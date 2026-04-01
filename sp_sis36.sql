-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis36;

CREATE PROCEDURE "informix".sp_sis36(a_periodo CHAR(7)) 
RETURNING DATE;

DEFINE _fecha  		 DATE;
DEFINE _mes    		 SMALLINT;
DEFINE _ano    	     SMALLINT;

-- Descomponer los periodos en fechas

LET _ano = a_periodo[1,4];
LET _mes = a_periodo[6,7];

IF _mes = 12 THEN
   LET _mes = 1;
   LET _ano = _ano + 1;
ELSE
   LET _mes = _mes + 1;
END IF

LET _fecha = MDY(_mes, 1, _ano);
LET _fecha = _fecha - 1;

RETURN _fecha;

END PROCEDURE;