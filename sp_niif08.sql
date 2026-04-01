-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif08('2021-01','2021-12')
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_niif08;
create procedure sp_niif08(a_periodo_desde char(7),a_periodo_hasta char(7))
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as error_desc;
			
			
define _error_desc			char(50);
define _nom_ramo			varchar(50);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _anio				smallint;
define _estatus_poliza		smallint;
define _clasificacion		smallint;
define _cnt_cob				smallint;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _error_isam			integer;
define my_sessionid			integer;
define _error				integer;
define _prima_cob_cedida	dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_retenida		dec(16,2);
define _prima_cob_ret		dec(16,2);
define _prima_cedida		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _monto_cob			dec(16,2);
define _monto2				dec(16,2);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return _error,
		   _error_isam,
		   _error_desc;
end exception


--set debug file to "sp_pro545.trc";
--trace on;

drop table if exists fichero_auto;
create temp table fichero_auto(
anio					smallint,
no_poliza				char(10),--
no_documento			char(20),--
vigencia_inic			date,--
vigencia_final			date,--
cod_ramo				char(3),--
ramo					varchar(50),
desc_clasif				varchar(50),
categoria_contable		varchar(50),
segm_triangulo			varchar(50),
estatus_poliza			smallint,
tipo_clasificacion		smallint,
nueva_renov				char(1),
prima_bruta				dec(16,2),--
prima_neta				dec(16,2),--
prima_suscrita			dec(16,2),--
prima_retenida			dec(16,2),--
prima_cedida			dec(16,2),--
prima_cobrada			dec(16,2),--??
prima_neta_cob			dec(16,2),--??
prima_cobrada_ret		dec(16,2),--??
prima_cobrada_ced		dec(16,2),--??
provision_prima			dec(16,2) default 0.00,--
gastos_admin			dec(16,2) default 0.00,
otros_gastos_adq		dec(16,2) default 0.00,
primary key (no_poliza)) with no log;

{foreach with hold
	select distinct no_documento
	  into a_no_documento
	  from emipomae
	 where no_documento in (select distinct no_documento from endedmae where no_endoso = '00000' and activa = 0)
	begin work;}

let my_sessionid = DBINFO('sessionid');
let _anio = a_periodo_desde[1,4];

foreach with hold
	select emi.no_poliza,
		   emi.no_documento,
		   emi.cod_ramo,
		   ram.nombre,
		   emi.vigencia_final,
		   emi.vigencia_inic,
		   emi.fecha_cancelacion,
		   emi.nueva_renov,
		   emi.estatus_poliza,
		   sum(mae.prima_bruta),
		   sum(mae.prima_neta),
		   sum(mae.prima_suscrita),
		   sum(mae.prima_retenida)
	  into _no_poliza,
		   _no_documento,
		   _cod_ramo,
		   _nom_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_cancelacion,
		   _nueva_renov,
		   _estatus_poliza,
		   _prima_bruta,
		   _prima_neta,
		   _prima_suscrita,
		   _prima_retenida
	  from emipomae emi
	 inner join endedmae mae on mae.no_poliza = emi.no_poliza and mae.actualizado = 1 and mae.periodo >= a_periodo_desde and mae.periodo <= a_periodo_hasta 
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo and ram.ramo_sis = 1
	 group by emi.no_poliza,emi.no_documento,emi.cod_ramo,ram.nombre,emi.vigencia_final,emi.vigencia_inic,emi.fecha_cancelacion,
			  emi.nueva_renov,emi.estatus_poliza--,mae.periodo
	  
	/*select first 100 emi.no_poliza,
		   emi.no_documento,
		   mae.vigencia_inic,
		   mae.vigencia_final,
		   mae.cod_ramo,
		   mae.estatus_poliza,
		   mae.no_pagos,
		   sum(emi.prima_neta),
		   sum(emi.prima_suscrita),
		   sum(emi.prima_suscrita - emi.prima_retenida),
		   sum(emi.prima_bruta)		   
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _no_pagos,
		   _prima_neta,
		   _prima_suscrita,
		   _prima_cedida,
		   _prima_bruta
	  from endedmae emi
	 inner join emipomae mae on mae.no_poliza = emi.no_poliza
	 where emi.periodo >= a_periodo_desde
	   and emi.periodo <= a_periodo_hasta 
	   and emi.actualizado = 1
	   and mae.cod_ramo in ('002','020','023')
	 group by emi.no_poliza,emi.no_documento,mae.vigencia_inic,mae.vigencia_final,mae.cod_ramo,	mae.estatus_poliza,mae.no_pagos*/

	/*if _fecha_cancelacion <= a_fecha_hasta then
		foreach
			select fecha_emision
			  into _fecha_emision
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and vigencia_inic = _fecha_cancelacion
		end foreach

		if  _fecha_emision <= a_fecha_hasta then
			continue foreach;
		end if
	end if*/
	
	call sp_niif13(_no_poliza,'','',1)
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;

	let _prima_cedida = _prima_suscrita - _prima_retenida;

	select sum(prima_neta),
		   sum(monto)
	  into _prima_neta_cob,
		   _monto_cob
	  from cobredet
	 where no_poliza = _no_poliza
	   and tipo_mov in ('P','N','X')
	   and actualizado = 1;
	
	if _prima_neta_cob is null or _prima_neta_cob = 0 then
		let _prima_neta_cob = 0;
		let _prima_cob_ret = 0;
		let _prima_cob_cedida = 0;
	else
		select sum(prima_neta * (porc_partic_prima/100) * (porc_proporcion/100))
		  into _prima_cob_ret
		  from cobredet cob
		 inner join cobreaco rea on rea.no_remesa = cob.no_remesa and rea.renglon = cob.renglon
		 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
		 where cob.no_poliza = _no_poliza
		   and cob.tipo_mov in ('P','N','X')
		   and cob.actualizado = 1;
		
		let _prima_cob_cedida = _prima_neta_cob - _prima_cob_ret;		
	end if

	if _cod_ramo = '020' then
		let _clasificacion = 2;
	elif _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_cob
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222',
								 '01299','01300','01301','01302','01303','01304','01305','01306','01307','01308','01309','01310','01311','01312','01313',
								 '01314','01315','01322','01323','01324','01325','01326','01327','01338','01341','01376','01536','01578','01657','01677',
								 '01816');

		if _cnt_cob is null then
			let _cnt_cob = 0;
		end if
		
		if _cnt_cob = 0 then
			if _cod_ramo = '002' then
				let _clasificacion = 2;
			else
				let _clasificacion = 4;
			end if
		else
			if _cod_ramo = '002' then
				let _clasificacion = 1;
			else
				let _clasificacion = 3;
			end if
		end if
	else --PENDIENTE
		
	end if
insert into fichero_auto(
		anio,
		no_poliza			,
		no_documento		,
		vigencia_inic		,
		vigencia_final		,
		cod_ramo			,
		ramo				,
		estatus_poliza		,
		tipo_clasificacion	,
		nueva_renov			,
		prima_bruta			,
		prima_neta			,
		prima_suscrita		,
		prima_retenida		,
		prima_cedida		,
		prima_cobrada		,
		prima_neta_cob		,
		prima_cobrada_ret	,
		prima_cobrada_ced,
		desc_clasif,
		categoria_contable,
		segm_triangulo)
values	(_anio,
		_no_poliza,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_cod_ramo,
		_nom_ramo,
		_estatus_poliza,
		_clasificacion,
		_nueva_renov,
		_prima_bruta,
		_prima_neta,
		_prima_suscrita,
		_prima_retenida,
		_prima_cedida,
		_monto_cob,
		_prima_neta_cob,
		_prima_cob_ret,
		_prima_cob_cedida,
		_desc_clasif,
		_categoria_contable,
		_segm_triangulo
		);
end foreach

return 0,0,'Carga Exitosa';

end
end procedure;