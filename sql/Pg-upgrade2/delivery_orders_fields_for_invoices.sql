-- @tag: delivery_orders_fields_for_invoices
-- @description: Spalten in Lieferscheintabellen, um einige Werte von Auftr�gen zu Rechnungen zu �bernehmen
-- @depends: release_2_6_0
ALTER TABLE delivery_orders ADD COLUMN taxzone_id integer;
ALTER TABLE delivery_orders ADD COLUMN taxincluded boolean;
ALTER TABLE delivery_orders ADD COLUMN terms integer;
ALTER TABLE delivery_orders ADD COLUMN curr char(3);

UPDATE delivery_orders SET taxincluded = FALSE;

