-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif012('2021-01','2021-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif012;
create procedure sp_niif012(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as error_desc;

define _error_desc			char(50);
define _estatus_recl		varchar(20);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _nom_subramo			varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _no_remesa			char(10);
define _nueva_renov			char(10);
define _no_poliza			char(10);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _periodo				char(7);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _clasificacion		smallint;
define _anio_cobro_desde	smallint;
define _anio_cobro_hasta	smallint;
define _anio_cobro			smallint;
define _fronting			smallint;
define _cnt_cob				smallint;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_salud			date;
define _fecha_cobro			date;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _prima_devengada		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _monto_pag			dec(16,2);
define _porc_coas			dec(9,6);

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


drop table if exists fichero_cobros_niif;
create temp table fichero_cobros_niif(
no_poliza				char(10),--
no_documento			char(20),--
categoria_contable		varchar(50),
segm_triangulo			varchar(50),
tipo_clasificacion		varchar(50),
vigencia_inic			date,--
vigencia_final			date,--
cod_ramo				char(3),--
ramo					varchar(50),
cod_subramo				char(3),--
subramo					varchar(50),
no_remesa				char(10),
renglon					integer,
cod_grupo				char(5),
nom_grupo				varchar(50),
nueva_renov				char(10),
prima_cobrada			dec(16,2) default 0.00,
prima_devengada			dec(16,2) default 0.00,
fecha_cobro				date,
periodo					char(7),
primary key (no_remesa,renglon)) with no log;

drop table if exists tmp_polizas;
create temp table tmp_polizas(
no_poliza				char(10),--
no_documento			char(20),--
vigencia_inic			date,--
vigencia_final			date,--
primary key (no_poliza,vigencia_inic,vigencia_final)) with no log;

--drop table if exists tmp_sinis;
let _cod_coasegur = '036';
drop table if exists tmp_codigos;
let _tipo = sp_sis04(a_cod_ramo);

FOREACH
	select cob.no_remesa,
		   cob.renglon,
		   cob.fecha,
		   cob.no_poliza,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   case emi.nueva_renov when 'N' then 'NUEVA' when 'R' then 'RENOVACION' end,
		   emi.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   emi.cod_grupo,
		   grp.nombre,
		   cob.monto,
		   cob.periodo
	  into _no_remesa,
		   _renglon,
		   _fecha_cobro,
		   _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _nueva_renov,
		   _cod_ramo,
		   _nom_ramo,
		   _cod_subramo,
		   _nom_subramo,
		   _cod_grupo,
		   _nom_grupo,
		   _monto_pagado,
		   _periodo
	  from cobredet cob
	 inner join emipomae emi on emi.no_poliza = cob.no_poliza
	 inner join tmp_codigos tmp on tmp.codigo = emi.cod_ramo
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 where cob.tipo_mov in ('P','N')
	   and cob.actualizado  = 1
	   and cob.periodo between a_periodo_desde and a_periodo_hasta
	--   and trx.numrecla = '02-0121-00099-01'

	let _categoria_contable = '';
	let _segm_triangulo = '';
	let _desc_clasif = '';
	
	if _cod_ramo = '020' then
		let _clasificacion = 2;
		let _desc_clasif = 'RESPONSABILIDAD CIVIL DE VEHICULOS INDIVIDUAL';
		let _segm_triangulo = 'AUTO INDIVIDUAL';
	elif _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_cob
		  from emipocob
		 where no_poliza = _no_poliza
		   and prima_neta <> 0
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
				let _desc_clasif = 'RESPONSABILIDAD CIVIL DE VEHICULOS INDIVIDUAL';
				let _segm_triangulo = 'AUTO INDIVIDUAL';
			else
				let _clasificacion = 4;
				
			end if
		else
			if _cod_ramo = '002' then
				let _clasificacion = 1;
				let _desc_clasif = 'AUTOMOVIL COMPLETA INDIVIDUAL';
				let _segm_triangulo = 'AUTO INDIVIDUAL';
			else
				let _clasificacion = 3;
				let _desc_clasif = 'AUTOMOVIL COMPLETA COLECTIVO';
				let _segm_triangulo = 'AUTO COLECTIVO';
				
			end if
		end if
	elif _cod_ramo in ('018') then
		let _anio_cobro = year(_fecha_cobro);
		let _fecha_salud = mdy(month(_vigencia_inic),day(_vigencia_inic),_anio_cobro);
		
		if _fecha_salud > _fecha_cobro then
			let _vigencia_inic = _fecha_salud - 1 units year;
			let _vigencia_final = _fecha_salud;
		else
			let _vigencia_inic = _fecha_salud;
			let _vigencia_final = _fecha_salud + 1 units year;
		end if
		if _cod_subramo = '012' then
			let _desc_clasif = 'SALUD COLECTIVO';
			let _segm_triangulo = 'SALUD COLECTIVO';
		else
			let _desc_clasif = 'SALUD INDIVIDUAL';
			let _segm_triangulo = 'SALUD INDIVIDUAL';
		end if
	elif _cod_ramo = '004' then
		if _cod_subramo in ('006','007','008') then
			let _desc_clasif = 'VIDA Y AP COLECTIVO';
			let _segm_triangulo = 'ACCIDENTE';
		else
			let _desc_clasif = 'VIDA Y AP INDIVIDUAL';
			let _segm_triangulo = 'ACCIDENTE';
		end if
	elif _cod_ramo = '008' then
		let _desc_clasif = 'FIANZA';		
		let _segm_triangulo = 'SIN CLASIFICACION';
	elif _cod_ramo in ('001','003') then
		let _desc_clasif = 'INCENDIO - TERREMOTO';
		let _segm_triangulo = 'INCENDIO';		
/*	elif _cod_ramo in ('019') then
		let _desc_clasif = 'VIDA Y AP INDIVIDUAL';	
		let _segm_triangulo = 'ACCIDENTE';		*/
	elif _cod_ramo in ('016') then
		let _desc_clasif = 'VIDA Y AP COLECTIVO';
		let _segm_triangulo = 'ACCIDENTE';
	elif _cod_ramo in ('007','010','011','012','013','014','022') then
		let _desc_clasif = 'RAMOS TECNICOS';
		let _segm_triangulo = 'RAMOS TECNICOS';
	elif _cod_ramo = '006' then
		let _desc_clasif = 'RESPONSABILIDAD CIVIL';
		let _segm_triangulo = 'RESPONSABILIDAD CIVIL';
	elif _cod_ramo = '005' then
		let _desc_clasif = 'ROBO';
		let _segm_triangulo = 'SIN CLASIFICACION';
	elif _cod_ramo = '009' then
		let _desc_clasif = 'TRANSPORTE';
		let _segm_triangulo = 'OTRO RAMO';
	elif _cod_ramo = '017' then
		let _desc_clasif = 'CASCO NAVES';
		let _segm_triangulo = 'OTRO RAMO';
	elif _cod_ramo = '015' then
		let _desc_clasif = 'RIESGOS DIVERSOS';
		let _segm_triangulo = 'RAMOS TECNICOS';
	elif _cod_ramo = '021' then
		let _desc_clasif = 'TODO RIESGO';
		let _segm_triangulo = 'RAMOS TECNICOS';
	end if
	
	let _porc_coas = 100;
	
	-- Informacion de Coaseguro
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
	let _pagado_bruto = _monto_pagado / 100 * _porc_coas;
	
	begin
		on exception in (-239)			
		end exception
		
		insert into tmp_polizas(
				no_poliza,
				no_documento,
				vigencia_inic,
				vigencia_final)
		values (_no_poliza,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final);
	end 
	
	begin
		on exception in (-239)
			update fichero_cobros_niif
			   set monto_pag = monto_pag + _pagado_bruto
			 where no_remesa = _no_remesa
			   and renglon = _renglon;
		end exception

		insert into fichero_cobros_niif(
					no_poliza,
					no_documento,
					categoria_contable,
					tipo_clasificacion,
					segm_triangulo,
					vigencia_inic,
					vigencia_final,
					cod_ramo,
					ramo,
					cod_subramo,
					subramo,
					no_remesa,
					renglon,
					cod_grupo,
					nom_grupo,
					nueva_renov,
					prima_cobrada,
					prima_devengada,
					fecha_cobro,
					periodo)
			values( _no_poliza,
					_no_documento,
					_categoria_contable,
					_desc_clasif,
					_segm_triangulo,
					_vigencia_inic,
					_vigencia_final,
					_cod_ramo,
					_nom_ramo,
					_cod_subramo,
					_nom_subramo,
					_no_remesa,
					_renglon,
					_cod_grupo,
					_nom_grupo,
					_nueva_renov,
					_pagado_bruto,
					0,
					_fecha_cobro,
					_periodo);
	end
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

return 0,0,'Carga Exitosa';

end
end procedure;