-- @tag: history_erp_snumbers
-- @description: Einf�hren der Buchungsnummern in die Historie
-- @depends: history_erp
ALTER TABLE history_erp ADD COLUMN snumbers text;
 