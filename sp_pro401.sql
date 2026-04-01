-- Procedimiento que Genera el Reporte Detallado del proceso de prima no devengada de NIIF
-- Creado    : 06/08/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro401;

create procedure sp_pro401(a_periodo char(8))
returning	char(21),		--1. _no_documento
			varchar(100),	--2. _nom_cliente
			varchar(50),	--3. _nom_ramo
			date,			--4. _vigencia_inic
			date,			--5. _vigencia_final
			smallint,		--6. _dias_facturados
			date,			--7. _fecha_corte
			smallint,		--8. _dias_no_trans
			dec(16,2),		--9. _prima_suscrita
			dec(16,2),		--10_prima_no_dev
			dec(16,2),		--11_reaseg_cedido
			dec(16,2),		--12_reaseg_cedido_no_dev
			dec(16,2),		--13_imp_prima_no_dev
			dec(16,2),		--14_imp_rea_ced_no_dev
			dec(16,2);		--15_comis_no_dev_agt

define _nom_cliente				varchar(100);
define _nom_ramo				varchar(50);
define _error_desc				char(100);
define _cuenta					char(25);
define _no_documento			char(21);
define _cod_cliente				char(10);
define _no_poliza				char(10);
define _periodo					char(7);
define _cod_contrato			char(5);
define _cod_agente				char(5);
define _no_endoso				char(5);
define _centro_costo			char(3);
define _cod_ramo				char(3);
define _porc_comis_agt			dec(5,2);
define _comis_no_dev_agt_ac_mes	dec(16,2);
define _reaseg_ced_no_dev_mes	dec(16,2);
define _reaseg_cedido_no_dev	dec(16,2);
define _imp_prima_no_dev_mes	dec(16,2);
define _comis_no_dev_agt_ac		dec(16,2);
define _imp_rea_ced_no_dev		dec(16,2);
define _reaseg_cedido_mes		dec(16,2);
define _comis_no_dev_agt		dec(16,2);
define _imp_prima_no_dev		dec(16,2);
define _prima_no_dev_mes		dec(16,2);
define _prima_reaseguro			dec(16,2);
define _prima_suscrita			dec(16,2);
define _prima_susc_mes			dec(16,2);
define _reaseg_cedido			dec(16,2);
define _prima_no_dev			dec(16,2);
define _dias_facturados_m		smallint;
define _dias_facturados			smallint;
define _dias_no_trans_m			smallint;
define _dias_no_trans			smallint;
define _tipo_contrato			smallint;
define _ramo_sis				smallint;
define _dias					smallint;		
define _error_isam				integer;
define _error					integer;
define _vigencia_final 			date;
define _vigencia_inic 			date;
define _fecha_desde				date;
define _fecha_hasta				date;
define _fecha_corte				date;
define _fecha					date;

set isolation to dirty read;

--set debug file to "sp_pro401.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
  rollback work;
  drop table tmp_niif;
  return '',_error_desc,'','','',_error,'',_error_isam,0.00,0.00,0.00,0.00,0.00,0.00,0.00;
end exception

let _reaseg_cedido_no_dev	= 0.00;
let _comis_no_dev_agt_ac	= 0.00;
let _imp_prima_no_dev		= 0.00;
let _prima_suscrita			= 0.00;
let _reaseg_cedido			= 0.00;
let _prima_no_dev			= 0.00;
let _dias_facturados		= 0;
let _dias_no_trans			= 0;
let _fecha_hasta			= sp_sis36(a_periodo);
let _fecha_desde			= mdy(1,month(fecha_hasta),year(fecha_hasta));
let _dias					= fecha_hasta - _fecha_desde + 1;

create temp table tmp_niif_resume(
	cuenta					char(25),		--1. _no_documento
	prima_suscrita			dec(16,2),		--2. _prima_suscrita
	prima_no_dev			dec(16,2),		--3._prima_no_dev
	reaseg_cedido			dec(16,2),		--4._reaseg_cedido
	rea_cedido_no_dev		dec(16,2),		--5._reaseg_cedido_no_dev
	imp_prima_no_dev		dec(16,2),		--6._imp_prima_no_dev
	imp_rea_ced_no_dev		dec(16,2),		--7._imp_rea_ced_no_dev
	comis_no_dev_agt		dec(16,2),		--8._comis_no_dev_agt
	prima_suscrita_m		dec(16,2),		--2. _prima_suscrita
	prima_no_dev_m			dec(16,2),		--3._prima_no_dev
	reaseg_cedido_m			dec(16,2),		--4._reaseg_cedido
	rea_cedido_no_dev_m		dec(16,2),		--5._reaseg_cedido_no_dev
	imp_prima_no_dev_m		dec(16,2),		--6._imp_prima_no_dev
	imp_rea_ced_no_dev_m	dec(16,2),		--7._imp_rea_ced_no_dev
	comis_no_dev_agt_m		dec(16,2)		--8._comis_no_dev_agt
	) with no log;

foreach with hold
	select distinct no_poliza
	  into _no_poliza
	  from prdprinode
	 where fecha >= a_fecha_desde
	   and fecha <= a_fecha_hasta

	begin work;

	select no_documento,
		   cod_pagador,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  into _no_documento,
		   _cod_cliente,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 5 then
		commit work;
		continue foreach;
	end if
	
	select sum(prima_suscrita)
	  into _prima_suscrita
	  from endedmae
	 where no_poliza = _no_poliza;

	if _prima_suscrita = 0 then
		commit work;
		continue foreach;
	end if
	
	select max(fecha)
	  into _fecha_corte
	  from prdprinode
	 where no_poliza = _no_poliza
	   and sac_asientos = 1;

	let _dias_facturados = _vigencia_final - _vigencia_inic;

	if _dias_facturados = 0 then
		let _dias_facturados = 1;
	end if

	if _fecha_corte > _fecha_hasta then
		let _fecha_corte = _fecha_hasta;
	end if
	
	let _dias_no_trans	= _vigencia_final - _fecha_corte;
--Proceso Acumulado de meses anteriores
	let _prima_no_dev	= _dias_no_trans / _dias_facturados * _prima_suscrita;
	
-- Proceso  del mes escogido del periodo
	select sum(prima_no_devengada)
	  into _prima_susc_mes
	  from prdprinode
	 where no_poliza = _no_poliza
	   and fecha >= _fecha_desde
	   and fecha <= _fecha_hasta;
	
	let _dias_no_trans_m = _fecha_hasta - _fecha_corte;	
	let _dias_facturados_m = _dias;
	
	if _vigencia_final < _fecha_hasta then
		let _dias_facturados_m = _vigencia_final - _fecha_desde + 1;
		let _dias_no_trans_m = _dias_no_trans;
	end if
	
	let _prima_no_dev_mes = _dias_no_trans_m / _dias_facturados_m * _prima_susc_mes;
	Let _cuenta    = sp_sis15('PIPSSD' , '01', _no_poliza);
-------------------------------------------*************************************************************************************************************************************-------------------------------------------	

	foreach
		select porc_comis_agt
		  into _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza

		let _comis_no_dev_agt = 0.00;
		let _comis_no_dev_agt = _prima_no_dev * (_porc_comis_agt / 100);
		let _comis_no_dev_agt_ac = _comis_no_dev_agt_ac + _comis_no_dev_agt;
	end foreach
	
	foreach
		select no_endoso
		  into _no_endoso
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1

		foreach
			select cod_contrato,
				   prima
			  into _cod_contrato,
				   _prima_reaseguro
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _tipo_contrato = 1 then
				continue foreach;
			end if
			
			let _reaseg_cedido = _reaseg_cedido + _prima_reaseguro;
		end foreach
	end foreach
	
	let _imp_prima_no_dev = _prima_no_dev * 0.02;
	let _reaseg_cedido_no_dev = _dias_no_trans/_dias_facturados*_reaseg_cedido;
	let _imp_rea_ced_no_dev = _reaseg_cedido_no_dev * 0.02;
	
	insert into tmp_niif_resume(
			cuenta,
			no_documento,
			prima_suscrita,
			prima_no_dev,
			reaseg_cedido,
			rea_cedido_no_dev,
			imp_prima_no_dev,
			imp_rea_ced_no_dev,
			comis_no_dev_agt,
			prima_suscrita_m,
			prima_no_dev_m,
			reaseg_cedido_m,
			rea_cedido_no_dev_m,
			imp_prima_no_dev_m)
	values	(_cuenta,
			_no_documento,
			_prima_suscrita,
			_prima_no_dev,
			_reaseg_cedido,
			_reaseg_cedido_no_dev,
			_imp_prima_no_dev,
			_imp_rea_ced_no_dev,
			_comis_no_dev_agt_ac,
			_prima_susc_mes,
			_prima_no_dev_mes,
			_reaseg_cedido_mes,
			_reaseg_ced_no_dev_mes,
			_imp_prima_no_dev_mes,
			_comis_no_dev_agt_ac_mes);
			
	let _comis_no_dev_agt_ac = 0.00;
	let _reaseg_cedido = 0.00;
	commit work;
end foreach

foreach
	select cuenta,
		   sum(prima_suscrita),
		   sum(prima_no_dev),
		   sum(reaseg_cedido),
		   sum(rea_cedido_no_dev),
		   sum(imp_prima_no_dev),
--		   imp_rea_ced_no_dev,
		   sum(comis_no_dev_agt),
		   sum(prima_suscrita_m),
		   sum(prima_no_dev_m),
		   sum(reaseg_cedido_m),
		   sum(rea_cedido_no_dev_m),
		   sum(imp_prima_no_dev_m),
--		   imp_rea_ced_no_dev,
		   sum(comis_no_dev_agt_m)
	  into _cuenta,
		   _prima_suscrita,
		   _prima_no_dev,
		   _reaseg_cedido,
		   _reaseg_cedido_no_dev,
		   _imp_prima_no_dev,
--		   _imp_rea_ced_no_dev,
		   _comis_no_dev_agt_ac,
		   _prima_susc_mes,
		   _prima_no_dev_mes,
		   _reaseg_cedido_mes,
		   _reaseg_ced_no_dev_mes,
		   _imp_prima_no_dev_mes,
		   _comis_no_dev_agt_ac_mes
	  from tmp_niif_resume
	 group by cuenta
	
	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;
	 
	return	_nom_cuenta,				--Segmentado por ramo de acuerdo a la 411
			_prima_suscrita,			--Prima suscrita acumulada
			_prima_no_dev,				--Prima acumulada no devengada
			_prima_susc_mes,			--Prima suscrita mensual (mes)
			_prima_no_dev_mes,			--Prima no devengada mensual (mes) 
			_reaseg_cedido,				--Reaseguro cedido acumulado
			_reaseg_cedido_no_dev,		--Reaseguro cedido acumulado no devengado
			_reaseg_cedido_mes,			--Reaseguro cedido mensual (mes)
			_reaseg_ced_no_dev_mes,		--Reaseguro cedido mensual no devengado
			_imp_prima_no_dev,			--Impto. 2% sobre prima no devengada acumulado
			_imp_prima_no_dev_mes,		--Impto. 2% sobre prima no devengada mensual (mes)
			_comis_no_dev_agt_ac,		--Comisión de corredor sobre prima no devengada acumulada
			_comis_no_dev_agt_ac_mes	--Comisión de corredor sobre prima no devengada mensual
			with resume;
end foreach

drop table tmp_niif_resume;
end
end procedure