-- Procedimiento que retorna la cantidad de registros a procesar
-- Creado : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 23/03/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas058;
create procedure sp_cas058(a_cia char(3), a_usuario char(8))
returning	smallint,
			smallint,
			smallint,
			smallint,
			smallint,
			date,
			char(50),
			char(50),
			char(3),
			char(10),
			char(50),
			smallint;

define _compania_nombre		char(50);
define _nombre_campana		char(50);
define _nombre_gestor		char(50);
define _cod_campana			char(10);
define _cod_supervisor		char(3);
define _cod_cobrador		char(3);
define _pendientes			smallint; 
define _atendidos			smallint; 
define _atrazados			smallint;
define _nuevos				smallint;
define _extra				smallint;
define _total				smallint; 
define _fecha				date;

set isolation to dirty read;
let  _compania_nombre = sp_sis01(a_cia);
let _cod_supervisor = '';

create temp table temp_supervisor(
cod_supervisor		char(3)) with no log;

foreach
	select cod_cobrador
	  into _cod_supervisor
	  from cobcobra
	 where usuario = a_usuario
	   and tipo_cobrador in (8,9)
	
	insert into temp_supervisor(cod_supervisor)
	values(_cod_supervisor);
end foreach

foreach
	select fecha_ult_pro,
		   nombre,
		   cod_cobrador,
		   cod_campana
	  into _fecha,
	       _nombre_gestor,
		   _cod_cobrador,
		   _cod_campana
	  from cobcobra
	 where tipo_cobrador in (1,4,5,8,11,12)
	   and cod_supervisor in (select cod_supervisor from temp_supervisor)
	   and activo = 1

	--let _fecha = '17/03/2015';

	select total, 
		   atendidos, 
		   pendientes, 
		   nuevos, 
		   atrazados,
		   extra
	  into _total, 
		   _atendidos, 
		   _pendientes, 
		   _nuevos, 
		   _atrazados,
		   _extra
	  from cobcadate
	 where cod_cobrador = _cod_cobrador
	   and fecha = _fecha;

	if _total is null then
		let _total = 0;
	end if

	if _atendidos is null then
		let _atendidos = 0;
	end if

	if _pendientes is null then
		let _pendientes = 0;
	end if

	if _atrazados is null then
		let _atrazados = 0;
	end if

	if _nuevos is null then
		let _nuevos = 0;
	end if

	if _extra is null then
		let _extra = 0;
	end if

	if _cod_campana <> '00000' then
		select nombre
		  into _nombre_campana
		  from cascampana
		 where cod_campana = _cod_campana;

		select count(*)
		  into _pendientes
		  from cascliente
		 where cod_campana = _cod_campana
		   and cod_gestion is null;
	else
		let _nombre_campana = 'SIN CAMPAÑA'; 
	end if

	return	_total, 
			_atendidos, 
			_pendientes, 
			_nuevos, 
			_atrazados,
			_fecha,
			_nombre_gestor,
			_compania_nombre,
			a_cia,
			_cod_campana,
			_nombre_campana,
			_extra	with resume;
end foreach

drop table temp_supervisor;
end procedure;