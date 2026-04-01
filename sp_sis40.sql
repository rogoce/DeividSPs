-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 03/09/2003 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis40;

CREATE PROCEDURE sp_sis40()
	   RETURNING  datetime year to fraction(5);

	   RETURN CURRENT;
END PROCEDURE
