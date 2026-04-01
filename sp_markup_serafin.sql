-- Procedimiento que Carga las tablas para el Analisis de Cuentas 
-- Creado: 20/10/2022 - Autor: Román Gordón
-- execute procedure sp_markup_serafin('001','001','2022-01','2022-10')

drop procedure sp_markup_serafin;
create procedure sp_markup_serafin(
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
define _motiv_no_renov			varchar(50);
define _zona_ventas				varchar(50);
define _nom_agente				varchar(50);
define _producto				varchar(50);
define _subramo					varchar(50);
define _ramo,_n_tipoauto		varchar(50);
define _no_documento			char(20); 
define _cod_contratante			char(10); 
define _cod_asegurado			char(10); 
define _cod_cliente				char(10); 
define _no_remesa				char(10); 
define _no_poliza				char(10); 
define _periodo_cob				char(7);
define _cod_producto			char(5);
define _cod_agente				char(5);
define _no_unidad				char(5);
define _cod_grupo				char(5);  
define _cod_sucursal			char(3);  
define _cod_tipoprod			char(3);
define _cod_no_renov			char(3);
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
define _mto_cob_pol				dec(16,2); 
define _porc_partic_agt			dec(5,2); 
define _porc_ret_uni			dec(9,6); 
define _proporcion_uni			dec(9,6); 
define _porc_comis_agt			dec(5,2); 
define _estatus_poliza			smallint;
define _cnt_markup				smallint;
define _no_pagos				smallint;
define _renglon,_cnt			integer;
define _error_isam				integer;
define _error					integer;
define _fecha_cob				date;
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
	no_pagos			smallint,
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
	producto_markup		smallint,
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
	no_remesa			char(10),
	renglon				integer,
	periodo_cob			char(7),
	fecha_cob			date,
	n_tipoauto          varchar(50),
	motiv_no_renov      varchar(50),
	PRIMARY KEY (no_remesa,renglon,no_poliza,cod_agente)) WITH NO LOG;

let _fecha_hoy = current;
let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

--drop table if exists tmp_incurrido;
--drop table if exists tmp_sinis;
--let v_filtros = sp_rec01(a_compania, a_agencia, a_periodo_desde, a_periodo_hasta); 

foreach
	select emi.no_poliza,
		   emi.no_documento,
		   cli.cod_cliente,
		   cli.nombre,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.estatus_poliza,
		   emi.nueva_renov,
		   emi.no_pagos,
		   grp.cod_grupo,
		   grp.nombre,
		   ram.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   agt.cod_agente,
		   agt.nombre,
		   cor.porc_partic_agt,
		   cor.porc_comis_agt,
		   emi.suma_asegurada,
		   emi.prima_neta,
		   emi.prima_suscrita,
		   emi.cod_no_renov,
		   cob.no_remesa,
		   cob.renglon,
		   cob.periodo,
		   cob.fecha,
		   cob.monto,
		   cob.prima_neta
	  into _no_poliza,
		   _no_documento,
		   _cod_contratante,
		   _nom_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _nueva_renov,
		   _no_pagos,
		   _cod_grupo,
		   _nom_grupo,
		   _cod_ramo,
		   _ramo,
		   _cod_subramo,
		   _subramo,
		   _cod_agente,
		   _nom_agente,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _suma_asegurada,
		   _prima_neta_pol,
		   _prima_susc_pol,
		   _cod_no_renov,
		   _no_remesa,
		   _renglon,
		   _periodo_cob,
		   _fecha_cob,
		   _mto_cob_pol,
		   _mto_cob_neto_pol
	  from emipomae emi
	 inner join emipoagt cor on cor.no_poliza = emi.no_poliza
	 inner join agtagent agt on agt.cod_agente = cor.cod_agente
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join emitipro pro on pro.cod_tipoprod = emi.cod_tipoprod
--	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
--	 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
	 inner join cobredet cob on cob.no_poliza = emi.no_poliza and cob.tipo_mov in ('P','N')
	 where cor.cod_agente in ('01589','02901','02311')
	   and cob.periodo between a_periodo_desde and a_periodo_hasta
--	   and emi.no_documento in('0223-01494-09')--in('2322-00085-01','0922-10015-01')

	let _cnt_markup = 0;
	select count(*)
	  into _cnt_markup
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in ('08268','08305','08307','08267','08127','08256','08255','08209','08351','08352',
							'08353','08374','08312','08311','08310','08309','08271','08308','08361','08210',
							'06054','08221','08393','09446','08615','08159','08146','08264','08158');

	if _cnt_markup is null then
		let _cnt_markup = 0;
	end if
	
	select nombre
	  into _motiv_no_renov
	  from eminoren
	 where cod_no_renov = _cod_no_renov;

	if _motiv_no_renov is null then
		let _motiv_no_renov = '';
	end if
	
	foreach
		select ase.cod_cliente,
			   ase.nombre,
			   prd.cod_producto,
			   prd.nombre
		  into _cod_asegurado,
			   _nom_asegurado,
			   _cod_producto,
			   _producto
		  from emipouni uni
		 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
		 inner join prdprod prd on prd.cod_producto = uni.cod_producto
		 where no_poliza = _no_poliza
		 order by no_unidad
		exit foreach;
	end foreach
	
	--Sacar el tipo auto, si hay mas de un tipo para la poliza, se coloca multiples.
	let _cnt        = 0;
	let _n_tipoauto = '';
	foreach
		select distinct p.nombre
		  into _n_tipoauto
		  from emipomae r, emipouni e, emiauto t, emivehic h, emimodel m, emitiaut p
		 where r.no_poliza = e.no_poliza
		   and e.no_poliza = t.no_poliza
		   and e.no_unidad = t.no_unidad
		   and t.no_motor = h.no_motor
		   and h.cod_modelo = m.cod_modelo
		   and m.cod_tipoauto = p.cod_tipoauto
		   and r.no_poliza = _no_poliza
		   
		let _cnt = _cnt + 1;
		if _cnt > 1 then
			let _n_tipoauto = 'MULTIPLES';
			exit foreach;
		end if
	end foreach
	
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
	no_pagos,
	cod_agente,
	nom_agente,
	porc_partic_agt,
	porc_comis_agt,
	prima_neta_pol,
	prima_susc_pol,
	mto_cob_neto_pol,
	prima_cob_dev,
	suma_asegurada,
	cod_producto,
	producto,
	producto_markup,
	no_remesa,
	renglon,
	periodo_cob,
	fecha_cob,
	n_tipoauto,
	motiv_no_renov)
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
	_no_pagos,
	_cod_agente,
	_nom_agente,
	_porc_partic_agt,
	_porc_comis_agt,
	_prima_neta_pol,
	_prima_susc_pol,
	_mto_cob_neto_pol,
	_mto_cob_pol,
	_suma_asegurada,
	_cod_producto,
	_producto,
	_cnt_markup,
	_no_remesa,
	_renglon,
	_periodo_cob,
	_fecha_cob,
	_n_tipoauto,
	_motiv_no_renov
	);
end foreach
return 0,'Carga Exitosa';
end
end procedure;