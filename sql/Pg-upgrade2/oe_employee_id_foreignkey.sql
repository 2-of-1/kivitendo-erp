-- @tag: oe_employee_id_foreignkey  
-- @description: Falls ein Benutzer hart in der Datenbank gel�scht werden soll, m�ssen auch die Verkn�pfung zu seinen bearbeitenden Auftr�ge bedacht werden
-- @depends: release_2_4_3
ALTER TABLE oe ADD FOREIGN KEY (employee_id) REFERENCES employee (id);
