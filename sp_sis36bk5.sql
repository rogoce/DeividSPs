-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36bk5;
CREATE PROCEDURE "informix".sp_sis36bk5(a_periodo CHAR(7)) 
RETURNING DATE;

DEFINE _fecha  		 DATE;
DEFINE _mes    		 SMALLINT;
DEFINE _ano    	     SMALLINT;

-- Descomponer los periodos en fechas

LET _ano = a_periodo[1,4];
LET _mes = a_periodo[6,7];


LET _fecha = MDY(_mes, 1, _ano);

let _fecha = _fecha - 1;
RETURN _fecha;

END PROCEDURE;