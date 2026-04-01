-- reporte para sacar estadistica de emirepol
-- Creado    : 22/04/2005 - Autor: Armando Moreno

DROP PROCEDURE sp_pro28i;

CREATE PROCEDURE "informix".sp_pro28i(a_ano integer, a_ano2 integer)
 RETURNING	integer,char(7),integer; -- cant. reg.

DEFINE _cant_reg    	INTEGER;
define _vigencia_final	date;
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
define _mes             integer;
define _valor           integer;

create temp table tmp_13(
periodo			char(7),
cantidad		integer,
trimestre		integer
) with no log;

SET ISOLATION TO DIRTY READ;

let _cant_reg = 0;

foreach

 SELECT vigencia_final,
		month(vigencia_final)
   INTO _vigencia_final,
		_mes
   FROM emirepol
  WHERE year(vigencia_final) between a_ano and a_ano2

--    and month(vigencia_final) in(1,2,3)

	IF  MONTH(_vigencia_final) < 10 THEN
		LET _mes_char = '0'|| MONTH(_vigencia_final);
	ELSE
		LET _mes_char = MONTH(_vigencia_final);
	END IF

	LET _ano_char = YEAR(_vigencia_final);
	LET _periodo  = _ano_char || "-" || _mes_char;
	let _cant_reg = _cant_reg + 1;

   if _mes > 0 and _mes <= 3 then
		let _valor = 1;
   end if
   if _mes > 3 and _mes <= 6 then
		let _valor = 2;
   end if
   if _mes > 6 then
		let _valor = 3;
   end if

	insert into tmp_13
	values (_periodo, _cant_reg,_valor);

end foreach

foreach
 select periodo,
        cantidad,
		trimestre
   into _periodo,
	    _cant_reg,
        _valor
   from tmp_13

	RETURN _cant_reg,
		   _periodo,
		   _valor	
			with resume;
end foreach
drop table tmp_13;
END PROCEDURE
