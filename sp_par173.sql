-- Conversion de la fecha de cumpleaños de la tabla de CAJS

drop procedure sp_par173;

create procedure "informix".sp_par173(a_fecha char(20))
returning date;

define _fecha	date;

define _dia_char	char(2);
define _mes_char	char(3);
define _ano_char	char(2);

define _dia_int		smallint;
define _mes_int		smallint;
define _ano_int		smallint;

let _dia_char = a_fecha[1,2];
let _mes_char = a_fecha[4,6];
let _ano_char = a_fecha[8,9];

if _mes_char = "JAN" then
	let _mes_int = 1;
elif _mes_char = "FEB" then
	let _mes_int = 2;
elif _mes_char = "MAR" then
	let _mes_int = 3;
elif _mes_char = "APR" then
	let _mes_int = 4;
elif _mes_char = "MAY" then
	let _mes_int = 5;
elif _mes_char = "JUN" then
	let _mes_int = 6;
elif _mes_char = "JUL" then
	let _mes_int = 7;
elif _mes_char = "AUG" then
	let _mes_int = 8;
elif _mes_char = "SEP" then
	let _mes_int = 9;
elif _mes_char = "OCT" then
	let _mes_int = 10;
elif _mes_char = "NOV" then
	let _mes_int = 11;
elif _mes_char = "DEC" then
	let _mes_int = 12;
end if

let _dia_int = _dia_char;
let _ano_int = _ano_char;
let _ano_int = _ano_int + 1900;

let _fecha = mdy(_mes_int, _dia_int, _ano_int);

return _fecha;

end procedure
