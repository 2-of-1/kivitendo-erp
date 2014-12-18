package SL::PriceSource::Pricegroup;

use strict;
use parent qw(SL::PriceSource::Base);

use SL::PriceSource::Price;
use SL::DB::Price;
use SL::Locale::String;
use List::UtilsBy qw(min_by);
use List::Util qw(first);

sub name { 'pricegroup' }

sub description { t8('Pricegroup') }

sub available_prices {
  my ($self, %params) = @_;

  return () unless $self->record->is_sales;

  my $item = $self->record_item;

  my $prices = SL::DB::Manager::Price->get_all(
    query        => [ parts_id => $item->parts_id, price => { gt => 0 } ],
    with_objects => 'pricegroup',
    order_by     => 'pricegroun.id',
  );

  return () unless @$prices;

  return map {
    $self->make_price($_);
  } @$prices;
}

sub price_from_source {
  my ($self, $source, $spec) = @_;

  my $price = SL::DB::Manager::Price->find_by(pricegroup_id => $spec, parts_id => $self->part->id);

  # TODO: if someone deletes the prices entry, this fails. add a fallback
  return $self->make_price($price);
}

sub best_price {
  my ($self, %params) = @_;

  return () unless $self->record->is_sales;

  my @prices    = $self->available_prices;
  my $customer  = $self->record->customer;

  return () if !$customer || !$customer->klass;

  my $best_price = first { $_->spec == $customer->klass } @prices;

  return $best_price || ();
}

sub make_price {
  my ($self, $price_obj) = @_;

  SL::PriceSource::Price->new(
    price        => $price_obj->price,
    spec         => $price_obj->pricegroup->id,
    description  => $price_obj->pricegroup->pricegroup,
    price_source => $self,
  )
}

1;
