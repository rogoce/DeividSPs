
-- Detalle de las unidades

-- Creado    : 03/09/2010 - Autor: Armando Moreno
-- Modificado: 03/09/2010 - Autor: Armando Moreno


DROP PROCEDURE sp_rec174;

CREATE PROCEDURE sp_rec174(a_nopoliza CHAR(10),a_nounidad CHAR(5), a_fecha DATE)
RETURNING smallint;

define _cant	smallint;
define _fecha   date;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec174.trc";
--TRACE ON;

let _fecha = current;

 SELECT	count(*)
   INTO	_cant
   FROM	recrcmae
  WHERE actualizado = 1
    AND no_poliza   = a_nopoliza
	AND no_unidad   = a_nounidad
	AND fecha_siniestro	= a_fecha;
   --	AND fecha_reclamo   = _fecha;

RETURN _cant;

END PROCEDURE;


