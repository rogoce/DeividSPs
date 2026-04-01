-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 06/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis26pru;

CREATE PROCEDURE "informix".sp_sis26pru()
	   RETURNING   DATE,
	   			   datetime hour to fraction(5);

	   RETURN CURRENT,CURRENT;
END PROCEDURE
