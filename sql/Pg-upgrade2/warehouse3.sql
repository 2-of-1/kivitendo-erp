-- @tag: warehouse3
-- @description: Defaultwert f�r onhand nochmal erneut setzen nach Bugfix f�r 1289 Gutschriften auf Rechnungen l�sen Lagerbewegung aus
-- @depends: warehouse2 release_2_6_0
-- @charset: UTF-8
UPDATE parts SET onhand = COALESCE((SELECT SUM(qty) FROM inventory WHERE inventory.parts_id = parts.id), 0);
