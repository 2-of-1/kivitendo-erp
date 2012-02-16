#!/usr/bin/perl

use strict;

BEGIN {
  require Cwd;

  my $dir =  $0;
  $dir    =  Cwd::getcwd() . '/' . $dir unless $dir =~ m|^/|;
  $dir    =~ s|[^/]+$|..|;

  chdir($dir) || die "Cannot change directory to ${dir}\n";

  unshift @INC, "modules/override"; # Use our own versions of various modules (e.g. YAML).
  push    @INC, "modules/fallback"; # Only use our own versions of modules if there's no system version.
}

use CGI qw( -no_xhtml);
use Cwd;
use Daemon::Generic;
use Data::Dumper;
use DateTime;
use English qw(-no_match_vars);
use POSIX qw(setuid setgid);
use SL::Auth;
use SL::DB::BackgroundJob;
use SL::BackgroundJob::ALL;
use SL::Form;
use SL::Helper::DateTime;
use SL::LXDebug;
use SL::LxOfficeConf;
use SL::Locale;

our %lx_office_conf;

sub lxinit {
  my $login = $lx_office_conf{task_server}->{login};

  package main;

  $::lxdebug = LXDebug->new;
  $::locale  = Locale->new($::lx_office_conf{system}->{language});
  $::form    = Form->new;
  $::auth    = SL::Auth->new;
  $::request = { cgi => CGI->new({}) };

  die 'cannot reach auth db'               unless $::auth->session_tables_present;

  $::auth->restore_session;

  require "bin/mozilla/common.pl";

  die "cannot find user $login"            unless %::myconfig = $::auth->read_user(login => $login);
  die "cannot find locale for user $login" unless $::locale   = Locale->new('de');
}

sub drop_privileges {
  my $user = $lx_office_conf{task_server}->{run_as};
  return unless $user;

  my ($uid, $gid);
  while (my @details = getpwent()) {
    next unless $details[0] eq $user;
    ($uid, $gid) = @details[2, 3];
    last;
  }
  endpwent();

  if (!$uid) {
    print "Error: Cannot drop privileges to ${user}: user does not exist\n";
    exit 1;
  }

  if (!setgid($gid)) {
    print "Error: Cannot drop group privileges to ${user} (group ID $gid): $!\n";
    exit 1;
  }

  if (!setuid($uid)) {
    print "Error: Cannot drop user privileges to ${user} (user ID $uid): $!\n";
    exit 1;
  }
}

sub gd_preconfig {
  my $self = shift;

  SL::LxOfficeConf->read($self->{configfile});

  die "Missing section [task_server] in config file"                unless $lx_office_conf{task_server};
  die "Missing key 'login' in section [task_server] in config file" unless $lx_office_conf{task_server}->{login};

  drop_privileges();
  lxinit();

  return ();
}

sub gd_run {
  while (1) {
    my $ok = eval {
      $::lxdebug->message(0, "Retrieving jobs") if $lx_office_conf{task_server}->{debug};

      my $jobs = SL::DB::Manager::BackgroundJob->get_all_need_to_run;

      $::lxdebug->message(0, "  Found: " . join(' ', map { $_->package_name } @{ $jobs })) if $lx_office_conf{task_server}->{debug} && @{ $jobs };

      foreach my $job (@{ $jobs }) {
        # Provide fresh global variables in case legacy code modifies
        # them somehow.
        $::locale = Locale->new($::lx_office_conf{system}->{language});
        $::form   = Form->new;

        $job->run;
      }

      1;
    };

    if ($lx_office_conf{task_server}->{debug}) {
      $::lxdebug->message(0, "Exception during execution: ${EVAL_ERROR}") if !$ok;
      $::lxdebug->message(0, "Sleeping");
    }

    my $seconds = 60 - (localtime)[0];
    sleep($seconds < 30 ? $seconds + 60 : $seconds);
  }
}

my $cwd     = getcwd();
my $pidbase = "${cwd}/users/pid";

mkdir($pidbase) if !-d $pidbase;

my $file = -f "${cwd}/config/lx_office.conf" ? "${cwd}/config/lx_office.conf" : "${cwd}/config/lx_office.conf.default";
newdaemon(configfile => $file,
          progname   => 'lx-office-task-server',
          pidbase    => "${pidbase}/",
          );

1;
