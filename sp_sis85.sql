-- Procedure que retorna la fecha en formato char dd/mm/aaaa

drop procedure sp_sis85;

create procedure sp_sis85(a_fecha date)
returning char(10);

define _dia			char(2);
define _mes			char(2);
define _ano			char(4);
define _valor		smallint;
define _fecha_char	char(10);

let _valor = day(a_fecha);

if _valor < 10 then
	let _dia = "0" || _valor;
else 
	let _dia = _valor;
end if

let _valor = month(a_fecha);

if _valor < 10 then
	let _mes = "0" || _valor;
else 
	let _mes = _valor;
end if

let _ano = year(a_fecha);

let _fecha_char = _dia || "/" || _mes || "/" || _ano;

return _fecha_char;

end procedure

