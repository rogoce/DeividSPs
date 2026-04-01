-- Carta a Acredor - 15 dias despues
-- creado    : 22/02/2012 - autor: henry giron
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_sis397('01/02/2012',15)
drop procedure sp_sis397;
create procedure sp_sis397(a_fecha date, a_despues smallint)
returning date;
define _recorrer_dia  date;
define _dias_semana   smallint;
define _feriado       smallint;
define _dia_actual    smallint;
let _dias_semana = 0;

if a_despues is null or a_despues <= 0 then
    return a_fecha;
end if

let _dias_semana = 1;
let _recorrer_dia = a_fecha;

while _dias_semana < a_despues	
	select count(*) into _feriado from avicanfer
	where dia = day(_recorrer_dia)
	  and mes = month(_recorrer_dia)
	  and estatus = 1;
	if _feriado is null then
		let _feriado = 0;
	end if
	if _feriado = 0 then
	    if weekday(_recorrer_dia) > 0 and weekday(_recorrer_dia) < 7 then	 
	        let _dias_semana = _dias_semana + 1;
	    end if
    end if
    let _recorrer_dia = _recorrer_dia + 1 units day;
end while

return _recorrer_dia ;
end procedure
				