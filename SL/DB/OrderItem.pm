package SL::DB::OrderItem;

use strict;

use SL::DB::MetaSetup::OrderItem;
use SL::DB::Helper::CustomVariables (
  sub_module  => 'orderitems',
  cvars_alias => 1,
  overloads   => {
    parts_id => 'SL::DB::Part',
  },
);

__PACKAGE__->meta->add_relationship(
  part => {
    type         => 'one to one',
    class        => 'SL::DB::Part',
    column_map   => { parts_id => 'id' },
  },
  price_factor_obj => {
    type           => 'one to one',
    class          => 'SL::DB::PriceFactor',
    column_map     => { price_factor_id => 'id' },
  },
  unit_obj       => {
    type         => 'one to one',
    class        => 'SL::DB::Unit',
    column_map   => { unit => 'name' },
  },
  order => {
    type         => 'one to one',
    class        => 'SL::DB::Order',
    column_map   => { trans_id => 'id' },
  },
);

# Creates get_all, get_all_count, get_all_iterator, delete_all and update_all.
__PACKAGE__->meta->make_manager_class;

__PACKAGE__->meta->initialize;

sub is_price_update_available {
  my $self = shift;
  return $self->origprice > $self->part->sellprice;
}

package SL::DB::Manager::OrderItem;

use SL::DB::Helper::Paginated;
use SL::DB::Helper::Sorted;

sub _sort_spec {
  return ( columns => { delivery_date => [ 'deliverydate',        ],
                        description   => [ 'lower(orderitems.description)',  ],
                        partnumber    => [ 'part.partnumber',     ],
                        qty           => [ 'qty'                  ],
                        ordnumber     => [ 'order.ordnumber'      ],
                        customer      => [ 'lower(customer.name)', ],
                        position      => [ 'trans_id', 'runningnumber' ],
                        transdate     => [ 'transdate', 'lower(order.reqdate::text)' ],
                      },
           default => [ 'position', 1 ],
           nulls   => { }
         );
}

sub default_objects_per_page { 40 }

1;
