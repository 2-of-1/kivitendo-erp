package SL::DB::Project;

use strict;

use SL::DB::MetaSetup::Project;

use SL::DB::Helper::CustomVariables(
  module      => 'Project',
  cvars_alias => 1,
);

__PACKAGE__->meta->make_manager_class;
__PACKAGE__->meta->initialize;

1;

__END__

=pod

=head1 NAME

SL::DB::Project: Model for the 'project' table

=head1 SYNOPSIS

This is a standard Rose::DB::Object based model and can be used as one.

=head1 FUNCTIONS

None so far.

=head1 AUTHOR

Moritz Bunkus E<lt>m.bunkus@linet-services.deE<gt>

=cut
