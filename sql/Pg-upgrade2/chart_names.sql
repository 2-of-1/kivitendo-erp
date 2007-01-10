-- @tag: chart_names
-- @description: Behebt ein paar Schreibfehler in Kontennamen in den Kontenramen SKR03 und SKR04.
-- @depends:
UPDATE chart
  SET description = replace(description, 'Saldenvertr�ge', 'Saldenvortr�ge')
  WHERE
    ((SELECT coa FROM defaults) IN ('Germany-DATEV-SKR03EU', 'Germany-DATEV-SKR04EU')) AND
    (description LIKE 'Saldenvertr�ge%');
UPDATE chart
  SET description = replace(description, 'Abziebare', 'Abziehbare')
  WHERE
    ((SELECT coa FROM defaults) IN ('Germany-DATEV-SKR03EU', 'Germany-DATEV-SKR04EU')) AND
    (description LIKE 'Abziehbare%');
