--Procedimiento que devuelve el periodo año poliza

DROP PROCEDURE sp_sis21g;
CREATE PROCEDURE "informix".sp_sis21g(a_vig_ini date, a_siniestro date)
RETURNING date,date;

DEFINE _mes,_dia integer;
define _vig_ini  date;
define _vig_fin  date;
define _i        smallint;

SET ISOLATION TO DIRTY READ;

--	set debug file to "sp_sis21g.trc";
--	trace on;

let _vig_fin = a_vig_ini + 1 units year;

let _i = 0;

WHILE (_i <= 100) LOOP
	if (a_siniestro >= a_vig_ini) and (a_siniestro <= _vig_fin) then  
		let _i = 200;
	else
		let a_vig_ini = _vig_fin;
		let _vig_fin = a_vig_ini + 1 units year;
		let _i = _i + 1;
	end if
END LOOP;

RETURN a_vig_ini,_vig_fin;
END PROCEDURE;