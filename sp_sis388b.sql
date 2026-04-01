-- procedimiento dias valido para marcar
-- creado    : 03/01/2020 - autor: Henry Giron
-- manejo especial para fecha_marcar solo cuando caiga sabado o domingo en avisocanc se le coloca el dia lunes
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_sis388b('01/07/2011')

drop procedure sp_sis388b;
create procedure sp_sis388b(a_fecha date)
returning date;

define _recorrer_dia  date;
define _dia_week      smallint;

--set debug file to "sp_sis388b.trc"; 
--trace on;

let _recorrer_dia = a_fecha;
let _dia_week = weekday(_recorrer_dia);

 if _dia_week = 6 then
    let _recorrer_dia = _recorrer_dia + 2 units day;
 else
     if _dia_week = 0 then
        let _recorrer_dia = _recorrer_dia + 1 units day;
	end if	  
end if

return _recorrer_dia;
end procedure
				