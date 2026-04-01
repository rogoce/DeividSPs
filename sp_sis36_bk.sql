-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36_bk;

CREATE PROCEDURE "informix".sp_sis36_bk(a_periodo CHAR(7)) 
RETURNING DATE;

DEFINE _fecha  		 DATE;


LET _fecha = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

RETURN _fecha;

END PROCEDURE;