-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 03/09/2003 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis40bk;

CREATE PROCEDURE "informix".sp_sis40bk()
RETURNING  smallint;

define _weekday	smallint;
define _fecha_hoy date;

let _fecha_hoy	= current;
let _weekday	= weekday(_fecha_hoy);

	   RETURN _weekday;
END PROCEDURE
