-- Reporte de Póliza con fecha de cobro menor al inicio de la vigencia
-- Creado    : 19/07/2018 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob415;
create procedure "informix".sp_cob415(a_fecha_desde date, a_dias smallint,a_proceso char(3))
returning	char(19)		as documento,
            char(7)			as fecha_exp,
			varchar(100)	as tarjetahabiente,
			char(20)		as poliza,
			date			as vigencia_inic,
			date			as vigencia_final,
			date			as fecha_ult_pro,
			smallint		as dia_cobro,
			dec(16,2)		as monto_letra,
			dec(16,2)		as saldo,
			smallint		as rechazada,
			date			as fecha_cobro;

define _nom_cliente		varchar(100);
define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _no_cuenta		char(17);
define _fecha_exp		char(7);
define _monto_letra		dec(16,2);
define _saldo           dec(16,2);
define _error_code      smallint;
define _error_isam      smallint;
define _dia_pivote		smallint;
define _dia_desde		smallint;
define _dia_hasta		smallint;
define _rechazada		smallint;
define _dia_cobro		smallint;
define _anio_hoy		smallint;
define _anio_sig		smallint;
define _lim_vig			smallint;
define _dia_hoy			smallint;
define _mes_hoy			smallint;
define _mes_sig			smallint;
define _vigencia_final	date;
define _vigencia_inic	date;
define _fecha_ult_tran	date;
define _fecha_cobro		date;
define _fecha_hoy		date;

--set debug file to "sp_cob415.trc"; 
--trace on;

begin
on exception set _error_code,_error_isam,_error_desc 
 	return	'',
			'',
			_error_desc,
			'',
			null,
			null,
			null,
			_error_code,
			_error_isam,
			0.00,
			0,
			null;
end exception

let _lim_vig = 30;
--let _fecha_hoy = current;
let _dia_desde = day(a_fecha_desde);
let _dia_hasta = day(a_fecha_desde + a_dias units day);
let _anio_hoy = year(a_fecha_desde);
let _mes_hoy = month(a_fecha_desde);
let _dia_hoy = day(a_fecha_desde);
let _anio_sig = _anio_hoy;

if _mes_hoy = 12 then -- en el siguiente mes hay cambio de año
	let _mes_sig = 1;
	let _anio_sig = _anio_sig + 1;
else
	let _mes_sig = _mes_hoy + 1;
end if

if a_proceso = 'TCR' then
	foreach
		select t.no_tarjeta,
			   e.fecha_exp,
			   t.dia,
			   t.nombre,
			   t.no_documento,
			   e.vigencia_inic,
			   e.vigencia_fin,
			   t.fecha_ult_tran,
			   t.monto,
			   e.saldo,
			   t.rechazada
		  into _no_tarjeta,
			   _fecha_exp,
			   _dia_cobro,
			   _nom_cliente,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_ult_tran,
			   _monto_letra,
			   _saldo,
			   _rechazada		   
		  from cobtacre t, emipoliza e
		 where t.no_documento = e.no_documento
		   and e.vigencia_inic > a_fecha_desde
		   and (e.vigencia_inic - a_fecha_desde) < _lim_vig	--la vigencia inicia en los proximos dias
		   and ((_dia_hasta < _dia_hoy and (dia <= _dia_hasta or dia >= _dia_desde)) or (_dia_hasta > _dia_hoy and (dia >= _dia_desde and dia <= _dia_hasta))) -- Si hay cambio de mes se debe cambiar el orden de los dias a buscar
		   and exigible = 0.00

		if _dia_cobro < _dia_hoy then --El día de cobro pertenece al siguiente mes
			let _fecha_cobro = mdy(_mes_sig,_dia_cobro,_anio_sig); --se coloca el mes y año del del siguiente mes como fecha de cobro
		else
			let _fecha_cobro = mdy(_mes_hoy,_dia_cobro,_anio_hoy);
		end if

		if _vigencia_inic <= _fecha_cobro then --si el inicio de la vigencia es antes de fecha de cobro no se debe mostrar en el reporte
			continue foreach;
		end if

		return	_no_tarjeta,
				_fecha_exp,
				_nom_cliente,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_fecha_ult_tran,
				_dia_cobro,
				_monto_letra,
				_saldo,
				_rechazada,
				_fecha_cobro
		with resume;
	end foreach
elif a_proceso = 'ACH' then
	foreach
		select t.no_cuenta,
			   t.dia,
			   t.nombre,
			   t.no_documento,
			   e.vigencia_inic,
			   e.vigencia_fin,
			   t.fecha_ult_tran,
			   t.monto,
			   e.saldo,
			   t.rechazada
		  into _no_cuenta,
			   _dia_cobro,
			   _nom_cliente,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_ult_tran,
			   _monto_letra,
			   _saldo,
			   _rechazada		   
		  from cobcutas t, emipoliza e
		 where t.no_documento = e.no_documento
		   and e.vigencia_inic > a_fecha_desde
		   and (e.vigencia_inic - a_fecha_desde) < _lim_vig	--la vigencia inicia en los proximos dias
		   and ((_dia_hasta < _dia_hoy and (dia <= _dia_hasta or dia >= _dia_desde)) or (_dia_hasta > _dia_hoy and (dia >= _dia_desde and dia <= _dia_hasta))) -- Si hay cambio de mes se debe cambiar el orden de los dias a buscar
		   and exigible = 0.00

		if _dia_cobro < _dia_hoy then --El día de cobro pertenece al siguiente mes
			let _fecha_cobro = mdy(_mes_sig,_dia_cobro,_anio_sig); --se coloca el mes y año del del siguiente mes como fecha de cobro
		else
			let _fecha_cobro = mdy(_mes_hoy,_dia_cobro,_anio_hoy);
		end if

		if _vigencia_inic <= _fecha_cobro then --si el inicio de la vigencia es antes de fecha de cobro no se debe mostrar en el reporte
			continue foreach;
		end if

		return	_no_cuenta,
				'',
				_nom_cliente,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_fecha_ult_tran,
				_dia_cobro,
				_monto_letra,
				_saldo,
				_rechazada,
				_fecha_cobro
		with resume;
	end foreach
end if
end
end procedure;