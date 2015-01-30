package SL::DB::PurchaseInvoice;

use strict;

use Carp;

use SL::DB::MetaSetup::PurchaseInvoice;
use SL::DB::Manager::PurchaseInvoice;
use SL::DB::Helper::LinkedRecords;
use SL::Locale::String qw(t8);

# The calculator hasn't been adjusted for purchase invoices yet.
# use SL::DB::Helper::PriceTaxCalculator;

__PACKAGE__->meta->add_relationship(
  invoiceitems   => {
    type         => 'one to many',
    class        => 'SL::DB::InvoiceItem',
    column_map   => { id => 'trans_id' },
    manager_args => { with_objects => [ 'part' ] }
  },
  sepa_export_items => {
    type            => 'one to many',
    class           => 'SL::DB::SepaExportItem',
    column_map      => { id => 'ap_id' },
    manager_args    => { with_objects => [ 'sepa_export' ] }
  },
  custom_shipto     => {
    type            => 'one to one',
    class           => 'SL::DB::Shipto',
    column_map      => { id => 'trans_id' },
    query_args      => [ module => 'AP' ],
  },
  transactions   => {
    type         => 'one to many',
    class        => 'SL::DB::AccTransaction',
    column_map   => { id => 'trans_id' },
    manager_args => { with_objects => [ 'chart' ],
                      sort_by      => 'acc_trans_id ASC' }
  },
);

__PACKAGE__->meta->initialize;

sub items { goto &invoiceitems; }
sub add_items { goto &add_invoiceitems; }

sub items_sorted {
  my ($self) = @_;

  return [ sort {$a->position <=> $b->position } @{ $self->items } ];
}

sub is_sales {
  # For compatibility with Order, DeliveryOrder
  croak 'not an accessor' if @_ > 1;
  return 0;
}

sub date {
  goto &transdate;
}

sub reqdate {
  goto &duedate;
}

sub customervendor {
  goto &vendor;
}

sub abbreviation {
  my $self = shift;

  return t8('AP Transaction (abbreviation)') if !$self->invoice && !$self->storno;
  return t8('AP Transaction (abbreviation)') . '(' . t8('Storno (one letter abbreviation)') . ')' if !$self->invoice && $self->storno;
  return t8('Invoice (one letter abbreviation)'). '(' . t8('Storno (one letter abbreviation)') . ')' if $self->storno;
  return t8('Invoice (one letter abbreviation)');

}

1;
