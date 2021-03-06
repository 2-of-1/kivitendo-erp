# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::AuthUser;

use strict;

use parent qw(SL::DB::Object);

__PACKAGE__->meta->table('user');
__PACKAGE__->meta->schema('auth');

__PACKAGE__->meta->columns(
  id       => { type => 'serial', not_null => 1 },
  login    => { type => 'text', not_null => 1 },
  password => { type => 'text' },
);

__PACKAGE__->meta->primary_key_columns([ 'id' ]);

__PACKAGE__->meta->unique_keys([ 'login' ]);

1;
;
