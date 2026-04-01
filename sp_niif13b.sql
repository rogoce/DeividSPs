-- Procedure de Generación del detalle GoCs para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif012('2021-01','2021-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif13b;
create procedure sp_niif13b(a_no_poliza char(10),a_no_reclamo char(10),a_no_tranrec char(10),a_tipo smallint)
returning	varchar(10)		as no_poliza,
			varchar(50)		as desc_clasif,
			varchar(50)		as categoria_contable,
			varchar(50)		as segm_triangulo;

define _error_desc			varchar(100);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _no_documento		char(20);
define _cod_grupo			char(5);
define _no_unidad			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _cat_subramo			char(2);
define _cat_ramo			char(2);
define _cat1				char(2);
define _cat2				char(2);
define _cat3				char(2);
define _cat4				char(2);
define _cat5				char(2);
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _fronting			smallint;
define _cnt_cob				integer;
define _error				integer;
define _error_isam			integer;
define _porc_partic_prima	dec(9,6);
define _porc_facultativo	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);

set isolation to dirty read;


let _categoria_contable = '';
let _segm_triangulo = '';
let _desc_clasif = '';
let _cat5 = '04';

begin 
on exception set _error, _error_isam, _error_desc
	if a_no_poliza is null then
		let a_no_poliza = '';
	end if

	
	let _error_desc = 'poliza: ' || trim(a_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return a_no_poliza,
			'',
			'',
			'';
end exception


--set debug file to "sp_niif013.trc";
--trace on;

	select emi.no_documento,
		   emi.cod_ramo,
		   emi.cod_subramo,
		   emi.cod_grupo,
		   /*nif.cat1,
		   nif.cat2*/
		   nif.clave_ramo,
		   nif.clave_subramo,
		   nif.cat1_n,
		   nif.cat2_n
	  into _no_documento,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_grupo,
		   _cat_ramo,
		   _cat_subramo,
		   _cat1,
		   _cat2
	  from emipomae emi
	  left join deivid_tmp:sc_niif17 nif on nif.codramo = emi.cod_ramo and nif.codsubramo = emi.cod_subramo
	 where emi.no_poliza = a_no_poliza;

	if _cod_grupo in ('00000','1000') then
		let _cat3 = '02';
	else
		let _cat3 = '01';
	end if
	
	if a_no_reclamo is not null and a_no_reclamo <> '' then
		select no_unidad
		  into _no_unidad
		  from recrcmae rec 
		 where no_reclamo = a_no_reclamo;	
	else
		foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = a_no_poliza
			exit foreach;
		end foreach
	end if

	if _cod_ramo = '020' then
		let _desc_clasif = 'RESPONSABILIDAD CIVIL DE VEHICULOS INDIVIDUAL';
		let _segm_triangulo = 'AUTO INDIVIDUAL';
	elif _cod_ramo in ('002','023') then
		if a_tipo = 1 then -- Busqueda Por Poliza
			select count(*)
			  into _cnt_cob
			  from emipocob
			 where no_poliza = a_no_poliza
			   and prima_neta <> 0
			   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222',
									 '01299','01300','01301','01302','01303','01304','01305','01306','01307','01308','01309','01310','01311','01312','01313',
									 '01314','01315','01322','01323','01324','01325','01326','01327','01338','01341','01376','01536','01578','01657','01677',
									 '01816');
		elif a_tipo = 2 then -- Busqueda por Transaccion de Reclamo
			
			select count(*)
			  into _cnt_cob
			  from rectrcob
			 where no_tranrec = a_no_tranrec
			   and monto <> 0
			   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222',
									 '01299','01300','01301','01302','01303','01304','01305','01306','01307','01308','01309','01310','01311','01312','01313',
									 '01314','01315','01322','01323','01324','01325','01326','01327','01338','01341','01376','01536','01578','01657','01677',
									 '01816');
		end if

		if _cnt_cob is null then
			let _cnt_cob = 0;
		end if
		
		if _cnt_cob = 0 then
			if _cod_ramo = '002' then
				let _desc_clasif = 'RESPONSABILIDAD CIVIL DE VEHICULOS INDIVIDUAL';
				let _segm_triangulo = 'AUTO INDIVIDUAL';
				if _cat1 = '17' then
					let _cat2 = '24';
				else
					let _cat2 = '26';
				end if
			else
				let _desc_clasif = 'RESPONSABILIDAD CIVIL DE VEHICULOS COLECTIVO';
				let _segm_triangulo = 'AUTO COLECTIVO';
				if _cat1 = '17' then
					let _cat2 = '24';
				else
					let _cat2 = '26';
				end if
			end if
		else
			if _cod_ramo = '002' then
				let _desc_clasif = 'AUTOMOVIL COMPLETA INDIVIDUAL';
				let _segm_triangulo = 'AUTO INDIVIDUAL';
				if _cat1 = '17' then
					let _cat2 = '23';
				else
					let _cat2 = '25';
				end if
			else
				let _desc_clasif = 'AUTOMOVIL COMPLETA COLECTIVO';
				let _segm_triangulo = 'AUTO COLECTIVO';
				if _cat1 = '17' then
					let _cat2 = '23';
				else
					let _cat2 = '25';
				end if
			end if
		end if
	elif _cod_ramo in ('018') then
		
		/*select mae.fecha,
			   det.date_added
		  into _fecha_ocurr,
			   _fecha_decl
		  from rectrmae trx
		 inner join atcdocde det on det.cod_asignacion = trx.cod_asignacion
		 inner join atcdocma mae on mae.cod_entrada = det.cod_entrada
		 where no_tranrec = _no_tranrec;

		if _fecha_ocurr is not null then
			let _fecha_ocurrencia = _fecha_ocurr;
		end if
		
		if _fecha_decl is not null then
			let _fecha_declaracion = _fecha_decl;
		end if*/


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
		elif _cod_ramo in ('019') then
		let _desc_clasif = 'VIDA Y AP INDIVIDUAL';	
		let _segm_triangulo = 'VIDA';		
	elif _cod_ramo in ('016') then
		let _desc_clasif = 'VIDA Y AP COLECTIVO';
		let _segm_triangulo = 'VIDA';
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
	
	let _porc_partic_prima = 0.00;
	let _porc_facultativo = 0.00;
	let _porc_retencion = 0.00;
	let _porc_fronting = 0.00;
	let _porc_cedido = 0.00;
	
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;
	
	foreach
		select distinct mae.tipo_contrato,
			   emi.porc_partic_prima,
			   mae.fronting
		  into _tipo_contrato,
			   _porc_partic_prima,
			   _fronting
		  from emireaco emi
		 inner join reacomae mae on mae.cod_contrato = emi.cod_contrato
		 where emi.no_poliza = a_no_poliza
		   and emi.no_unidad = _no_unidad
		   and emi.no_cambio = _no_cambio

		if _fronting = 1 then
			let _porc_fronting = _porc_partic_prima;
		else
			if _tipo_contrato = 1 then
				let _porc_retencion = _porc_partic_prima;
			elif _tipo_contrato = 3 then
				let _porc_facultativo = _porc_partic_prima;
			elif _tipo_contrato in (5,7) then
				let _porc_cedido = _porc_partic_prima;
			end if	
		end if
	end foreach
	
	if _porc_retencion = 100 and _cod_ramo = '018' then
		let _cat4 = '02';
	elif _porc_retencion = 100 and _cod_ramo <> '018' then
		let _cat4 = '04';
	elif _porc_facultativo = 100 or  _porc_fronting = 100 then
		let _cat4 = '01';
	elif _porc_facultativo + _porc_fronting not in(0,200) then
		let _cat4 = '03';
	else
		let _cat4 = '02';
	end if
	
	let _categoria_contable = _cat_ramo || '-' || _cat_subramo|| '-' || _cat1 ||'-'|| _cat2; -- ||'-'|| _cat3 ||'-'|| _cat4||'-' || _cat5;
	
	return	a_no_poliza,
			_desc_clasif,
			_categoria_contable,
			_segm_triangulo;
end
end procedure;