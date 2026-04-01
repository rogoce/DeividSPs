-- Procedimiento que determina los días pendientes por procesar para T
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob339b;
create procedure "informix".sp_cob339b() 
returning	smallint,
			char(100);
			
define _motivo_rechazo	varchar(50);
define _error_desc		char(100);
define _nombre			char(100);
define _no_documento	char(20);
define _no_cuenta		char(17);
define _cod_pagador		char(10);
define _fecha_exp		char(7);
define _cod_banco		char(3);
define _tipo_cuenta		char(1);
define _modificado		char(1);
define _monto			dec(16,2);
define _cargo_especial	dec(16,2);
define _dia_especial	smallint;
define _cnt_cobcutas	smallint;
define _cnt_rechazo		smallint;
define _cnt_existe		smallint;
define _excepcion		smallint;
define _rechazada		smallint;
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
no_cuenta		char(17),
monto			dec(16,2),
cargo_especial	dec(16,2),
cod_pagador		char(10),
no_documento	char(20),
nombre			char(100),
cod_banco		char(3),
excepcion		smallint,
tipo_cuenta		char(1),
rechazada		smallint,
modificado		char(1),
dia				smallint,
dia_especial	smallint,
fecha_hasta		date,
fecha_inicio	date) with no log;

foreach
	select h.no_cuenta,
		   c.monto,
		   c.cargo_especial,
		   c.no_documento,
		   h.cod_pagador,
		   h.cod_banco,
		   h.tipo_cuenta,
		   c.rechazada,
		   c.excepcion,
		   c.modificado,
		   c.dia,
		   c.dia_especial,
		   c.fecha_hasta,
		   c.fecha_inicio
	  into _no_cuenta,
		   _monto,
		   _cargo_especial,
		   _no_documento,
		   _cod_pagador,
		   _cod_banco,
		   _tipo_cuenta,
		   _rechazada,
		   _excepcion,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)
	   and (c.dia in (select dia from tmp_dias_proceso) or c.dia_especial in (select dia from tmp_dias_proceso))
	
	insert into tmp_procesar(
			no_cuenta,
			monto,
			cargo_especial,
			cod_pagador,
			no_documento,
			cod_banco,
			excepcion,
			tipo_cuenta,
			rechazada,
			modificado,
			dia,
			dia_especial,
			fecha_hasta,
			fecha_inicio)
	values(	_no_cuenta,
			_monto,
			_cargo_especial,
			_cod_pagador,
			_no_documento,
			_cod_banco,
			_excepcion,
			_tipo_cuenta,
			_rechazada,
			_modificado,
			_dia,
			_dia_especial,
			_fecha_hasta,
			_fecha_inicio);
end foreach

foreach
	select h.no_cuenta,
		   c.monto,
		   c.cargo_especial,
		   h.cod_pagador,
		   h.cod_banco,
		   c.excepcion,
		   h.tipo_cuenta,
		   c.rechazada,
		   c.modificado,
		   c.dia,
		   c.dia_especial,
		   c.fecha_hasta,
		   c.fecha_inicio,
		   c.no_documento,
		   c.cnt_rechazo
	  into _no_cuenta,
		   _monto,
		   _cargo_especial,
		   _cod_pagador,
		   _cod_banco,
		   _excepcion,
		   _tipo_cuenta,
		   _rechazada,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio,
		   _no_documento,
		   _cnt_rechazo
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)
	   and c.rechazada = 1
	
	if _cnt_rechazo >= 3 then
		update cobcutas
		   set rechazada = 0,
			   cnt_rechazo = 0
		 where no_cuenta = _no_cuenta
		   and no_documento = _no_documento;
		
		update cobcuhab
		   set rechazada = 0
		 where no_cuenta = _no_cuenta;
		
		continue foreach;
	end if
	
	select count(*)
	  into _cnt_existe
	  from tmp_procesar
	 where no_cuenta   = _no_cuenta
	   and no_documento = _no_documento;
		
	select count(*)
	  into _cnt_cobcutas
	  from cobcutas
	 where no_cuenta = _no_cuenta
	   and no_documento = _no_documento;
	
	if _cnt_cobcutas is null then
		let _cnt_cobcutas = 0;
	end if
	
	if _cnt_cobcutas = 0 then
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
				no_cuenta,
				monto,
				cargo_especial,
				cod_pagador,
				no_documento,
				cod_banco,
				excepcion,
				tipo_cuenta,
				rechazada,
				modificado,
				dia,
				dia_especial,
				fecha_hasta,
				fecha_inicio)
		values(	_no_cuenta,
				_monto,
				_cargo_especial,
				_cod_pagador,
				_no_documento,
				_cod_banco,
				_excepcion,
				_tipo_cuenta,
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