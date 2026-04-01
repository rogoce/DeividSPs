-- Crea los registros en saldos y periodos hasta el 2020

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac17;

create procedure "informix".sp_sac17()

define _mes_int		smallint;
define _ano_int		smallint;
define _descripcion	char(50);
define _mes_char	char(2);
define _ano_char	char(4);
define _periodo		char(7);

define _fecha_ini	date;
define _fecha_fin	date;

for _ano_int = 2005 to 2020

	let _ano_char = _ano_int;

	for _mes_int = 1 to 14

		if _mes_int < 10 then
			let _mes_char = "0" || _mes_int;
		else
			let _mes_char = _mes_int;
		end if

		if _mes_int in (13, 14) then
	
			let _fecha_ini = mdy(1, 1, _ano_int);
			let _fecha_fin = mdy(12, 31, _ano_int);

		else

			let _fecha_ini = mdy(_mes_int, 1, _ano_int);
			let _periodo   = _ano_char || "-" || _mes_char;
			let _fecha_fin = sp_sis36(_periodo);

		end if

		let _descripcion = trim(sp_sac18(_mes_int)) || " DEL " || _ano_char;

		insert into cglperiodo
		values(
		_ano_char,
		_mes_char,
		_descripcion,
		_fecha_ini,
		_fecha_fin,
		"A",
		"N"
		);

	end for

end for

update cglperiodo
   set per_status1 = "A"
 where per_mes     = "13";

update cglperiodo
   set per_status1 = "C"
 where per_mes     = "14";

end procedure