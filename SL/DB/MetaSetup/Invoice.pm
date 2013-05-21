# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::Invoice;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->setup(
  table   => 'ar',

  columns => [
    id                        => { type => 'integer', not_null => 1, sequence => 'glid' },
    invnumber                 => { type => 'text', not_null => 1 },
    transdate                 => { type => 'date', default => 'now' },
    gldate                    => { type => 'date', default => 'now' },
    customer_id               => { type => 'integer' },
    taxincluded               => { type => 'boolean' },
    amount                    => { type => 'numeric', precision => 5, scale => 15 },
    netamount                 => { type => 'numeric', precision => 5, scale => 15 },
    paid                      => { type => 'numeric', precision => 5, scale => 15 },
    datepaid                  => { type => 'date' },
    duedate                   => { type => 'date' },
    deliverydate              => { type => 'date' },
    invoice                   => { type => 'boolean', default => 'false' },
    shippingpoint             => { type => 'text' },
    terms                     => { type => 'integer', default => '0' },
    notes                     => { type => 'text' },
    ordnumber                 => { type => 'text' },
    employee_id               => { type => 'integer' },
    quonumber                 => { type => 'text' },
    cusordnumber              => { type => 'text' },
    intnotes                  => { type => 'text' },
    department_id             => { type => 'integer' },
    shipvia                   => { type => 'text' },
    itime                     => { type => 'timestamp', default => 'now()' },
    mtime                     => { type => 'timestamp' },
    cp_id                     => { type => 'integer' },
    language_id               => { type => 'integer' },
    payment_id                => { type => 'integer' },
    delivery_customer_id      => { type => 'integer' },
    delivery_vendor_id        => { type => 'integer' },
    storno                    => { type => 'boolean', default => 'false' },
    taxzone_id                => { type => 'integer' },
    shipto_id                 => { type => 'integer' },
    type                      => { type => 'text' },
    dunning_config_id         => { type => 'integer' },
    orddate                   => { type => 'date' },
    quodate                   => { type => 'date' },
    globalproject_id          => { type => 'integer' },
    salesman_id               => { type => 'integer' },
    transaction_description   => { type => 'text' },
    storno_id                 => { type => 'integer' },
    marge_total               => { type => 'numeric', precision => 5, scale => 15 },
    marge_percent             => { type => 'numeric', precision => 5, scale => 15 },
    donumber                  => { type => 'text' },
    invnumber_for_credit_note => { type => 'text' },
    direct_debit              => { type => 'boolean', default => 'false' },
    currency_id               => { type => 'integer', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],

  allow_inline_column_values => 1,

  foreign_keys => [
    contact => {
      class       => 'SL::DB::Contact',
      key_columns => { cp_id => 'cp_id' },
    },

    currency => {
      class       => 'SL::DB::Currency',
      key_columns => { currency_id => 'id' },
    },

    customer => {
      class       => 'SL::DB::Customer',
      key_columns => { customer_id => 'id' },
    },

    department => {
      class       => 'SL::DB::Department',
      key_columns => { department_id => 'id' },
    },

    dunning_config => {
      class       => 'SL::DB::DunningConfig',
      key_columns => { dunning_config_id => 'id' },
    },

    employee => {
      class       => 'SL::DB::Employee',
      key_columns => { employee_id => 'id' },
    },

    globalproject => {
      class       => 'SL::DB::Project',
      key_columns => { globalproject_id => 'id' },
    },

    language => {
      class       => 'SL::DB::Language',
      key_columns => { language_id => 'id' },
    },

    payment_terms => {
      class       => 'SL::DB::PaymentTerm',
      key_columns => { payment_id => 'id' },
    },

    salesman => {
      class       => 'SL::DB::Employee',
      key_columns => { salesman_id => 'id' },
    },

    shipto => {
      class       => 'SL::DB::Shipto',
      key_columns => { shipto_id => 'shipto_id' },
    },

    storno_obj => {
      class       => 'SL::DB::Invoice',
      key_columns => { storno_id => 'id' },
    },
  ],
);

1;
;
