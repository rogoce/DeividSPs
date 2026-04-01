-- Proceso que genera la información del Archivo de Pólizas Nuevas y Renovaciones de Ducruet (Excepto Auto, Soda y Fianzas)
-- Creado    : 15/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro373;

create procedure "informix".sp_pro373()
returning integer,
		  smallint,
		  char(30),
          char(100);

define _deducible			varchar(50);
define _nom_prod			varchar(50);
define _email				varchar(50);
define _primer_nom			varchar(40);
define _segundo_nom			varchar(40);
define _primer_ape			varchar(40);
define _segundo_ape			varchar(40);
define _pasaporte			varchar(30);
define _cedula				varchar(30);
define _ruc					varchar(30);
define _desc_unidad			char(512);
define _error_desc			char(100);
define _descripcion			char(81);
define _nom_acre			char(50);
define _campo				char(30);
define _no_documento		char(21);
define _cod_manzana			char(15);
define _cod_cobertura_agt	char(10);
define _cod_producto_agt	char(10);
define _cod_contratante		char(10);
define _cod_acre_agt		char(10);
define _cod_acreedor		char(10);
define _cod_producto		char(10);
define _cod_perpago			char(10);
define _no_poliza			char(10);
define _cod_color			char(10);
define _tel_res				char(10);
define _tel_ofi				char(10);
define _celular				char(10);
define _tipo				char(6);
define _cod_cobertura		char(5);
define _no_unidad			char(5);
define _cod_impuesto		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tipo_persona		char(1);
define _nueva_renov			char(1);
define _porc_descuento		dec(5,2);
define _porc_impuesto		dec(5,2);
define _fact_imp			dec(5,2);
define _suma_aseg_edif		dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_aseg_cont		dec(16,2);
define _suma_aseg_uni		dec(16,2);
define _deducible_dec		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta	   		dec(16,2);
define _prima_cob			dec(16,2);
define _descuento			dec(16,2);
define _impuesto			dec(16,2);
define _recargo				dec(16,2);
define _limite1				dec(16,2);
define _limite2				dec(16,2);
define _prima		   		dec(16,2);
define _tipo_incendio		smallint;
define _es_pasaporte		smallint;
define _cnt_unidades		smallint;
define _cnt_existe			smallint;
define _tipo_cober			smallint;
define _return				smallint;
define _no_pagos			smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_proceso		date;
define _vigencia_final		date;

--set debug file to "sp_pro373.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	drop table tmp_cober;
	drop table tmp_uni;
	return _error,_error_isam,"Error al Cargas las Tablas para la Generación de la Estructura de Otros Riesgos. ", _error_desc;
end exception

create temp table tmp_cober(
no_poliza			char(10),
no_unidad			char(5),
cod_cobertura_agt	char(10),
prima				dec(16,2),
limite1				dec(16,2),
limite2				dec(16,2),
deducible			dec(16,2),
desc_deducible		varchar(50)
) with no log;

create temp table tmp_uni(
no_poliza			char(10),
no_unidad			char(5),
cod_acreedor_agt	char(10),
nom_acreedor		varchar(50),
suma_asegurada		dec(16,2),
suma_aseg_edif		dec(16,2),
suma_aseg_cont		dec(16,2),
descripcion			char(512)
) with no log;

let _fecha_proceso	= current - 1 units day;
let _fecha_proceso	= '01/05/2013';
let _tipo			= 'POLIZA';
let _desc_unidad	= '';

foreach
	select no_documento,
		   e.no_poliza,
		   cod_ramo,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   no_pagos,
		   prima,
		   prima_neta,
		   prima_bruta,
		   descuento,
		   impuesto,
		   recargo,
		   nueva_renov,
		   suma_asegurada
	  into _no_documento,
		   _no_poliza,
		   _cod_ramo,
		   _cod_subramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_contratante,
		   _no_pagos,
		   _prima,
		   _prima_neta,
		   _prima_bruta,
		   _descuento,
		   _impuesto,
		   _recargo,
		   _nueva_renov,
		   _suma_asegurada
	  from emipomae e,emipoagt a
	 where e.no_poliza			= a.no_poliza
	   and a.cod_agente			= '00035'
	   and cod_ramo  in ('001')
	   and e.actualizado		= 1
	   and e.estatus_poliza		= 1
	   and fecha_suscripcion	> _fecha_proceso
	   and nueva_renov			= 'R'

	select count(*)
	  into _cnt_unidades
	  from emipouni
	 where no_poliza = _no_poliza;

	{if _cod_ramo = '001' then
		if _cnt_unidades > 2 then
			continue foreach;
		end if
	else}
		if _cnt_unidades > 1 then
			continue foreach;
		end if
	--end if

	let _porc_impuesto= 0.00;
	--Impuesto
	foreach
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = _no_poliza
		
		select factor_impuesto
		  into _fact_imp
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;
		
		let _porc_impuesto = _porc_impuesto + _fact_imp;
	end foreach

	let _porc_descuento = 0.00;

	select sum(porc_descuento)
	  into _porc_descuento
	  from emipolde
	 where no_poliza = _no_poliza;

	if _porc_descuento is null then
		let _porc_descuento = 0.00;
	end if
	-- Información del Cliente
	select aseg_primer_nom,
		   aseg_segundo_nom,
		   aseg_primer_ape,
		   aseg_segundo_ape,
		   tipo_persona,
		   pasaporte,
		   telefono1,
		   telefono2,
		   cedula,
		   celular,
		   e_mail
	  into _primer_nom,
		   _segundo_nom,
		   _primer_ape,
		   _segundo_ape,
		   _tipo_persona,
		   _es_pasaporte,
		   _tel_res,
		   _tel_ofi,
		   _cedula,
		   _celular,
		   _email
	  from cliclien
	 where cod_cliente = _cod_contratante;

	--Insercion del Maestro
	if _tipo_persona = 'J' then
		let _ruc = _cedula;
		let _cedula = '';
		let _pasaporte = '';
	else
		if _es_pasaporte = 1 then
			let _pasaporte = _cedula;
			let _cedula = '';
			let _ruc = '';
		else
			let _pasaporte = '';
			let _ruc = '';
		end if 
	end if	

	--Información de la Unidad
	foreach
		select no_unidad,
			   cod_producto,
			   cod_manzana,
			   suma_asegurada,
			   tipo_incendio
		  into _no_unidad,
			   _cod_producto,
			   _cod_manzana,
			   _suma_aseg_uni,
			   _tipo_incendio
		  from emipouni
		 where no_poliza = _no_poliza

		select nombre
		  into _nom_prod
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select cod_producto_agt
		  into _cod_producto_agt
		  from equiprod
		 where cod_agente = '00035'
		   and cod_ramo_ancon = _cod_ramo
		   and cod_subramo_ancon = _cod_subramo
		   and cod_producto_ancon = _cod_producto;

		if _cod_producto_agt is null or _cod_producto_agt = '' then
			let _cod_producto_agt = 'P/D';
		end if

		let _suma_aseg_edif = 0.00;
		let _suma_aseg_cont = 0.00;
		if _cod_ramo = '001' then	
			if _tipo_incendio = 1 then
				let _suma_aseg_edif = _suma_aseg_uni;
				let _suma_aseg_uni = 0.00;
				let _suma_aseg_cont = 0.00;
			elif _tipo_incendio = 2 then
				let _suma_aseg_cont = _suma_aseg_uni;
				let _suma_aseg_uni = 0.00;
				let _suma_aseg_edif = 0.00;
			end if
		end if

		let _desc_unidad = '';
		let _descripcion = '';
--Descripcion de la Unidad
		foreach
			select descripcion
			  into _descripcion
			  from blobuni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and no_endoso = '00000'
			
			if _descripcion is null or _descripcion = '' then
				continue foreach;
			end if
			
			let _desc_unidad = trim(_desc_unidad) || ' ' || trim(_descripcion);
		end foreach

		let _cod_acre_agt	= '';
		let _nom_acre		= '';
--Descripcion del Acreedor Hipotecario
		foreach
			select cod_acreedor
			  into _cod_acreedor
			  from emipoacr
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			
			select nombre
			  into _nom_acre
			  from emiacre
			 where cod_acreedor = _cod_acreedor;
			
			foreach
				select cod_acreedor_agt
				  into _cod_acre_agt
				  from equiacre
				 where cod_acreedor_ancon = _cod_acreedor
				   and cod_agente			= '00035'
				exit foreach;
			end foreach
		end foreach

		insert into tmp_uni(
				no_poliza,
				no_unidad,
				suma_asegurada,
				suma_aseg_edif,
				suma_aseg_cont,
				descripcion,
				cod_acreedor_agt,
				nom_acreedor)
		values	(_no_poliza,
				_no_unidad,
				_suma_aseg_uni,
				_suma_aseg_edif,
				_suma_aseg_cont,
				_desc_unidad,
				_cod_acre_agt,
				_nom_acre);				

-- Información de las Coberturas de la póliza
		foreach
			select cod_cobertura,
				   limite_1,
				   limite_2,
				   deducible,
				   prima_neta
			  into _cod_cobertura,
				   _limite1,
				   _limite2,
				   _deducible,
				   _prima_cob
			  from emipocob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			begin
				on exception in(-1213)
					let _deducible_dec = 0.00;
				end exception

				let _deducible_dec = cast(_deducible as dec(16,2));
				let _deducible = '';
			end
			{select cod_cobertura_agt
			  into _cod_cobertura_agt
			  from equicober
			 where cod_agente = '00035'
			   and cod_cobertura_ancon	= _cod_cobertura
			   and cod_ramo_ancon		= _cod_ramo
			   and cod_subramo_ancon	= _cod_subramo;
			
			if _cod_cobertura_agt is null or _cod_cobertura_agt = '' then
				let _cod_cobertura_agt = 'P/D';
			end if}

			insert into tmp_cober(
					no_poliza,
					no_unidad,
					cod_cobertura_agt,
					prima,
					deducible,
					limite1,
					limite2,
					desc_deducible)
			values	(_no_poliza,
					_no_unidad,
					_cod_cobertura,
					_prima_cob,
					_deducible_dec,
					_limite1,
					_limite2,
					_deducible);
		end foreach			
	end foreach

	insert into emiducm(
			no_poliza,
			no_documento,
			cod_ramo,
			vigencia_inic,
			vigencia_fin,
			nom_cliente,
			ape_cliente,
			seg_ape_cliente,
			cedula,
			pasaporte,
			ruc,
			tel_residencial,
			tel_oficina,
			celular,
			email,
			tipo_doc,
			prima_sin_descuento,
			monto_descuento,
			porc_descuento,
			prima,
			porc_impuesto,
			monto_impuesto,
			total_prima,
			no_pagos,
			cod_producto_agt,
			nom_producto,
			nueva_renov)
	values(	_no_poliza,
			_no_documento,
			_cod_ramo,
			_vigencia_inic,
			_vigencia_final,
			_primer_nom,
			_primer_ape,
			_segundo_ape,
			_cedula,
			_pasaporte,
			_ruc,
			_tel_res,
			_tel_ofi,
			_celular,
			_email,
			'Póliza',
			_prima,
			_descuento,
			_porc_descuento,
			_prima_neta,
			_porc_impuesto,
			_impuesto,
			_prima_bruta,
			_no_pagos,
			_cod_producto_agt,
			_nom_prod,
			_nueva_renov
			);	
end foreach

insert into emiducu
select no_poliza,
	   no_unidad,
	   suma_asegurada,
	   suma_aseg_edif,
	   suma_aseg_cont,
	   cod_acreedor_agt,
	   nom_acreedor,
	   descripcion
  from tmp_uni;

insert into emiducc
select no_poliza,
	   no_unidad,
	   cod_cobertura_agt,
	   limite1,
	   limite2,
	   prima,
	   deducible,
	   desc_deducible
  from tmp_cober;

drop table tmp_uni;
drop table tmp_cober;

return 0,0,'Carga de Datos Exitosa.','';
end
end procedure		   