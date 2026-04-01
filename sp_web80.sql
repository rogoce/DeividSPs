-- Procedimiento que verifica si el motor y chasis son iguales se bloquea.
-- Creado     :	24/02/2026 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web80;		
create procedure "informix".sp_web80(a_no_motor char(30), a_usuario CHAR(8), a_cod_producto char(10))
returning char(7);
		  
define _no_chasis			char(30);
define _fecha_bloqueo       date;
define _fecha_libera        date;
define _return              smallint;
define _preguntar_suma      smallint;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_web80.trc";
--TRACE ON;

	let _return = 0;

	select preguntar_suma
	  into _preguntar_suma
	  from prdprod
	where cod_producto = a_cod_producto;

	if _preguntar_suma = 1 then
		select no_chasis
		  into _no_chasis
		  from deivid:emivehic
		 where no_motor = a_no_motor;
		  
		if trim(_no_chasis) = trim(a_no_motor) then
			select max(date(fecha_bloqueo)), 
				   max(date(fecha_libera))
			  into _fecha_bloqueo, _fecha_libera
			  from deivid:emivebit
			 where no_motor = a_no_motor;
			 
			 if _fecha_bloqueo is null or _fecha_bloqueo = '' then
				let _return = 1;
				update emivehic 
				   set bloqueado = 1,
					   cod_mala_ref = '004'
				 where no_motor = a_no_motor;
				 
				insert into emivebit (no_motor, bloqueado, user_bloqueo, cod_mala_ref, fecha_bloqueo)
							  values (a_no_motor, 1, a_usuario, '004', current);
			 else
				if _fecha_libera is not null or _fecha_libera <> '' then
					if _fecha_bloqueo > _fecha_libera then
						let _return = 1;
					end if
				else
					let _return = 1;
				end if
			 end if
		end if
	end if
	return _return;
end procedure 