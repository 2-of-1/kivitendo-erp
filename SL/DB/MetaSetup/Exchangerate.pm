# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::Exchangerate;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->setup(
  table   => 'exchangerate',

  columns => [
    transdate   => { type => 'date' },
    buy         => { type => 'numeric', precision => 5, scale => 15 },
    sell        => { type => 'numeric', precision => 5, scale => 15 },
    itime       => { type => 'timestamp', default => 'now()' },
    mtime       => { type => 'timestamp' },
    id          => { type => 'serial', not_null => 1 },
    currency_id => { type => 'integer', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],
);

1;
;
