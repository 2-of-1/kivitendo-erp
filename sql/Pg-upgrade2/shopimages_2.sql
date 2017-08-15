-- @tag:shopimages_2
-- @description: Umbennung der Spalten für Weite und Breite in die Weite und Breite des orginal Bildes
-- @charset: UTF-8
-- @depends: release_3_4_1 files shop_parts shopimages
-- @ignore: 0

ALTER TABLE shop_images RENAME thumbnail_width TO org_file_width;
ALTER TABLE shop_images RENAME thumbnail_height TO org_file_height;
