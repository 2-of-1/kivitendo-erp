# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::Draft;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->table('drafts');

__PACKAGE__->meta->columns(
  id          => { type => 'varchar', length => 50, not_null => 1 },
  module      => { type => 'varchar', length => 50, not_null => 1 },
  submodule   => { type => 'varchar', length => 50, not_null => 1 },
  description => { type => 'text' },
  itime       => { type => 'timestamp', default => 'now()' },
  form        => { type => 'text' },
  employee_id => { type => 'integer' },
);

__PACKAGE__->meta->primary_key_columns([ 'id' ]);

__PACKAGE__->meta->allow_inline_column_values(1);

__PACKAGE__->meta->foreign_keys(
  employee => {
    class       => 'SL::DB::Employee',
    key_columns => { employee_id => 'id' },
  },
);

# __PACKAGE__->meta->initialize;

1;
;
