-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 03/09/2003 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis40a;

CREATE PROCEDURE "informix".sp_sis40a()
	   RETURNING datetime hour to second;

	   RETURN CURRENT;
END PROCEDURE
