-- @tag: custom_variables_parts_services_assemblies
-- @description: Benutzerdefinierte Variablen f�r Waren, Dienstleistungen, Erzeugnisse.
-- @depends: release_2_6_0
ALTER TABLE custom_variable_configs ADD COLUMN flags text;
