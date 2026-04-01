--Procedimiento que devuelve el periodo año poliza

DROP PROCEDURE sp_sis21d;
CREATE PROCEDURE "informix".sp_sis21d(a_vig_ini date, a_ano integer)
RETURNING date,date;

DEFINE _mes,_dia integer;
define _vig_ini  date;
define _vig_fin  date;

SET ISOLATION TO DIRTY READ;


let _mes = month(a_vig_ini);
let _dia = day(a_vig_ini);
let _vig_ini = MDY(_mes, _dia, a_ano);

LET _vig_fin = MDY(_mes, _dia, a_ano + 1);
LET _vig_fin = _vig_fin - 1;

RETURN _vig_ini,_vig_fin;

END PROCEDURE;