package SL::Helper::PrintOptions;

use strict;

use List::MoreUtils qw(any);


# generate the printing options displayed at the bottom of oe and is forms.
# this function will attempt to guess what type of form is displayed, and will generate according options
#
# about the coding:
# this version builds the arrays of options pretty directly. if you have trouble understanding how,
# the opthash function builds hashrefs which are then pieced together for the template arrays.
# unneeded options are "undef"ed out, and then grepped out.
#
# the inline options is untested, but intended to be used later in metatemplating
sub get_print_options {
  my ($class, %params) = @_;

  my $form     = $params{form}     || $::form;
  my $myconfig = $params{myconfig} || \%::myconfig;
  my $locale   = $params{locale}   || $::locale;
  my $options  = $params{options};

  my $prefix = $options->{dialog_name_prefix} || '';

  # names 3 parameters and returns a hashref, for use in templates
  sub opthash { +{ value => shift, selected => shift, oname => shift } }
  my (@FORMNAME, @LANGUAGE_ID, @FORMAT, @SENDMODE, @MEDIA, @PRINTER_ID, @SELECTS) = ();

  # note: "||"-selection is only correct for values where "0" is _not_ a correct entry
  $form->{sendmode}   = "attachment";
  $form->{format}     = $form->{format} || $myconfig->{template_format} || "pdf";
  $form->{copies}     = $form->{copies} || $myconfig->{copies}          || 3;
  $form->{media}      = $form->{media}  || $myconfig->{default_media}   || "screen";
  $form->{printer_id} = defined $form->{printer_id}           ? $form->{printer_id} :
                        defined $myconfig->{default_printer_id} ? $myconfig->{default_printer_id} : "";

  $form->{PD}{ $form->{formname} } = "selected";
  $form->{DF}{ $form->{format} }   = "selected";
  $form->{OP}{ $form->{media} }    = "selected";
  $form->{SM}{ $form->{sendmode} } = "selected";

  push @FORMNAME, grep $_,
    ($form->{type} eq 'purchase_order') ? (
      opthash("purchase_order",      $form->{PD}{purchase_order},      $locale->text('Purchase Order')),
      opthash("bin_list",            $form->{PD}{bin_list},            $locale->text('Bin List'))
    ) : undef,
    ($form->{type} eq 'credit_note') ?
      opthash("credit_note",         $form->{PD}{credit_note},         $locale->text('Credit Note')) : undef,
    ($form->{type} eq 'sales_order') ? (
      opthash("sales_order",         $form->{PD}{sales_order},         $locale->text('Confirmation')),
      opthash("proforma",            $form->{PD}{proforma},            $locale->text('Proforma Invoice')),
    ) : undef,
    ($form->{type} =~ /sales_quotation$/) ?
      opthash('sales_quotation',     $form->{PD}{sales_quotation},     $locale->text('Quotation')) : undef,
    ($form->{type} =~ /request_quotation$/) ?
      opthash('request_quotation',   $form->{PD}{request_quotation},   $locale->text('Request for Quotation')) : undef,
    ($form->{type} eq 'invoice') ? (
      opthash("invoice",             $form->{PD}{invoice},             $locale->text('Invoice')),
      opthash("proforma",            $form->{PD}{proforma},            $locale->text('Proforma Invoice')),
    ) : undef,
    ($form->{type} eq 'invoice' && $form->{storno}) ? (
      opthash("storno_invoice",      $form->{PD}{storno_invoice},      $locale->text('Storno Invoice')),
    ) : undef,
    ($form->{type} =~ /_delivery_order$/) ? (
      opthash($form->{type},         $form->{PD}{$form->{type}},       $locale->text('Delivery Order')),
      opthash('pick_list',           $form->{PD}{pick_list},           $locale->text('Pick List')),
    ) : undef;

  push @SENDMODE,
    opthash("attachment",            $form->{SM}{attachment},          $locale->text('Attachment')),
    opthash("inline",                $form->{SM}{inline},              $locale->text('In-line'))
      if ($form->{media} eq 'email');

  my $printable_templates = any { $::lx_office_conf{print_templates}->{$_} } qw(latex opendocument);
  push @MEDIA, grep $_,
      opthash("screen",              $form->{OP}{screen},              $locale->text('Screen')),
    ($printable_templates && $form->{printers} && scalar @{ $form->{printers} }) ?
      opthash("printer",             $form->{OP}{printer},             $locale->text('Printer')) : undef,
    ($printable_templates && !$options->{no_queue}) ?
      opthash("queue",               $form->{OP}{queue},               $locale->text('Queue')) : undef
        if ($form->{media} ne 'email');

  push @FORMAT, grep $_,
    ($::lx_office_conf{print_templates}->{opendocument} &&     $::lx_office_conf{applications}->{openofficeorg_writer}  &&     $::lx_office_conf{applications}->{xvfb}
                                                        && (-x $::lx_office_conf{applications}->{openofficeorg_writer}) && (-x $::lx_office_conf{applications}->{xvfb})
     && !$options->{no_opendocument_pdf}) ?
      opthash("opendocument_pdf",    $form->{DF}{"opendocument_pdf"},  $locale->text("PDF (OpenDocument/OASIS)")) : undef,
    ($::lx_office_conf{print_templates}->{latex}) ?
      opthash("pdf",                 $form->{DF}{pdf},                 $locale->text('PDF')) : undef,
    ($::lx_office_conf{print_templates}->{latex} && !$options->{no_postscript}) ?
      opthash("postscript",          $form->{DF}{postscript},          $locale->text('Postscript')) : undef,
    (!$options->{no_html}) ?
      opthash("html", $form->{DF}{html}, "HTML") : undef,
    ($::lx_office_conf{print_templates}->{opendocument} && !$options->{no_opendocument}) ?
      opthash("opendocument",        $form->{DF}{opendocument},        $locale->text("OpenDocument/OASIS")) : undef,
    ($::lx_office_conf{print_templates}->{excel} && !$options->{no_excel}) ?
      opthash("excel",               $form->{DF}{excel},               $locale->text("Excel")) : undef;

  push @LANGUAGE_ID,
    map { opthash($_->{id}, ($_->{id} eq $form->{language_id} ? 'selected' : ''), $_->{description}) } +{}, @{ $form->{languages} }
      if (ref $form->{languages} eq 'ARRAY');

  push @PRINTER_ID,
    map { opthash($_->{id}, ($_->{id} eq $form->{printer_id} ? 'selected' : ''), $_->{printer_description}) } +{}, @{ $form->{printers} }
      if ((ref $form->{printers} eq 'ARRAY') && scalar @{ $form->{printers } });

  @SELECTS = map {
    sname => $_->[1],
    DATA  => $_->[0],
    show  => !$options->{"hide_" . $_->[1]} && scalar @{ $_->[0] }
  },
  [ \@FORMNAME,    'formname',    ],
  [ \@LANGUAGE_ID, 'language_id', ],
  [ \@FORMAT,      'format',      ],
  [ \@SENDMODE,    'sendmode',    ],
  [ \@MEDIA,       'media',       ],
  [ \@PRINTER_ID,  'printer_id',  ];

  my %dont_display_groupitems = (
    'dunning' => 1,
    'letter'  => 1,
    );

  my %template_vars = (
    name_prefix          => $prefix || '',
    display_copies       => scalar @{ $form->{printers} || [] } && $::lx_office_conf{print_templates}->{latex} && $form->{media} ne 'email',
    display_remove_draft => (!$form->{id} && $form->{draft_id}),
    display_groupitems   => !$dont_display_groupitems{$form->{type}},
    groupitems_checked   => $form->{groupitems} ? "checked" : '',
    remove_draft_checked => $form->{remove_draft} ? "checked" : ''
  );

  return $form->parse_html_template("generic/print_options", { SELECTS  => \@SELECTS, %template_vars } );
}

1;
