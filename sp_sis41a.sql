-- Procedimiento para traer el año actual.
-- Es usado para Incentivo No.2
-- Creado    : 02/03/2022 - Autor: Lic. Armando Moreno M.

DROP PROCEDURE sp_sis41a;
CREATE PROCEDURE sp_sis41a()
	   RETURNING  integer;

define _fecha_int integer;
--let _fecha_int = year(current) -1;

let _fecha_int = 2025;

RETURN _fecha_int;
END PROCEDURE
