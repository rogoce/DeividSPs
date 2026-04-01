-- procedimiento que trae todos los correos de un cliente.
-- creado    : 27/12/2011 - Autor: Roman Gordon

drop procedure sp_wc01;
create procedure "informix".sp_wc01() 
returning	smallint,
			char(50);

define _error_desc		char(50);
define _equipo_a		char(30);
define _equipo_b		char(30);
define _wildcard		char(30);
define _juego_a			smallint;
define _juego_b			smallint;
define _juego_w			smallint;
define _cnt				smallint;
define _error			integer;
define _error_isam		integer;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception


set isolation to dirty read;
--set debug file to "sp_par310.trc"; 
--trace on;

let _cnt = 0;
foreach
	select no_juego,
		   equipo_a
	  into _juego_a,
		   _equipo_a
	  from calendar_wc

	let _cnt = _cnt + 1;

	foreach
		select no_juego,
			   equipo_b
		  into _juego_b,
			   _equipo_b
		  from calendar_wc
		 where no_juego <> _juego_a

		insert into permut_wc(escenario,resultados,juego)
		values(_cnt,_equipo_a,_juego_a);

		foreach
			select no_juego,
				   wildcard
			  into _juego_w,
				   _wildcard
			  from calendar_wc
			 where no_juego not in (_juego_a,_juego_b)

			insert into permut_wc(escenario,resultados,juego)
			values(_cnt,_wildcard,_juego_w);
		end foreach

		insert into permut_wc(escenario,resultados,juego)
		values(_cnt,_equipo_b,_juego_b);
		let _cnt = _cnt + 1;

		
	end foreach
end foreach

return 0,'Exito';
end procedure;