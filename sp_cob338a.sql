-- Procedimiento que determina los días pendientes por procesar para TCR, American y ACH (SOLO PARA REPORTE, NO ACTUALIZA LA INFORMACIÓN)
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob338a;
create procedure "informix".sp_cob338a(a_proceso char(3),a_fecha_proceso date) 
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

--set debug file to "sp_cob338a.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
	drop table if exists tmp_dias_proceso;
	drop table if exists tmp_cobfectar;
	drop table if exists tmp_cobfecach;
	drop table if exists tmp_cobfectam;
 	return _error_code,_error_desc;
end exception

--Borrar las tablas temporales para realizar el proceso desde 0.
drop table if exists tmp_dias_proceso;
drop table if exists tmp_cobfectar;
drop table if exists tmp_cobfecach;
drop table if exists tmp_cobfectam;

--Crea la tabla temporal que contendra los días que se van a procesar.
create temp table tmp_dias_proceso(dia smallint) with no log;

if a_proceso = 'TCR' then
	--Crea la tabla temporal con la tabla física para no interferir con los procesos reales de cobros.
	select *
	  from cobfectar
	  into temp tmp_cobfectar;

	--Inicializa los registros en estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	--Los registros con estatus 2 son los que están siendo procesados pero no han sido enviados al banco
	update tmp_cobfectar
	   set procesado = 0
	 where procesado = 2;

	--Verifica que el día que se quiere procesar no haya sido procesado anteriorment.
	select procesado
	  into _procesado
	  from tmp_cobfectar
	 where fecha = a_fecha_proceso;

	--Si el día ya fue procesado no puede ser procesado nuevamente.
	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if
	
	-- Selecciona la fecha más antigua que no haya sido procesada.
	select min(fecha)
	  into _fecha_ult_proceso
	  from tmp_cobfectar
	 where procesado = 0;

	--Actualiza los registros que se van a procesar al estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	update tmp_cobfectar
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
elif a_proceso = 'ACH' then

	--Crea la tabla temporal con la tabla física para no interferir con los procesos reales de cobros.
	select *
	  from cobfecach
	  into temp tmp_cobfecach;

	--Inicializa los registros en estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	--Los registros con estatus 2 son los que están siendo procesados pero no han sido enviados al banco
	update tmp_cobfecach
	   set procesado = 0
	 where procesado = 2;
	
	--Verifica que el día que se quiere procesar no haya sido procesado anteriorment.
	select procesado
	  into _procesado
	  from tmp_cobfecach
	 where fecha = a_fecha_proceso;

	--Si el día ya fue procesado no puede ser procesado nuevamente.
	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if

	--Selecciona la fecha más antigua que no haya sido procesada.
	select min(fecha)
	  into _fecha_ult_proceso
	  from tmp_cobfecach
	 where procesado = 0;

	--Actualiza los registros que se van a procesar al estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	update tmp_cobfecach
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
elif a_proceso = 'AME' then

	--Crea la tabla temporal con la tabla física para no interferir con los procesos reales de cobros.
	select *
	  from cobfectam
	  into temp tmp_cobfectam;

	--Inicializa los registros en estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	--Los registros con estatus 2 son los que están siendo procesados pero no han sido enviados al banco
	update tmp_cobfectam
	   set procesado = 0
	 where procesado = 2;

	--Verifica que el día que se quiere procesar no haya sido procesado anteriorment.
	select procesado
	  into _procesado
	  from tmp_cobfectam
	 where fecha = a_fecha_proceso;

	--Si el día ya fue procesado no puede ser procesado nuevamente.
	if _procesado = 1 then
		drop table tmp_dias_proceso;
		return 1,'El día escogido ya fue procesado. Verifique';
	end if

	--Selecciona la fecha más antigua que no haya sido procesada.
	select min(fecha)
	  into _fecha_ult_proceso
	  from tmp_cobfectam
	 where procesado = 0;

	--Actualiza los registros que se van a procesar al estatus 2, que es un estado transitorio hasta que se actualice la Remesa.
	update tmp_cobfectam
	   set procesado = 2,
	       fecha_procesado = today
	 where fecha between _fecha_ult_proceso and a_fecha_proceso;
else --No reconoce el  código del proceso que se quiere trabajar.
	drop table tmp_dias_proceso;
	let _error_desc = 'El Proceso seleccionado no es Valido. Por Favor Verifique';
	return -1,_error_desc;
end if

--Extrae el día de la fecha que se quiere procesar
let _dia_hoy = day(a_fecha_proceso);
--Extrae el mes de la fecha que se quiere procesar
let _mes_hoy = month(a_fecha_proceso);
--Extrae el día de la fecha más antigua sin procesar
let _dia_ult_proceso = day(_fecha_ult_proceso);

--Verifica si el día que se quiere procesar es el 28/2 para tomar en cuenta los días del 29 al 31
if _dia_hoy >= 28 and _mes_hoy = 2 then

	--Determina el día siguiente al último día que se quiere procesar
	let _fecha_siguiente = a_fecha_proceso + 1 units day;

	--Si el día siguiente pertence al mes siguiente se deben procesar los días del 29 al 31
	if day(_fecha_siguiente) <> 29 then	
		let _dia_hoy = 31;
	end if
elif _dia_hoy >= 30 and _mes_hoy <> 2 then

	--Determina el día siguiente al último día que se quiere procesar
	let _fecha_siguiente = a_fecha_proceso + 1 units day;
	let _dia_hoy = day(_fecha_siguiente);
	
	--Si el mes del día que se quiere procesar no tiene 31 días entonces se debe insertar el día 31
	if day(_fecha_siguiente) <> 31 then	
		let _dia_hoy = 31;
	end if
end if

insert into tmp_dias_proceso
values(_dia_ult_proceso);

--Proceso que determina los días que hay entre el días más antiguo sin procesar y el día que se quiere procesar
while _dia_ult_proceso <> _dia_hoy

	--Si el contrador sobrepasa el 30 se debe inicializar.
	if _dia_ult_proceso > 30 then
		let _dia_ult_proceso = 0;
	end if

	--Se aumenta el contador en 1 para insertar el día
	let _dia_ult_proceso = _dia_ult_proceso + 1 ;

	--Se inserta en la tabla temporal el día que se procesara.
	insert into tmp_dias_proceso
	values(_dia_ult_proceso);
end while

return 0,'Proceso Finalizado';
end
end procedure;