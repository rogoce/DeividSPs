-- Procedimiento que determina los días pendientes por procesar para T
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob338;
create procedure "informix".sp_cob338(a_proceso char(3),a_fecha_proceso date) 
returning	smallint,
			char(100);
			
define _error_desc	 		char(100);
define _dia_ult_proceso		smallint;
define _procesado			smallint;
define _mes_hoy				smallint;
define _dia_hoy				smallint;
define _error_code      	integer;
define _error_isam			integer;
define _fecha_ult_proceso	date;
define _fecha_siguiente		date;

set isolation to dirty read;

--set debug file to "sp_cob338.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
	drop table tmp_dias_proceso;
 	return _error_code,_error_desc;
end exception

create temp table tmp_dias_proceso(
	dia		smallint
) with no log;

if a_proceso = 'TCR' then
	update cobfectar
	   set procesado = 0
	 where procesado = 2;
	 
	select procesado
	  into _procesado
	  from cobfectar
	 where fecha = a_fecha_proceso;

	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if
	
	select min(fecha)
	  into _fecha_ult_proceso
	  from cobfectar
	 where procesado = 0;
	
	update cobfectar
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
elif a_proceso = 'ACH' then
	
	update cobfecach
	   set procesado = 0
	 where procesado = 2;
	
	select procesado
	  into _procesado
	  from cobfecach
	 where fecha = a_fecha_proceso;

	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if
	
	select min(fecha)
	  into _fecha_ult_proceso
	  from cobfecach
	 where procesado = 0;
	 
	update cobfecach
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
elif a_proceso = 'AME' then
	
	update cobfectam
	   set procesado = 0
	 where procesado = 2;
	
	select procesado
	  into _procesado
	  from cobfectam
	 where fecha = a_fecha_proceso;

	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if
	
	select min(fecha)
	  into _fecha_ult_proceso
	  from cobfectam
	 where procesado = 0;
	
	update cobfectam
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
else
	drop table tmp_dias_proceso;
	let _error_desc = 'El Proceso seleccionado no es Valido. Por Favor Verifique';
	return -1,_error_desc;
end if

let _dia_hoy = day(a_fecha_proceso);
let _mes_hoy = month(a_fecha_proceso);
let _dia_ult_proceso = day(_fecha_ult_proceso);

if _dia_hoy >= 28 and _mes_hoy = 2 then
	let _fecha_siguiente = a_fecha_proceso + 1 units day;
	
	if day(_fecha_siguiente) <> 29 then	
		let _dia_hoy = 31;
	end if
elif _dia_hoy >= 30 and _mes_hoy <> 2 then
	let _fecha_siguiente = a_fecha_proceso + 1 units day;
	if day(_fecha_siguiente) <> 31 then
		let _dia_hoy = day(_fecha_siguiente);
		
		if day(_fecha_siguiente) <> 31 then	
			let _dia_hoy = 31;
		end if
	end if
end if

insert into tmp_dias_proceso
values(_dia_ult_proceso);
	
while _dia_ult_proceso <> _dia_hoy
	
	if _dia_ult_proceso > 30 then
		let _dia_ult_proceso = 0;
	end if
	
	let _dia_ult_proceso = _dia_ult_proceso + 1 ;
	
	insert into tmp_dias_proceso
	values(_dia_ult_proceso);
end while

return 0,'Proceso Finalizado';

--drop table tmp_dias_proceso;
end
end procedure 