-- Procedure que Crea el endoso de cambio de corredor masivamente
-- Creado		: 29/11/2012	- Autor: Roman Gordon

drop procedure sp_sis176;

create procedure "informix".sp_sis176()
returning char(20),			--_no_documento,   
		  char(5),			--_no_endoso,   
		  char(5),			--_cod_agente,   
		  date,				--_vigencia_inic,   
		  date;				--_vigencia_final,   

define _desc_unidad			varchar(50);
define _error_desc			char(200);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza	    	char(10);
define _user_added			char(8);
define _periodo				char(7);
define _cod_agente_new		char(5);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _cod_agente  		char(5);
define _no_endoso			char(5);
define _cod_ruta			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_tipocalc		char(3);
define _cod_formapag		char(3);
define _cod_endomov			char(3);
define _cod_perpago			char(3);
define _null				char(1);
define _porc_partic_agt		dec(16,2);
define _suma_asegurada		dec(16,2);
define _porc_comis_agt		dec(16,2);
define _beneficio_max		dec(16,2);
define _porc_produc			dec(16,2);
define _no_endoso_ent		smallint;
define _reasegurada			smallint;
define _procesado  			smallint;
define _no_pagos			smallint;
define _status				smallint;
define _error				integer;
define _vigencia_final_uni	date;
define _vigencia_final_pol	date;
define _vigencia_inic_uni	date;
define _vigencia_inic_pol	date;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

--set debug file to "sp_sis176.trc";
--trace on;

let _cod_agente_new	= '02082';
let _cod_compania	= '001';
let _cod_sucursal	= '001';
let _cod_tipocalc	= '007';
let _cod_endomov	= '012';
let _null			= null;
let _user_added		= 'informix';

let _fecha_hoy		= current;
let _periodo		= sp_sis39(_fecha_hoy);

foreach
	select poliza
	  into _no_documento
	  from deivid_tmp:tmp_rolkam
	 where procesada = 0

	let	_cod_producto		= '';
	let	_cod_formapag		= '';
	let	_cod_cliente		= '';		
	let	_desc_unidad		= '';
	let	_cod_perpago		= '';
	let	_error_desc			= '';
	let	_cod_agente			= '';
	let	_no_poliza			= '';
	let	_no_unidad			= '';
	let	_no_endoso			= '';
	let	_cod_ruta			= '';
	let _porc_partic_agt	= 0.00;
	let	_suma_asegurada		= 0.00;	
	let	_porc_comis_agt		= 0.00;
	let	_beneficio_max		= 0.00;
	let	_porc_produc		= 0.00;
	let _no_endoso_ent		= 0;
	let	_reasegurada		= 0;
	let	_procesado  		= 0;
	let	_no_pagos			= 0;
	let	_status				= 0;
	let	_error				= 0;
	   
	call sp_sis21(_no_documento) returning _no_poliza;
	
	if _no_poliza is null or _no_poliza = '' then
		update deivid_tmp:tmp_rolkam
		   set procesada = 2
		 where poliza = _no_documento;
		continue foreach;
	end if
	
	select estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_perpago,
		   cod_formapag,
		   fecha_primer_pago,
		   no_pagos
	  into _status,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_perpago,
		   _cod_formapag,
		   _fecha_primer_pago,
		   _no_pagos
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _status <> 1 then
		continue foreach;
	end if
	
	let _vigencia_final_pol = _vigencia_final;
	let _vigencia_inic_pol	= _vigencia_inic;
	
	if _vigencia_inic < '01/10/2012' then
		let _vigencia_inic = '01/10/2012';
	end if
	
	select cod_agente,
		   porc_partic_agt,
		   porc_comis_agt,
		   porc_produc
	  into _cod_agente,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _porc_produc
	  from emipoagt
	 where no_poliza = _no_poliza;
	 
	if _cod_agente = '02082' then
		update deivid_tmp:tmp_rolkam
		   set procesada = 2
		 where poliza = _no_documento;
		continue foreach;
	end if
			
	--REGRESA EL NUEVO NUMERO DE ENDOSO
	let _no_endoso		= sp_sis90(_no_poliza);
	let _no_endoso_ent	= _no_endoso + 1;
	let _no_endoso		= sp_set_codigo(5, _no_endoso_ent);
	
	insert into endedmae
			(no_poliza,				--663154
			no_endoso,				--00001
			cod_compania,			--001
			cod_sucursal,			--001
			cod_tipocalc,			--007
			cod_formapag,			--008
			cod_tipocan,			--null
			cod_perpago,			--002
			cod_endomov,			--012
			no_documento,			--0210-10123-20
			vigencia_inic,			--11/11/2012
			vigencia_final,			--11/11/2013
			prima,					--0
			descuento,				--0
			recargo,				--0
			prima_neta,				--0
			impuesto,				--0
			prima_bruta,			--0
			prima_suscrita,			--0
			prima_retenida,			--0
			tiene_impuesto,			--1
			fecha_emision,			--29/11/2012
			fecha_impresion,		--29/11/2012
			fecha_primer_pago,		--11/11/2012
			no_pagos,				--12
			actualizado,			--0
			no_factura,				--null
			fact_reversar,			--null
			date_added,				--29/11/2012
			date_changed,			--29/11/2012
			interna,				--0
			periodo,				--2012-11
			user_added,				--NBROWN
			factor_vigencia,		--0
			suma_asegurada,			--0
			posteado,				--0
			activa,					--null
			vigencia_inic_pol,		--11/11/2012
			vigencia_final_pol,		--11/11/2013
			no_endoso_ext,			--null
			cod_tipoprod,			--null
			cotizacion,				--null
			de_cotizacion,			--0
			gastos,					--0
			sac_asientos,			--0
			subir_bo,				--0
			sac_notrx,				--null
			flag_web_corr,			--0
			facultativo,			--0
			fronting,				--0
			wf_aprob,				--0
			wf_firma_aprob,			--null
			wf_incidente,			--null
			wf_fecha_entro,			--null
			wf_fecha_aprob,			--null
			fecha_indicador,		--null
			no_hoja)				--null
	values	(_no_poliza,			--no_poliza,
			_no_endoso,				--no_endoso,
			_cod_compania,			--cod_compania,
			_cod_sucursal,			--cod_sucursal,
			_cod_tipocalc,			--cod_tipocalc,
			_cod_formapag,			--cod_formapag,
			_null,					--cod_tipocan,
			_cod_perpago,			--cod_perpago,
			_cod_endomov,			--cod_endomov,
			_no_documento,			--no_documento,
			_vigencia_inic,			--vigencia_inic,	
			_vigencia_final,		--vigencia_final,
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			1,						--1
			_fecha_hoy,				--29/11/2012
			_fecha_hoy,				--29/11/2012
			_fecha_primer_pago,		--11/11/2012
			_no_pagos,				--12
			0,						--0
			_null,					--null
			_null,					--null
			_fecha_hoy,				--29/11/2012
			_fecha_hoy,				--29/11/2012
			0,						--0
			_periodo,				--2012-11
			_user_added,			--NBROWN
			0,						--0
			0,						--0
			0,						--0
			_null,					--null
			_vigencia_inic_pol,		--11/11/2012
			_vigencia_final_pol,	--11/11/2013
			_null,					--null
			_null,					--null
			_null,					--null
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			_null,					--null
			0,						--0
			0,						--0
			0,						--0
			0,						--0
			_null,					--null
			_null,					--null
			_null,					--null
			_null,					--null
			_null,					--null
			_null);					--null
	
	
	foreach
		select no_unidad,
			   reasegurada,
			   vigencia_inic,
			   vigencia_final,
			   beneficio_max,
			   desc_unidad,
			   cod_ruta,
			   cod_producto,
			   cod_asegurado,
			   suma_asegurada
		  into _no_unidad,
			   _reasegurada,
			   _vigencia_inic_uni,
			   _vigencia_final_uni,
			   _beneficio_max,
			   _desc_unidad,
			   _cod_ruta,
			   _cod_producto,
			   _cod_cliente,
			   _suma_asegurada
		  from emipouni
		 where no_poliza = _no_poliza
		 
		insert into endeduni(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_ruta,
				cod_producto,
				cod_cliente,
				suma_asegurada,
				prima,
				descuento,
				recargo,
				prima_neta,
				impuesto,
				prima_bruta,
				reasegurada,
				vigencia_inic,
				vigencia_final,
				desc_unidad,
				prima_suscrita,
				prima_retenida,
				gastos,
				subir_bo,
				beneficio_max)
		values	(_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_ruta,
				_cod_producto,
				_cod_cliente,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				_reasegurada,
				_vigencia_inic_uni,
				_vigencia_final_uni,
				_desc_unidad,
				0,
				0,
				0,
				0,
				_beneficio_max);
	end foreach
			
	insert into endmoage(
			no_poliza,
			no_endoso,
			cod_agente,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc)
	values	(_no_poliza,
			_no_endoso,
			_cod_agente_new,
			_porc_partic_agt,
			_porc_comis_agt,
			_porc_produc);
			
	
	update deivid_tmp:tmp_rolkam
	   set procesada	= 1
	 where poliza		= _no_documento;

	call sp_pro43(_no_poliza,_no_endoso) returning _error,_error_desc;
			
	return _no_documento,
		   _no_endoso,	
		   _cod_agente,
		   _vigencia_inic,
		   _vigencia_final 
		   with resume;
	--exit foreach;
end foreach
end procedure
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  