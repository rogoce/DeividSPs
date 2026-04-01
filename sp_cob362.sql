-- Estadística de pólizas renovadas con saldo en la vigencia anterior
-- Creado    : 15/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob362;
create procedure sp_cob362(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	char(20)	as Poliza,
			varchar(10)	as Estatus_Poliza,
			varchar(50)	as Ramo,
			varchar(50)	as Forma_de_Pago,
			date		as Vigencia_Inicial,
			date		as Vigencia_Final,
			date		as Fecha_Renovacion,
			dec(16,2)	as Prima_Bruta_Actual,
			dec(16,2)	as Prima_Bruta_Anterior,
			dec(16,2)	as Por_Vencer,
			dec(16,2)	as Exigible,
			dec(16,2)	as Corriente,
			dec(16,2)	as Monto30,
			dec(16,2)	as Monto60,
			dec(16,2)	as Monto90,
			dec(16,2)	as Saldo,
			dec(16,2)	as Saldo_Anterior,
			dec(16,2)	as Porcentaje_Saldo,
			varchar(50)	as Corredor;

define _error_desc			varchar(100);
define _nom_formapag		varchar(50);
define _nom_agente			varchar(50);
define _nom_ramo			varchar(50);
define _estatus				varchar(10);
define _no_documento		char(20);
define _no_poliza_ant		char(10);
define _no_poliza			char(10);
define _periodo_actual		char(7);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_ramo			char(3);
define _prima_bruta_ant		dec(16,2);
define _por_vencer_r		dec(16,2);
define _corriente_r			dec(16,2);
define _prima_bruta			dec(16,2);
define _monto_180_r			dec(16,2);
define _monto_150_r			dec(16,2);
define _monto_120_r			dec(16,2);
define _monto_90_r			dec(16,2);
define _monto_60_r			dec(16,2);
define _monto_30_r			dec(16,2);
define _exigible_r			dec(16,2);
define _porc_saldo			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _saldo_r				dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_renovacion	date;
define _fecha_impresion		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _fecha_hoy			date;

--set debug file to "sp_cob362.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	rollback work;
	drop table tmp_datos;
	return _no_documento,'','','','01/01/1900','01/01/1900','01/01/1900',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,_error,_error_isam,0.00,_error_desc;
end exception

let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

let _fecha_hoy = current;
let _periodo_actual = sp_sis39(_fecha_hoy);

drop table if exists tmp_datos;
create temp table tmp_datos(
no_documento	char(20),
no_poliza		char(10),
cod_formapag	char(3),
cod_ramo		char(3),
estatus_poliza	smallint,
saldo			dec(16,2),
vigencia_inic	date,
vigencia_final	date,
fecha_impresion	date) with no log;

foreach with hold
	select no_documento,
		   max(no_poliza)
	  into _no_documento,
		   _no_poliza
	  from emipomae
	 where nueva_renov = 'R'
	   and fecha_impresion >= _fecha_desde
	   and fecha_impresion <= _fecha_hasta
	   and actualizado = 1
	 group by 1
	 order by 1

	begin work;

	select estatus_poliza,
		   cod_ramo,
		   cod_formapag,
		   vigencia_inic,
		   vigencia_final,
		   fecha_impresion
	  into _estatus_poliza,
		   _cod_ramo,
		   _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_impresion
	  from emipomae
	 where no_poliza = _no_poliza;

	let _fecha_renovacion = _fecha_impresion - 1 units day;
	let _periodo = sp_sis39(_fecha_renovacion);

	call sp_cob33d('001','001', _no_documento, _periodo, _fecha_renovacion)
	returning   _por_vencer_r,
				_exigible_r,
				_corriente_r,
				_monto_30_r,
				_monto_60_r,
				_monto_90_r,
				_saldo_r;

	if _saldo_r <= 0 then
		commit work;
		continue foreach;
	end if

	insert into tmp_datos(
			no_documento,
			no_poliza,
			cod_formapag,
			cod_ramo,
			estatus_poliza,
			saldo,
			vigencia_inic,
			vigencia_final,
			fecha_impresion)
	values(	_no_documento,
			_no_poliza,
			_cod_formapag,
			_cod_ramo,
			_estatus_poliza,
			_saldo_r,
			_vigencia_inic,
			_vigencia_final,
			_fecha_impresion);
	commit work;
end foreach

begin work;

foreach
	select no_documento,
		   no_poliza,
		   cod_formapag,
		   cod_ramo,
		   estatus_poliza,
		   saldo,
		   vigencia_inic,
		   vigencia_final,
		   fecha_impresion
	  into _no_documento,
		   _no_poliza,
		   _cod_formapag,
		   _cod_ramo,
		   _estatus_poliza,
		   _saldo_r,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_impresion
	  from tmp_datos
	 order by vigencia_inic

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _estatus_poliza = 1 then				
		let _estatus = 'Vigente';
	elif _estatus_poliza = 2 then
		let _estatus = 'Cancelada';
	elif _estatus_poliza = 3 then
		let _estatus = 'Vencida';
	elif _estatus_poliza = 4 then
		let _estatus = 'Anulada';
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc

		exit foreach;
	end foreach

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	foreach
		select no_poliza
		  into _no_poliza_ant
		  from emipomae
		 where no_documento = _no_documento
		   and vigencia_inic < _vigencia_inic
		 order by vigencia_inic desc

		exit foreach;
	end foreach

	select sum(prima_bruta)
	  into _prima_bruta_ant
	  from endedmae
	 where no_poliza = _no_poliza_ant
	   and actualizado = 1
	   and activa = 1;

	select sum(prima_bruta)
	  into _prima_bruta
	  from endedmae
	 where no_poliza = _no_poliza
	   and actualizado = 1
	   and activa = 1;

	call sp_cob33('001','001', _no_documento, _periodo_actual, _fecha_hoy)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	let _porc_saldo = 0;
	if _prima_bruta_ant > 0 then
		let _porc_saldo = (_saldo_r/_prima_bruta_ant) * 100;
	end if

	return	_no_documento,
			_estatus,
			_nom_ramo,
			_nom_formapag,
			_vigencia_inic,
			_vigencia_final,
			_fecha_impresion,
			_prima_bruta,
			_prima_bruta_ant,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_saldo,
			_saldo_r,
			_porc_saldo,
			_nom_agente with resume;
end foreach

commit work;

end
end procedure;