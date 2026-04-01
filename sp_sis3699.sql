-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis3699;
CREATE PROCEDURE "informix".sp_sis3699(a_periodo CHAR(7)) 
RETURNING char(7);

DEFINE _fecha  		 DATE;
DEFINE _mes    		 SMALLINT;
DEFINE _ano    	     SMALLINT;
define _periodo      char(7);

-- Descomponer los periodos en fechas

LET _mes = a_periodo[6,7];

let _mes = _mes + 1;

IF _mes >= 10 THEN
   LET _periodo = a_periodo[1,5] || _mes;
ELSE
   LET _periodo = a_periodo[1,4] || '-0' || _mes;
END IF

RETURN _periodo;

END PROCEDURE;