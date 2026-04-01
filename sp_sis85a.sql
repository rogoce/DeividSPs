-- Procedure que retorna la fecha en formato char dd-mmm-aaaa

--drop procedure sp_sis85a;

create procedure sp_sis85a(a_fecha date)
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

if _valor = 1 then
	let _mes = "JAN";
elif _valor = 2 then
	let _mes = "FEB";
elif _valor = 3 then
	let _mes = "MAR";
elif _valor = 4 then
	let _mes = "APR";
elif _valor = 5 then
	let _mes = "MAY";
elif _valor = 6 then
	let _mes = "JUN";
elif _valor = 7 then
	let _mes = "JUL";
elif _valor = 8 then
	let _mes = "AUG";
elif _valor = 9 then
	let _mes = "SEP";
elif _valor = 10 then
	let _mes = "OCT";
elif _valor = 11 then
	let _mes = "NOV";
elif _valor = 12 then
	let _mes = "DEC";
end if

let _ano = year(a_fecha);

let _fecha_char = _dia || "-" || _mes || "-" || _ano;

return _fecha_char;

end procedure

