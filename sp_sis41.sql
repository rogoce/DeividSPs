-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 03/09/2003 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis41;

CREATE PROCEDURE "informix".sp_sis41()
	   RETURNING  datetime year to fraction(5);

define _fecha_hora datetime year to fraction(5);
let _fecha_hora = current;
let _fecha_hora = _fecha_hora + 1 UNITS SECOND;

	   RETURN _fecha_hora;
END PROCEDURE
