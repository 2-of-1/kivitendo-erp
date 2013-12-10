# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::DeliveryTerm;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->setup(
  table   => 'delivery_terms',

  columns => [
    id               => { type => 'integer', not_null => 1, sequence => 'id' },
    description      => { type => 'text' },
    description_long => { type => 'text' },
    sortkey          => { type => 'integer', not_null => 1 },
    itime            => { type => 'timestamp', default => 'now()' },
    mtime            => { type => 'timestamp' },
  ],

  primary_key_columns => [ 'id' ],

  allow_inline_column_values => 1,
);

1;
;
