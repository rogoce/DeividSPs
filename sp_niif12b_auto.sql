-- Procedure de Generación del detalle de Pasivo por Cobertura Restante para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif012b('2026-01','2026-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif12b_auto;
create procedure sp_niif12b_auto(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning 	varchar(50) as concat,					
			char(10) as no_poliza,--			
			char(5) as no_endoso,--
			char(20) as no_documento,--
			varchar(50) as categoria_contable,
			varchar(50) as segm_triangulo,
			varchar(50) as tipo_clasificacion,
			varchar(50) as tipo_reas,
			varchar(50) as reasegurador,
			date as vigencia_inic,--
			date as vigencia_final,--
			date as vigencia_inic_end,--
			date as vigencia_final_end,--
			date as fecha_emis_endoso,--
			date as fecha_suscripcion,--
			char(3) as cod_ramo,--
			varchar(50) as ramo,
			char(3) as cod_subramo,--
			varchar(50) as subramo,
			char(10) as nueva_renov,
			dec(16,2) as prima_cobrada,
			dec(16,2) as suma_asegurada,
			date as fecha_cobro,  
			char(7) as periodo;	


define _error_desc			char(50);
define _estatus_recl			varchar(20);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _reasegurador_ret		varchar(50);
define _segm_triangulo		varchar(50);
define _reasegurador			varchar(50);
define _nom_subramo			varchar(50);
define _nom_grupo				varchar(50);
define _tipo_reas				varchar(50);
define _nom_ramo				varchar(50);
define _concat					varchar(50);
define _no_documento		char(20);
define _no_remesa			char(10);
define _nueva_renov			char(10);
define _no_poliza			char(10);
define _cod_cober_reas		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_grupo			char(5);
define _cod_coasegur_ret	char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _periodo_end			char(7);
define _periodo				char(7);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _clasificacion		smallint;
define _tipo_contrato		smallint;
define _anio_cobro_desde	smallint;
define _anio_cobro_hasta	smallint;
define _anio_cobro			smallint;
define _mes_periodo			smallint;
define _mes_vig				smallint;
define _fronting			smallint;
define _imp_gob				smallint;
define _cnt_cob				smallint;
define _vigencia_fin_endoso	date;
define _fecha_emision_end	date;
define _fecha_suscripcion	date;
define _fecha_suspension	date;
define _vigencia_endoso		date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_salud			date;
define _fecha_cobro			date;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _impuesto_rea		dec(16,2);
define _impuesto_seg		dec(16,2);
define _comision_agt		dec(16,2);
define _comision_rea		dec(16,2);
define _pagado_bruto_rea	dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_aseg_rea		dec(16,2);
define _prima_devengada		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _monto_pag			dec(16,2);
define _porc_coas			dec(9,6);
define _porc_cont_partic	dec(9,6);
define _porc_comis_agt		dec(9,6);
define _porc_comis_rea		dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto_fac	dec(9,6);
define _porc_impuesto_rea	dec(9,6);
define _porc_impuesto_seg	dec(9,6);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
--	if _no_poliza is null then
--		let _no_poliza = '';
--	end if
	
--	if _no_documento is null then
--		let _no_documento = '';
--	end if
	
--	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
--	return _error,
--		   _error_isam,
--		   _error_desc;
end exception


--set debug file to "sp_pro545.trc";
--trace on;


drop table if exists fichero_cobros_niif;
create temp table fichero_cobros_niif(
no_poliza				char(10),--
no_endoso				char(5),--
no_documento			char(20),--
categoria_contable		varchar(50),
segm_triangulo			varchar(50),
tipo_clasificacion		varchar(50),
reasegurador			varchar(50),
vigencia_inic			date,--
vigencia_final			date,--
vigencia_inic_end		date,--
vigencia_final_end		date,--
fecha_emis_endoso		date,--
fecha_suscripcion		date,--
cod_ramo				char(3),--
ramo					varchar(50),
cod_subramo				char(3),--
subramo					varchar(50),
no_remesa				char(10),
renglon					integer,
cod_grupo				char(5),
nom_grupo				varchar(50),
nueva_renov				char(10),
tipo_reas				varchar(50),
prima_cobrada			dec(16,2) default 0.00,
prima_devengada			dec(16,2) default 0.00,
impuesto_seg			dec(16,2) default 0.00,
impuesto_rea			dec(16,2) default 0.00,
comision_agt			dec(16,2) default 0.00,
comision_rea			dec(16,2) default 0.00,
suma_asegurada			dec(16,2) default 0.00,
fecha_cobro				date,
periodo					char(7),
primary key (no_poliza,no_endoso,reasegurador,tipo_reas)) with no log;

drop table if exists tmp_polizas;
create temp table tmp_polizas(
no_poliza				char(10),--
no_endoso				char(5),--
no_documento			char(20),--
cod_ramo				char(3),--
categoria_contable		varchar(50),--
prima_cobrada			dec(16,2) default 0.00,
suma_asegurada			dec(16,2) default 0.00,
porc_partic				dec(9,6) default 0.00,
primary key (no_poliza,no_endoso)) with no log;


drop table if exists tmp_ramo;
create temp table tmp_ramo(
cod_ramo				char(3),--
ramo					varchar(50),--
categoria_contable		varchar(50),--
prima_cobrada			dec(16,2) default 0.00,
porc_partic				dec(9,6) default 0.00,
primary key (cod_ramo,categoria_contable)) with no log;

--drop table if exists tmp_sinis;
let _cod_coasegur_ret = '036';
drop table if exists tmp_codigos;
let _tipo = sp_sis04(a_cod_ramo);
let _fecha_cobro = sp_sis36(a_periodo_desde);
let _periodo = a_periodo_desde[1,4];--'2025';

select nombre
  into _reasegurador_ret
  from emicoase
 where cod_coasegur = _cod_coasegur_ret;

FOREACH
	select cob.no_poliza,
		   cob.no_endoso,
		   emi.no_documento,
		   rea.no_unidad,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   case emi.nueva_renov when 'N' then 'NUEVA' when 'R' then 'RENOVACION' end,
		   emi.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   emi.cod_grupo,
		   grp.nombre,
		   con.cod_contrato,
		   con.tipo_contrato,--case con.tipo_contrato when 1 then 'No Cedido' else 'Cedido' end,
		   cob.vigencia_inic,
		   cob.vigencia_final,
		   cob.fecha_emision,
		   emi.fecha_suscripcion,
		   rea.cod_cober_reas,
		   cob.periodo,
		   sum(rea.prima),
		   sum(rea.suma_asegurada)
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,
		   _no_unidad,
		   _vigencia_inic,
		   _vigencia_final,
		   _nueva_renov,
		   _cod_ramo,
		   _nom_ramo,
		   _cod_subramo,
		   _nom_subramo,
		   _cod_grupo,
		   _nom_grupo,
		   _cod_contrato,
		   _tipo_contrato,--_tipo_reas,
		   _vigencia_endoso,
		   _vigencia_fin_endoso,		   
		   _fecha_emision_end,
		   _fecha_suscripcion,
		   _cod_cober_reas,
		   _periodo_end,
		   _monto_pagado,
		   _suma_asegurada
	  from endedmae cob--deivid_cob:cobmoros2 cob
	 inner join endeduni uni on uni.no_poliza = cob.no_poliza and cob.no_endoso = uni.no_endoso
	 inner join emipomae emi on emi.no_poliza = cob.no_poliza
	 inner join emifacon rea on rea.no_poliza = uni.no_poliza and rea.no_endoso = uni.no_endoso and rea.no_unidad = uni.no_unidad
	 inner join reacomae con on con.cod_contrato = rea.cod_contrato
	 inner join tmp_codigos tmp on tmp.codigo = emi.cod_ramo
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join deivid_tmp:tmp_fact_vig aut on aut.no_factura = cob.no_factura
	 where cob.actualizado = 1
	   --and cob.no_documento in ('1621-00023-01','1621-00024-01','1621-00025-01','1621-00026-01','1621-00027-01','1621-00028-01','1621-00029-01','1621-00030-01')
	 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
	 having sum(rea.prima) <> 0

	let _categoria_contable = '';
	let _segm_triangulo = '';
	let _desc_clasif = '';
	
	call sp_niif13(_no_poliza,'','',1)
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;

	select porc_impuesto
	  into _porc_impuesto_rea
	  from reacocob
	 where cod_cober_reas = _cod_cober_reas
	   and cod_contrato = _cod_contrato;
	
	let _porc_coas = 100;
	let _impuesto_seg = 0.00;
	let _impuesto_rea = 0.00;
	let _comision_agt = 0.00;
	let _comision_rea = 0.00;
	
	/*-- Informacion de Coaseguro
	select porc_partic_coas
	  into _porc_coas
      from emicoama
     where no_poliza    = _no_poliza
       and cod_coasegur = _cod_coasegur;

	if _porc_coas is null then
		let _porc_coas = 100;
	end if

	-- Informacion de Reaseguro
	let _pagado_bruto = 0.00;

	-- Calculos
	let _pagado_bruto = _monto_pagado / 100 * _porc_coas;*/
	let _pagado_bruto = _monto_pagado;
	
	select imp_gob
	  into _imp_gob
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	if _imp_gob = 1 then
		let _porc_impuesto_seg = 2.00;
	else
		let _porc_impuesto_seg = 0.00;
	end if
	
	begin
		on exception in (-239)
			update tmp_polizas
			   set prima_cobrada = prima_cobrada + _monto_pagado
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
		end exception
		
		insert into tmp_polizas(
				no_poliza,
				no_endoso,			
				no_documento,
				cod_ramo,
				categoria_contable,
				prima_cobrada
				)
		values (_no_poliza,
			   _no_endoso,
			   _no_documento,
			   _cod_ramo,
			   _categoria_contable,
			   _monto_pagado
			   );
	end 
	
	begin
		on exception in (-239)
			update tmp_ramo
			   set prima_cobrada = prima_cobrada + _monto_pagado
			 where cod_ramo = _cod_ramo
			   and categoria_contable = _categoria_contable;
		end exception
		
		insert into tmp_ramo(
				cod_ramo,
				ramo,
				categoria_contable,
				prima_cobrada
				)
		values (_cod_ramo,
			   _nom_ramo,
			   _categoria_contable,
			   _monto_pagado
			   );
	end 
	
	if _tipo_contrato in (1) then
		let _tipo_reas = 'No Cedido';
	else
		let _tipo_reas = 'Cedido C';
	end if
	
	if _cod_ramo = '018' then			
		let _mes_vig = month(_vigencia_inic);
		let _mes_periodo = month(_vigencia_endoso);
		
		
		if _mes_vig > _mes_periodo then
			let _vigencia_inic = mdy(_mes_vig,day(_vigencia_inic),_periodo-1);
			
			if _vigencia_final > mdy(_mes_vig,day(_vigencia_inic),_periodo) then
				let _vigencia_final = mdy(_mes_vig,day(_vigencia_inic),_periodo);
			end if
		else
			let _vigencia_inic = mdy(_mes_vig,day(_vigencia_inic),_periodo);
			if _vigencia_final > mdy(_mes_vig,day(_vigencia_inic),_periodo) then
				let _vigencia_final = mdy(_mes_vig,day(_vigencia_inic),_periodo + 1);
			end if
		end if
	end if
	
	if _tipo_contrato = 1 then -- Retencion
		begin
			on exception in (-239)
				update fichero_cobros_niif
				   set prima_cobrada = prima_cobrada + _pagado_bruto,
					   suma_asegurada = suma_asegurada + _suma_asegurada
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and tipo_reas = _tipo_reas
				   and reasegurador = _reasegurador_ret;
			end exception

		insert into fichero_cobros_niif(
					no_poliza,
					no_endoso,
					no_documento,
					categoria_contable,
					tipo_clasificacion,
					segm_triangulo,
					reasegurador,
					vigencia_inic,
					vigencia_final,
					vigencia_inic_end,
					vigencia_final_end,
					fecha_emis_endoso,
					fecha_suscripcion,
					cod_ramo,
					ramo,
					cod_subramo,
					subramo,
					cod_grupo,
					nom_grupo,
					nueva_renov,
					tipo_reas,
					prima_cobrada,
					prima_devengada,
					fecha_cobro,
					periodo,
					suma_asegurada)
			values( _no_poliza,
					_no_endoso,
					_no_documento,
					_categoria_contable,
					_desc_clasif,
					_segm_triangulo,
					_reasegurador_ret,
					_vigencia_inic,
					_vigencia_final,
					_vigencia_endoso,
					_vigencia_fin_endoso,							
					_fecha_emision_end,
					_fecha_suscripcion,
					_cod_ramo,
					_nom_ramo,
					_cod_subramo,
					_nom_subramo,
					_cod_grupo,
					_nom_grupo,
					_nueva_renov,
					_tipo_reas,
					_pagado_bruto,
					0,
					_fecha_cobro,
					_periodo_end,
					_suma_asegurada);
		end		
	elif _tipo_contrato = 3 then -- Facultativo
		foreach
			select coa.nombre,
				   fac.prima,
				   fac.porc_impuesto,
				   fac.porc_comis_fac,
				   fac.suma_asegurada
			  into _reasegurador,
				   _pagado_bruto,
				   _porc_impuesto_fac,
				   _porc_comis_fac,
				   _suma_asegurada
			  from emifafac fac
			 inner join emicoase coa on coa.cod_coasegur = fac.cod_coasegur
			 where fac.no_poliza = _no_poliza
			   and fac.no_endoso = _no_endoso
			   and fac.no_unidad = _no_unidad
			   and fac.cod_cober_reas = _cod_cober_reas
			   and fac.cod_contrato = _cod_contrato

			let _tipo_reas = 'Cedido F';
			
			/*
			let _impuesto_rea = _pagado_bruto * (_porc_impuesto_fac/100);
			--let _comision_agt = _pagado_bruto * (_porc_comis_agt/100);
			let _comision_rea = _pagado_bruto * (_porc_comis_fac/100);
			*/
			
			begin
			on exception in (-239)
				update fichero_cobros_niif
				   set prima_cobrada = prima_cobrada + _pagado_bruto,
					   /*impuesto_rea = impuesto_rea + _impuesto_rea,
					   impuesto_seg = impuesto_seg + _impuesto_seg,
					   comision_agt = comision_agt + _comision_agt,
					   comision_rea = comision_rea + _comision_rea,*/
					   suma_asegurada = suma_asegurada + _suma_asegurada
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and tipo_reas = _tipo_reas
				   and reasegurador = _reasegurador;
			end exception

			insert into fichero_cobros_niif(
						no_poliza,
						no_endoso,
						no_documento,
						categoria_contable,
						tipo_clasificacion,
						segm_triangulo,
						reasegurador,
						vigencia_inic,
						vigencia_final,
						vigencia_inic_end,
						vigencia_final_end,					
						fecha_emis_endoso,
						fecha_suscripcion,
						cod_ramo,
						ramo,
						cod_subramo,
						subramo,
						cod_grupo,
						nom_grupo,
						nueva_renov,
						tipo_reas,
						prima_cobrada,
						prima_devengada,
						/*impuesto_seg,
						impuesto_rea,
						comision_agt,
						comision_rea,*/
						fecha_cobro,
						periodo,
						suma_asegurada)
				values( _no_poliza,
						_no_endoso,
						_no_documento,
						_categoria_contable,
						_desc_clasif,
						_segm_triangulo,
						_reasegurador,
						_vigencia_inic,
						_vigencia_final,
						_vigencia_endoso,
						_vigencia_fin_endoso,
						_fecha_emision_end,
						_fecha_suscripcion,
						_cod_ramo,
						_nom_ramo,
						_cod_subramo,
						_nom_subramo,
						_cod_grupo,
						_nom_grupo,
						_nueva_renov,
						_tipo_reas,
						_pagado_bruto,
						0,
						/*0,
						_impuesto_rea,
						_comision_agt,
						_comision_rea,*/
						_fecha_cobro,
						_periodo_end,
						_suma_asegurada);
			end
		end foreach
	else
		foreach
			select coa.cod_coasegur,
				   ase.nombre,
				   coa.porc_cont_partic,
				   coa.porc_comision
			  into _cod_coasegur,
				   _reasegurador,
				   _porc_cont_partic,
				   _porc_comis_rea
			  from reacoase coa
			 inner join emicoase ase on ase.cod_coasegur = coa.cod_coasegur
			 where coa.cod_contrato = _cod_contrato
			   and coa.cod_cober_reas = _cod_cober_reas

			if _cod_coasegur = '036' then
				let _tipo_reas = 'No Cedido';
			else
				let _tipo_reas = 'Cedido C';
			end if

			let _pagado_bruto_rea = _pagado_bruto * (_porc_cont_partic/100);
			let _suma_aseg_rea = _suma_asegurada * (_porc_cont_partic/100);
			--let _comision_rea = _pagado_bruto_rea * (_porc_comis_rea/100);
			--let _impuesto_rea = _pagado_bruto_rea * (_porc_impuesto_rea/100);
			--let _comision_agt = _pagado_bruto_rea * (_porc_comis_agt/100);
		
			begin
			on exception in (-239)
				update fichero_cobros_niif
				   set prima_cobrada = prima_cobrada + _pagado_bruto_rea,
					   /*impuesto_rea = impuesto_rea + _impuesto_rea,
					   impuesto_seg = impuesto_seg + _impuesto_seg,
					   comision_agt = comision_agt + _comision_agt,
					   comision_rea = comision_rea + _comision_rea,*/
					   suma_asegurada = suma_asegurada + _suma_aseg_rea
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and tipo_reas = _tipo_reas
				   and reasegurador = _reasegurador;
			end exception

			insert into fichero_cobros_niif(
						no_poliza,
						no_endoso,
						no_documento,
						categoria_contable,
						tipo_clasificacion,
						segm_triangulo,
						reasegurador,
						vigencia_inic,
						vigencia_final,
						vigencia_inic_end,
						vigencia_final_end,					
						fecha_emis_endoso,
						fecha_suscripcion,					
						cod_ramo,
						ramo,
						cod_subramo,
						subramo,
						cod_grupo,
						nom_grupo,
						nueva_renov,
						tipo_reas,
						prima_cobrada,
						prima_devengada,
						fecha_cobro,
						periodo,
						suma_asegurada)
				values( _no_poliza,
						_no_endoso,
						_no_documento,
						_categoria_contable,
						_desc_clasif,
						_segm_triangulo,
						_reasegurador,
						_vigencia_inic,
						_vigencia_final,
						_vigencia_endoso,
						_vigencia_fin_endoso,
						_fecha_emision_end,
						_fecha_suscripcion,
						_cod_ramo,
						_nom_ramo,
						_cod_subramo,
						_nom_subramo,
						_cod_grupo,
						_nom_grupo,
						_nueva_renov,
						_tipo_reas,
						_pagado_bruto_rea,
						0,
						_fecha_cobro,
						_periodo_end,
						_suma_aseg_rea);
			end
		end foreach
	end if
end foreach
/*
foreach
	select no_poliza,
		   no_documento,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final
	  from tmp_polizas

	call sp_dev06(_no_documento,_vigencia_final) returning _error,_error_desc,_cubierto_hasta,_fecha_suspension;

	select sum(prima_diaria)
	  into _prima_devengada
	  from tmp_consumo_prima
	 where no_documento = _no_documento
	   and fecha between _vigencia_inic and _vigencia_final;
	
	update fichero_cobros_niif
	   set prima_devengada = _prima_devengada
	 where no_poliza = _no_poliza
	   and vigencia_inic = _vigencia_inic
	   and vigencia_final = _vigencia_final;
end foreach*/

foreach 
	select  no_poliza,
            no_endoso,
		    no_documento,
		    categoria_contable,
		    segm_triangulo,
		    tipo_clasificacion,
		    reasegurador,
			vigencia_inic,
			vigencia_final,
			vigencia_inic_end,
			vigencia_final_end,
			fecha_emis_endoso,
			fecha_suscripcion,
			cod_ramo,
			ramo,
			cod_subramo,
			subramo,
			no_remesa,
			renglon,
			cod_grupo,
			nom_grupo,
			nueva_renov,
			tipo_reas,
			prima_cobrada,
			prima_devengada,
			/*impuesto_seg,
			impuesto_rea,
			comision_agt,
			comision_rea,*/
			suma_asegurada,
			fecha_cobro,
			periodo
	INTO 	_no_poliza,
			_no_endoso,
			_no_documento,
			_categoria_contable,
			_segm_triangulo,
			_desc_clasif,
			_reasegurador,
  		    _vigencia_inic,
			_vigencia_final,
			_vigencia_endoso,
			_vigencia_fin_endoso,
			_fecha_emision_end,
			_fecha_suscripcion,
			_cod_ramo,
			_nom_ramo,
			_cod_subramo,
			_nom_subramo,
			_no_remesa,
			_renglon,
			_cod_grupo,
			_nom_grupo,
			_nueva_renov,
			_tipo_reas,
			_pagado_bruto_rea,
			_prima_devengada,
			/*_impuesto_rea,
			_impuesto_seg,
			_comision_agt,
			_comision_rea,*/
			_suma_aseg_rea,
			_fecha_cobro,
			_periodo_end
	FROM 	fichero_cobros_niif
	
	let _concat = trim(_no_poliza) || '_' || trim(_no_endoso) || '_' || trim(_no_documento);
	
	RETURN _concat,
			_no_poliza,
			_no_endoso,
			_no_documento,
			_categoria_contable,
			_segm_triangulo,
			_desc_clasif,
			_tipo_reas,
			_reasegurador,
  		    _vigencia_inic,
			_vigencia_final,
			_vigencia_endoso,
			_vigencia_fin_endoso,			
			_fecha_emision_end,
			_fecha_suscripcion,
			_cod_ramo,
			_nom_ramo,
			_cod_subramo,
			_nom_subramo,
			_nueva_renov,
			_pagado_bruto_rea,
			_suma_aseg_rea,
			_fecha_cobro,
			_periodo_end WITH RESUME;
END FOREACH
--return 0,0,'Carga Exitosa';

end
end procedure;