package SL::DB::Part;

use strict;

use Carp;
use List::MoreUtils qw(any);
use Rose::DB::Object::Helpers qw(as_tree);

use SL::DBUtils;
use SL::DB::MetaSetup::Part;
use SL::DB::Manager::Part;
use SL::DB::Chart;
use SL::DB::Helper::AttrHTML;
use SL::DB::Helper::TransNumberGenerator;
use SL::DB::Helper::CustomVariables (
  module      => 'IC',
  cvars_alias => 1,
);

__PACKAGE__->meta->add_relationships(
  assemblies                     => {
    type         => 'one to many',
    class        => 'SL::DB::Assembly',
    column_map   => { id => 'id' },
  },
  prices         => {
    type         => 'one to many',
    class        => 'SL::DB::Price',
    column_map   => { id => 'parts_id' },
  },
  makemodels     => {
    type         => 'one to many',
    class        => 'SL::DB::MakeModel',
    column_map   => { id => 'parts_id' },
  },
  translations   => {
    type         => 'one to many',
    class        => 'SL::DB::Translation',
    column_map   => { id => 'parts_id' },
  },
  assortment_items => {
    type         => 'one to many',
    class        => 'SL::DB::AssortmentItem',
    column_map   => { id => 'assortment_id' },
  },
);

__PACKAGE__->meta->initialize;

__PACKAGE__->attr_html('notes');

__PACKAGE__->before_save('_before_save_set_partnumber');

sub _before_save_set_partnumber {
  my ($self) = @_;

  $self->create_trans_number if !$self->partnumber;
  return 1;
}

sub is_type {
  my $self = shift;
  my $type  = lc(shift || '');
  die 'invalid type' unless $type =~ /^(?:part|service|assembly|assortment)$/;

  return $self->type eq $type ? 1 : 0;
}

sub is_part       { $_[0]->part_type eq 'part'       }
sub is_assembly   { $_[0]->part_type eq 'assembly'   }
sub is_service    { $_[0]->part_type eq 'service'    }
sub is_assortment { $_[0]->part_type eq 'assortment' }

sub type {
  return $_[0]->part_type;
  # my ($self, $type) = @_;
  # if (@_ > 1) {
  #   die 'invalid type' unless $type =~ /^(?:part|service|assembly)$/;
  #   $self->assembly(          $type eq 'assembly' ? 1 : 0);
  #   $self->inventory_accno_id($type ne 'service'  ? 1 : undef);
  # }

  # return 'assembly' if $self->assembly;
  # return 'part'     if $self->inventory_accno_id;
  # return 'service';
}

sub new_part {
  my ($class, %params) = @_;
  $class->new(%params, part_type => 'part');
}

sub new_assembly {
  my ($class, %params) = @_;
  $class->new(%params, part_type => 'assembly');
}

sub new_service {
  my ($class, %params) = @_;
  $class->new(%params, part_type => 'service');
}

sub new_assortment {
  my ($class, %params) = @_;
  $class->new(%params, part_type => 'assortment');
}

sub orphaned {
  my ($self) = @_;
  die 'not an accessor' if @_ > 1;

  my @relations = qw(
    SL::DB::InvoiceItem
    SL::DB::OrderItem
    SL::DB::Inventory
    SL::DB::Assembly
    SL::DB::AssortmentItem
  );

  for my $class (@relations) {
    eval "require $class";
    return 0 if $class->_get_manager_class->get_all_count(query => [ parts_id => $self->id ]);
  }
  return 1;
}

sub get_sellprice_info {
  my $self   = shift;
  my %params = @_;

  confess "Missing part id" unless $self->id;

  my $object = $self->load;

  return { sellprice       => $object->sellprice,
           price_factor_id => $object->price_factor_id };
}

sub get_ordered_qty {
  my $self   = shift;
  my %result = SL::DB::Manager::Part->get_ordered_qty($self->id);

  return $result{ $self->id };
}

sub available_units {
  shift->unit_obj->convertible_units;
}

# autogenerated accessor is slightly off...
sub buchungsgruppe {
  shift->buchungsgruppen(@_);
}

sub get_taxkey {
  my ($self, %params) = @_;

  my $date     = $params{date} || DateTime->today_local;
  my $is_sales = !!$params{is_sales};
  my $taxzone  = $params{ defined($params{taxzone}) ? 'taxzone' : 'taxzone_id' } * 1;
  my $tk_info  = $::request->cache('get_taxkey');

  $tk_info->{$self->id}                                      //= {};
  $tk_info->{$self->id}->{$taxzone}                          //= { };
  my $cache = $tk_info->{$self->id}->{$taxzone}->{$is_sales} //= { };

  if (!exists $cache->{$date}) {
    $cache->{$date} =
      $self->get_chart(type => $is_sales ? 'income' : 'expense', taxzone => $taxzone)
      ->get_active_taxkey($date);
  }

  return $cache->{$date};
}

sub get_chart {
  my ($self, %params) = @_;

  my $type    = (any { $_ eq $params{type} } qw(income expense inventory)) ? $params{type} : croak("Invalid 'type' parameter '$params{type}'");
  my $taxzone = $params{ defined($params{taxzone}) ? 'taxzone' : 'taxzone_id' } * 1;

  my $charts     = $::request->cache('get_chart_id/by_part_id_and_taxzone')->{$self->id} //= {};
  my $all_charts = $::request->cache('get_chart_id/by_id');

  $charts->{$taxzone} ||= { };

  if (!exists $charts->{$taxzone}->{$type}) {
    require SL::DB::Buchungsgruppe;
    my $bugru    = SL::DB::Buchungsgruppe->load_cached($self->buchungsgruppen_id);
    my $chart_id = ($type eq 'inventory') ? ($self->inventory_accno_id ? $bugru->inventory_accno_id : undef)
                 :                          $bugru->call_sub("${type}_accno_id", $taxzone);

    if ($chart_id) {
      my $chart                    = $all_charts->{$chart_id} // SL::DB::Chart->load_cached($chart_id)->load;
      $all_charts->{$chart_id}     = $chart;
      $charts->{$taxzone}->{$type} = $chart;
    }
  }

  return $charts->{$taxzone}->{$type};
}

# this is designed to ignore chargenumbers, expiration dates and just give a list of how much <-> where
sub get_simple_stock {
  my ($self, %params) = @_;

  return [] unless $self->id;

  my $query = <<'';
    SELECT sum(qty), warehouse_id, bin_id FROM inventory WHERE parts_id = ?
    GROUP BY warehouse_id, bin_id

  my $stock_info = selectall_hashref_query($::form, $::form->get_standard_dbh, $query, $self->id);
  [ map { bless $_, 'SL::DB::Part::SimpleStock'} @$stock_info ];
}
# helper class to have bin/warehouse accessors in stock result
{ package SL::DB::Part::SimpleStock;
  sub warehouse { require SL::DB::Warehouse; SL::DB::Manager::Warehouse->find_by_or_create(id => $_[0]->{warehouse_id}) }
  sub bin       { require SL::DB::Bin;       SL::DB::Manager::Bin      ->find_by_or_create(id => $_[0]->{bin_id}) }
}

sub displayable_name {
  join ' ', grep $_, map $_[0]->$_, qw(partnumber description);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

SL::DB::Part: Model for the 'parts' table

=head1 SYNOPSIS

This is a standard Rose::DB::Object based model and can be used as one.

=head1 TYPES

Although the base class is called C<Part> we usually talk about C<Articles> if
we mean instances of this class. This is because articles come in three
flavours called:

=over 4

=item Part     - a single part

=item Service  - a part without onhand, and without inventory accounting

=item Assembly - a collection of both parts and services

=item Assortment - a collection of parts

=back

These types are sadly represented by data inside the class and cannot be
migrated into a flag. To work around this, each C<Part> object knows what type
it currently is. Since the type is data driven, there ist no explicit setting
method for it, but you can construct them explicitly with C<new_part>,
C<new_service>, C<new_assembly> and C<new_assortment>. A Buchungsgruppe should be supplied in this
case, but it will use the default Buchungsgruppe if you don't.

Matching these there are assorted helper methods dealing with types,
e.g.  L</new_part>, L</new_service>, L</new_assembly>, L</type>,
L</is_type> and others.

=head1 FUNCTIONS

=over 4

=item C<new_part %PARAMS>

=item C<new_service %PARAMS>

=item C<new_assembly %PARAMS>

Will set the appropriate data fields so that the resulting instance will be of
the requested type. Since accounting targets are part of the distinction,
providing a C<Buchungsgruppe> is recommended. If none is given the constructor
will load a default one and set the accounting targets from it.

=item C<type>

Returns the type as a string. Can be one of C<part>, C<service>, C<assembly>.

=item C<is_type $TYPE>

Tests if the current object is a part, a service or an
assembly. C<$type> must be one of the words 'part', 'service' or
'assembly' (their plurals are ok, too).

Returns 1 if the requested type matches, 0 if it doesn't and
C<confess>es if an unknown C<$type> parameter is encountered.

=item C<is_part>

=item C<is_service>

=item C<is_assembly>

Shorthand for C<is_type('part')> etc.

=item C<get_sellprice_info %params>

Retrieves the C<sellprice> and C<price_factor_id> for a part under
different conditions and returns a hash reference with those two keys.

If C<%params> contains a key C<project_id> then a project price list
will be consulted if one exists for that project. In this case the
parameter C<country_id> is evaluated as well: if a price list entry
has been created for this country then it will be used. Otherwise an
entry without a country set will be used.

If none of the above conditions is met then the information from
C<$self> is used.

=item C<get_ordered_qty %params>

Retrieves the quantity that has been ordered from a vendor but that
has not been delivered yet. Only open purchase orders are considered.

=item C<get_taxkey %params>

Retrieves and returns a taxkey object valid for the given date
C<$params{date}> and tax zone C<$params{taxzone}>
(C<$params{taxzone_id}> is also recognized). The date defaults to the
current date if undefined.

This function looks up the income (for trueish values of
C<$params{is_sales}>) or expense (for falsish values of
C<$params{is_sales}>) account for the current part. It uses the part's
associated buchungsgruppe and uses the fields belonging to the tax
zone given by C<$params{taxzone}>.

The information retrieved by the function is cached.

=item C<get_chart %params>

Retrieves and returns a chart object valid for the given type
C<$params{type}> and tax zone C<$params{taxzone}>
(C<$params{taxzone_id}> is also recognized). The type must be one of
the three key words C<income>, C<expense> and C<inventory>.

This function uses the part's associated buchungsgruppe and uses the
fields belonging to the tax zone given by C<$params{taxzone}>.

The information retrieved by the function is cached.

=item C<orphaned>

Checks if this article is used in orders, invoices, delivery orders or
assemblies.

=item C<buchungsgruppe BUCHUNGSGRUPPE>

Used to set the accounting information from a L<SL:DB::Buchungsgruppe> object.
Please note, that this is a write only accessor, the original Buchungsgruppe can
not be retrieved from an article once set.

=back

=head1 AUTHORS

Moritz Bunkus E<lt>m.bunkus@linet-services.deE<gt>,
Sven Schöling E<lt>s.schoeling@linet-services.deE<gt>

=cut
