-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 06/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis261;

CREATE PROCEDURE "informix".sp_sis261()
	   RETURNING   DATE,
	               DATE;				 
	   DEFINE fecha1, fecha2 date;
	   LET fecha1 = '01/01/2002';
	   LET fecha2 = fecha1 - 1;

	   RETURN fecha1,
	          fecha2;
END PROCEDURE
