-- Procedimiento que Carga las tablas para el Analisis de Cuentas 
-- Creado: 20/10/2022 - Autor: Román Gordón
-- execute procedure sp_bi01('001','001','2022-01','2022-10')

drop procedure sp_bi01;
create procedure "informix".sp_bi01(
a_compania		char(3),
a_agencia		char(3),
a_periodo_desde	char(7),
a_periodo_hasta	char(7))
returning	integer 		as error,
			varchar(100)	as mensaje;

define v_filtros				varchar(255);
define _mensaje					varchar(255);
define _nom_contratante			varchar(100);
define _nom_asegurado			varchar(100);
define _nom_grupo				varchar(100);
define _tipo_produccion			varchar(50);
define _zona_ventas				varchar(50);
define _nom_agente				varchar(50);
define _producto				varchar(50);
define _subramo					varchar(50);
define _ramo					varchar(50);
define _no_documento			char(20); 
define _cod_contratante			char(10); 
define _cod_asegurado			char(10); 
define _cod_cliente				char(10); 
define _no_poliza				char(10); 
define _cod_producto			char(5);
define _cod_agente				char(5);
define _no_unidad				char(5);
define _cod_grupo				char(5);  
define _cod_sucursal			char(3);  
define _cod_tipoprod			char(3);
define _cod_subramo				char(3);  
define _cod_zona				char(3);  
define _cod_ramo				char(3);  
define _cod_origen				char(3);
define _nueva_renov				char(1);
define _prima_susc_dev_uni_ret	dec(16,2); 
define _prima_cob_dev_uni_ret	dec(16,2); 
define _prima_susc_dev_uni		dec(16,2); 
define _prima_cob_dev_uni		dec(16,2); 
define _mto_cob_neto_uni		dec(16,2); 
define _mto_cob_neto_pol		dec(16,2); 
define _rec_pagado_total		dec(16,2); 
define _incurrido_total			dec(16,2);
define _rec_pagado_neto			dec(16,2); 
define _incurrido_neto			dec(16,2); 
define _suma_asegurada			dec(16,2); 
define _prima_neta_uni			dec(16,2); 
define _prima_susc_uni			dec(16,2); 
define _prima_neta_pol			dec(16,2); 
define _prima_susc_pol			dec(16,2); 
define _prima_susc_dev			dec(16,2); 
define _prima_cob_dev			dec(16,2); 
define _prima_ret_pol			dec(16,2); 
define _prima_ced_pol			dec(16,2); 
define _prima_ced_uni			dec(16,2); 
define _prima_ret_uni			dec(16,2); 
define _reserva_total			dec(16,2); 
define _reserva_neta			dec(16,2); 
define _porc_partic_agt			dec(5,2); 
define _porc_ret_uni			dec(9,6); 
define _proporcion_uni			dec(9,6); 
define _porc_comis_agt			dec(5,2); 
define _estatus_poliza			smallint;
define _error_isam				integer;
define _error					integer;
define _fecha_suspension		date;
define _fecha_desde				date;
define _fecha_hasta				date;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_hoy				date;

begin
	on exception set _error,_error_isam,_mensaje
		return _error,_no_documento ||" " ||_mensaje ;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

drop table if exists tmp_analisis_cartera;
create temp table tmp_analisis_cartera(
	no_poliza			char(10),
	no_documento		char(20),
	cod_contratante		char(10),
	nom_contratante		varchar(100),
	cod_asegurado		char(10),
	nom_asegurado		varchar(100),
	vigencia_inic		date,
	vigencia_final		date,
	estatus_poliza		smallint,
	nueva_renov			char(1),
	cod_grupo			char(5),
	nom_grupo			varchar(50),
	cod_ramo			char(3),
	ramo				varchar(50),
	cod_subramo			char(3),
	subramo				varchar(50),
	tipo_produccion		varchar(50),
	cod_zona			char(3),
	zona_ventas			varchar(50),
	cod_agente			char(5),
	nom_agente			varchar(100),
	porc_partic_agt		dec(5,2),
	porc_comis_agt		dec(5,2),
	prima_neta_pol		dec(16,2),
	prima_susc_pol		dec(16,2),
	prima_ret_pol		dec(16,2),
	prima_ced_pol		dec(16,2),
	mto_cob_neto_pol	dec(16,2),
	prima_susc_dev		dec(16,2),
	prima_cob_dev		dec(16,2),
	no_unidad			char(5),
	suma_asegurada		dec(16,2),
	cod_producto		char(5),
	producto			varchar(50),
	prima_neta_uni		dec(16,2),
	prima_susc_uni		dec(16,2),
	prima_ret_uni		dec(16,2),
	prima_ced_uni		dec(16,2),
	mto_cob_neto_uni	dec(16,2),
	prima_susc_dev_uni	dec(16,2),
	prima_cob_dev_uni	dec(16,2),
	prima_susc_dev_ret	dec(16,2),
	prima_cob_dev_ret	dec(16,2),
	proporcion_uni		dec(5,2),
	rec_pagado_total	dec(16,2),
	reserva_total		dec(16,2),
	incurrido_total		dec(16,2),
	rec_pagado_neto		dec(16,2),
	reserva_neta		dec(16,2),
	incurrido_neto		dec(16,2),
	PRIMARY KEY (no_poliza,no_unidad,cod_agente)) WITH NO LOG;

let _fecha_hoy = current;
let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

drop table if exists tmp_incurrido;
drop table if exists tmp_sinis;
let v_filtros = sp_rec01(a_compania, a_agencia, a_periodo_desde, a_periodo_hasta); 

foreach
	select emi.no_poliza,
		   emi.no_documento,
		   cli.cod_cliente,
		   cli.nombre,
		   ase.cod_cliente,
		   ase.nombre,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.estatus_poliza,
		   emi.nueva_renov,
		   grp.cod_grupo,
		   grp.nombre,
		   ram.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   pro.nombre,
		   zon.cod_vendedor,
		   zon.nombre,
		   agt.cod_agente,
		   agt.nombre,
		   cor.porc_partic_agt,
		   cor.porc_comis_agt,
		   emi.prima_neta,
		   emi.prima_suscrita,
		   emi.prima_retenida,
		   emi.prima_suscrita - emi.prima_retenida,
		   uni.no_unidad,
		   uni.suma_asegurada,
		   prd.cod_producto,
		   prd.nombre,
		   uni.prima_neta,
		   uni.prima_suscrita,
		   uni.prima_retenida,
		   uni.prima_suscrita - uni.prima_retenida,
		   uni.prima_suscrita/emi.prima_suscrita * 100,
		   case 
		   when uni.prima_suscrita = 0 then
				uni.prima_retenida/uni.prima_neta * 100
		   else
				uni.prima_retenida/uni.prima_suscrita * 100
		   end case
	  into _no_poliza,
		   _no_documento,
		   _cod_contratante,
		   _nom_contratante,
		   _cod_asegurado,
		   _nom_asegurado,
		   _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _nueva_renov,
		   _cod_grupo,
		   _nom_grupo,
		   _cod_ramo,
		   _ramo,
		   _cod_subramo,
		   _subramo,
		   _tipo_produccion,
		   _cod_zona,
		   _zona_ventas,
		   _cod_agente,
		   _nom_agente,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _prima_neta_pol,
		   _prima_susc_pol,
		   _prima_ret_pol,
		   _prima_ced_pol,
		   _no_unidad,
		   _suma_asegurada,
		   _cod_producto,
		   _producto,
		   _prima_neta_uni,
		   _prima_susc_uni,
		   _prima_ret_uni,
		   _prima_ced_uni,
		   _proporcion_uni,
		   _porc_ret_uni
	  from emipomae emi
	 inner join emipoagt cor on cor.no_poliza = emi.no_poliza
	 inner join agtagent agt on agt.cod_agente = cor.cod_agente
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join agtvende zon on zon.cod_vendedor = agt.cod_vendedor
	 inner join emitipro pro on pro.cod_tipoprod = emi.cod_tipoprod
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza and uni.prima_neta <> 0
	 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
	 inner join prdprod prd on prd.cod_producto = uni.cod_producto
	 where uni.cod_producto in ('08268','08305','08306','08307','08267','08159','08257','08258','08127','08256','08255','08259','08261','08209','08351','08352','08353','08374','08146'
							   ,'08264','08312','08311','08310','08309','08271','08308','08393','08361','08370','08210','08221','08158')
	 --emi.cod_grupo in ('00068','77973','77974','77978','77979','77980')
	 --  and emi.estatus_poliza = 1
	   and emi.vigencia_inic >= '31/07/2022'
	   and emi.prima_suscrita <> 0
	   and cor.cod_agente in ('02311')
--	   and emi.no_documento <> '0222-05371-09'

	call sp_dev06g(_no_documento,_fecha_hoy,_vigencia_inic,_fecha_hasta) 
	returning _error,_mensaje,_prima_susc_dev,_prima_cob_dev;
	
	if _error <> 0 then
		return _error,_mensaje;
	end if

	let _prima_susc_dev_uni = _prima_susc_dev * (_proporcion_uni/100);
	let _prima_cob_dev_uni = _prima_cob_dev * (_proporcion_uni/100);
	
	let _prima_susc_dev_uni_ret = _prima_susc_dev_uni * (_porc_ret_uni/100);
	let _prima_cob_dev_uni_ret = _prima_cob_dev_uni * (_porc_ret_uni/100);

	let _mto_cob_neto_pol = 0.00;
	select sum(prima_neta)
	  into _mto_cob_neto_pol
	  from cobredet
	 where no_poliza = _no_poliza
	   and periodo < a_periodo_hasta;

	if _mto_cob_neto_pol is null then
		let _mto_cob_neto_pol = 0.00;
		let _mto_cob_neto_uni = 0.00;
	else
		let _mto_cob_neto_uni = _mto_cob_neto_pol *  (_proporcion_uni/100);
	end if
	
	
	let _rec_pagado_neto = 0.00;
	let _incurrido_neto = 0.00;
	let _reserva_neta = 0.00;
	
	select sum(pagado_total),
		   sum(reserva_total),
		   sum(incurrido_total),
		   sum(pagado_neto),
		   sum(reserva_neto),
		   sum(incurrido_neto)
	  into _rec_pagado_total,
		   _reserva_total,
		   _incurrido_total,
		   _rec_pagado_neto,
		   _reserva_neta,
		   _incurrido_neto
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo and tmp.no_poliza = _no_poliza and rec.no_unidad = _no_unidad;

	if _rec_pagado_neto is null then
		let _rec_pagado_neto = 0.00;
	end if

	if _incurrido_neto is null then
		let _incurrido_neto = 0.00;
	end if

	if _reserva_neta is null then 
		let _reserva_neta = 0.00;
	end if

	if _rec_pagado_total is null then
		let _rec_pagado_total = 0.00;
	end if

	if _reserva_total is null then
		let _reserva_total = 0.00;
	end if

	if _incurrido_total is null then 
		let _incurrido_total = 0.00;
	end if

	insert into tmp_analisis_cartera(
	no_poliza,
	no_documento,
	cod_contratante,
	nom_contratante,
	cod_asegurado,
	nom_asegurado,
	vigencia_inic,
	vigencia_final,
	estatus_poliza,
	nueva_renov,
	cod_grupo,
	nom_grupo,
	cod_ramo,
	ramo,
	cod_subramo,
	subramo,
	tipo_produccion,
	cod_zona,
	zona_ventas,
	cod_agente,
	nom_agente,
	porc_partic_agt,
	porc_comis_agt,
	prima_neta_pol,
	prima_susc_pol,
	prima_ret_pol,
	prima_ced_pol,
	mto_cob_neto_pol,
	prima_susc_dev,
	prima_cob_dev,
	no_unidad,
	suma_asegurada,
	cod_producto,
	producto,
	prima_neta_uni,
	prima_susc_uni,
	prima_ret_uni,
	prima_ced_uni,
	prima_susc_dev_uni,
	prima_cob_dev_uni,
	proporcion_uni,
	rec_pagado_total,
	reserva_total,
	incurrido_total,
	rec_pagado_neto,
	reserva_neta,
	incurrido_neto,
	prima_susc_dev_ret,
	prima_cob_dev_ret,
	mto_cob_neto_uni
	)
	values(
	_no_poliza,
	_no_documento,
	_cod_contratante,
	_nom_contratante,
	_cod_asegurado,
	_nom_asegurado,
	_vigencia_inic,
	_vigencia_final,
	_estatus_poliza,
	_nueva_renov,
	_cod_grupo,
	_nom_grupo,
	_cod_ramo,
	_ramo,
	_cod_subramo,
	_subramo,
	_tipo_produccion,
	_cod_zona,
	_zona_ventas,
	_cod_agente,
	_nom_agente,
	_porc_partic_agt,
	_porc_comis_agt,
	_prima_neta_pol,
	_prima_susc_pol,
	_prima_ret_pol,
	_prima_ced_pol,
	_mto_cob_neto_pol,
	_prima_susc_dev,
	_prima_cob_dev,
	_no_unidad,
	_suma_asegurada,
	_cod_producto,
	_producto,
	_prima_neta_uni,
	_prima_susc_uni,
	_prima_ret_uni,
	_prima_ced_uni,
	_prima_susc_dev_uni,
	_prima_cob_dev_uni,
	_proporcion_uni,
	_rec_pagado_total,
	_reserva_total,
	_incurrido_total,
	_rec_pagado_neto,
	_reserva_neta,
	_incurrido_neto,
	_prima_susc_dev_uni_ret,
	_prima_cob_dev_uni_ret,
	_mto_cob_neto_uni);
end foreach

return 0,'Carga Exitosa';

end
end procedure;