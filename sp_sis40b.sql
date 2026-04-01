-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 03/09/2003 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

---DROP PROCEDURE sp_sis40b;

CREATE PROCEDURE "informix".sp_sis40b(a_periodo char(7))
	   RETURNING  date;

	   define _fecha_ini date;
	   
	   let _fecha_ini = mdy(a_periodo[6,7], 1, a_periodo[1,4]);
	   RETURN _fecha_ini;
END PROCEDURE
