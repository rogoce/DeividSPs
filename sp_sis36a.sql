-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis36a;

CREATE PROCEDURE "informix".sp_sis36a()
RETURNING DATE;

DEFINE _fecha  		 DATE;
define _per_ini char(7);


LET _per_ini = "2010-10";

let _fecha = mdy(_per_ini[6,7], 1, _per_ini[1,4]);

--LET _fecha = _fecha - 1;

RETURN _fecha;

END PROCEDURE;