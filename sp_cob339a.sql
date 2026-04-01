-- Procedimiento que determina los días pendientes por procesar para T
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob339a;
create procedure "informix".sp_cob339a() 
returning	smallint,
			char(100);
			
define _motivo_rechazo	varchar(50);
define _error_desc		char(100);
define _nombre			char(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _fecha_exp		char(7);
define _cod_banco		char(3);
define _tipo_tarjeta	char(1);
define _modificado		char(1);
define _monto			dec(16,2);
define _cargo_especial	dec(16,2);
define _dia_especial	smallint;
define _cnt_existe		smallint;
define _excepcion		smallint;
define _rechazada		smallint;
define _cnt_cobtacre	smallint;
define _dia				smallint;
define _error_code		integer;
define _error_isam		integer;
define _fecha_inicio	date;
define _fecha_hasta		date;

set isolation to dirty read;

--set debug file to "sp_cob339.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
	drop table tmp_procesar;
	drop table tmp_dias_proceso;
 	return _error_code,_error_desc;
end exception

create temp table tmp_procesar(
	no_tarjeta		char(19),
	monto			dec(16,2),
	cargo_especial	dec(16,2),
	fecha_exp		char(7),
	no_documento	char(20),
	nombre			char(100),
	cod_banco		char(3),
	excepcion		smallint,
	tipo_tarjeta	char(1),
	rechazada		smallint,
	modificado		char(1),
	dia				smallint,
	dia_especial	smallint,
	fecha_hasta		date,
	fecha_inicio	date) with no log;

foreach
	select h.no_tarjeta,
		   c.monto,
		   c.cargo_especial,
		   h.fecha_exp,
		   c.no_documento,
		   h.nombre,
		   h.cod_banco,
		   c.excepcion,
		   h.tipo_tarjeta,
		   c.rechazada,
		   c.modificado,
		   c.dia,
		   c.dia_especial,
		   c.fecha_hasta,
		   c.fecha_inicio
	  into _no_tarjeta,
		   _monto,
		   _cargo_especial,
		   _fecha_exp,
		   _no_documento,
		   _nombre,
		   _cod_banco,
		   _excepcion,
		   _tipo_tarjeta,
		   _rechazada,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio
	  from cobtacre c, cobtahab h
	 where c.no_tarjeta = h.no_tarjeta
	   and h.tipo_tarjeta = "4"
	   and (c.dia in (select dia from tmp_dias_proceso) or c.dia_especial in (select dia from tmp_dias_proceso))
	
	insert into tmp_procesar(
			no_tarjeta,
			monto,
			cargo_especial,
			fecha_exp,
			no_documento,
			nombre,
			cod_banco,
			excepcion,
			tipo_tarjeta,
			rechazada,
			modificado,
			dia,
			dia_especial,
			fecha_hasta,
			fecha_inicio)
	values(	_no_tarjeta,
			_monto,
			_cargo_especial,
			_fecha_exp,
			_no_documento,
			_nombre,
			_cod_banco,
			_excepcion,
			_tipo_tarjeta,
			_rechazada,
			_modificado,
			_dia,
			_dia_especial,
			_fecha_hasta,
			_fecha_inicio);
end foreach

foreach
	select c.monto,
		   c.cargo_especial,
		   h.fecha_exp,
		   h.nombre,
		   h.cod_banco,
		   c.excepcion,
		   h.tipo_tarjeta,
		   c.rechazada,
		   c.modificado,
		   c.dia,
		   c.dia_especial,
		   c.fecha_hasta,
		   c.fecha_inicio,
		   c.no_tarjeta,
		   c.no_documento
	  into _monto,
		   _cargo_especial,
		   _fecha_exp,
		   _nombre,
		   _cod_banco,
		   _excepcion,
		   _tipo_tarjeta,
		   _rechazada,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio,
		   _no_tarjeta,
		   _no_documento
	  from cobtacre c, cobtahab h
	 where c.no_tarjeta = h.no_tarjeta
	   and h.tipo_tarjeta = "4"
	   and c.rechazada    = 1
	
	select count(*)
	  into _cnt_existe
	  from tmp_procesar
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;
	
	if _no_tarjeta is null or _no_tarjeta = '' then
		return 1,_no_documento with resume;
		--continue foreach;
	end if
	
	select count(*)
	  into _cnt_cobtacre
	  from cobtacre
	 where no_tarjeta = _no_tarjeta
	   and no_documento = _no_documento;
	
	if _cnt_cobtacre is null then
		let _cnt_cobtacre = 0;
	end if
	
	if _cnt_cobtacre = 0 then
		continue foreach;
	end if
	
	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if
	
	foreach
		select dia
		  into _dia
		  from tmp_dias_proceso
		exit foreach;
	end foreach
	
	if _cnt_existe = 0 then
		insert into tmp_procesar(
				no_tarjeta,
				monto,
				cargo_especial,
				fecha_exp,
				no_documento,
				nombre,
				cod_banco,
				excepcion,
				tipo_tarjeta,
				rechazada,
				modificado,
				dia,
				dia_especial,
				fecha_hasta,
				fecha_inicio)
		values(	_no_tarjeta,
				_monto,
				_cargo_especial,
				_fecha_exp,
				_no_documento,
				_nombre,
				_cod_banco,
				_excepcion,
				_tipo_tarjeta,
				_rechazada,
				_modificado,
				_dia,
				_dia_especial,
				_fecha_hasta,
				_fecha_inicio);
	end if
end foreach

return 0,'Carga Exitosa';
end
end procedure;