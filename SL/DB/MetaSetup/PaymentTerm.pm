# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::PaymentTerm;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->table('payment_terms');

__PACKAGE__->meta->columns(
  id               => { type => 'integer', not_null => 1, sequence => 'id' },
  description      => { type => 'text' },
  description_long => { type => 'text' },
  terms_netto      => { type => 'integer' },
  terms_skonto     => { type => 'integer' },
  percent_skonto   => { type => 'float', precision => 4 },
  itime            => { type => 'timestamp', default => 'now()' },
  mtime            => { type => 'timestamp' },
  ranking          => { type => 'integer' },
  sortkey          => { type => 'integer', not_null => 1 },
);

__PACKAGE__->meta->primary_key_columns([ 'id' ]);

__PACKAGE__->meta->allow_inline_column_values(1);

# __PACKAGE__->meta->initialize;

1;
;
