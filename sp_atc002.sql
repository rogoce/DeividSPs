
drop procedure sp_atc002;

create procedure "informix".sp_atc002()
returning smallint;

define _fecha_inicio	datetime year to minute;
define _fecha_fin		datetime year to minute;
define _ano				smallint;
define _mes				smallint;
define _dia				smallint;

define _loop			integer;
define _i				integer;

delete from atcfecha;

let _fecha_inicio 	= to_date("13-09-2006 00:01", "%d-%m-%Y %H:%M");
let _fecha_fin	  	= to_date("13-09-2006 23:59", "%d-%m-%Y %H:%M");

let _loop = 365 * 20;

for _i = 1 to _loop

	let _fecha_inicio 	= _fecha_inicio + 1 units day;
	let _fecha_fin		= _fecha_fin    + 1 units day;
	let _ano			= year(_fecha_inicio);
	let _mes			= month(_fecha_inicio);
	let _dia			= day(_fecha_inicio);

	insert into atcfecha
	values (_fecha_inicio, _fecha_fin, _ano, _mes, _dia);

end for

return 0;

end procedure