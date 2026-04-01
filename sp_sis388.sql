-- procedimiento dias valido para cancelar
-- creado    : 01/06/2011 - autor: henry giron
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_sis388('01/07/2011','08/07/2011')

drop procedure sp_sis388;

create procedure sp_sis388(a_desde date, a_hasta date)
returning smallint;

define _recorrer_dia  date;
define _dias_semana   smallint;
define _feriado       smallint;

let _dias_semana = 0;

if a_desde is null or a_hasta is null or a_hasta < a_desde then
    return _dias_semana;
end if

let _dias_semana = 0;
let _recorrer_dia = a_desde;

while _recorrer_dia <= a_hasta	

	select count(*) 
	  into _feriado 
	  from avicanfer
	 where dia = day(_recorrer_dia)
	   and mes = month(_recorrer_dia)
	   and estatus = 1;

	if _feriado is null then
		let _feriado = 0;
	end if

	if _feriado = 0 then
	    if weekday(_recorrer_dia) > 0 and weekday(_recorrer_dia) < 7 then	 -- Se incluye Sabado. Sr. Berrocal.
	        let _dias_semana = _dias_semana + 1;
	    end if
    end if

    let _recorrer_dia = _recorrer_dia + 1 units day;

end while

return _dias_semana;
end procedure
