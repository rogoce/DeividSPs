-- Procedimiento que carga el archivo de renovaciones.
-- creado    : 05/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro371;
create procedure "informix".sp_pro371(a_no_poliza char(10))
returning   integer,
			char(100);   -- _error

define _deducible_char			varchar(50);
define _nom_producto			varchar(50);
define _desc_limite1			varchar(50);
define _desc_limite2			varchar(50);
define _nom_acreedor			varchar(50);
define _pasaporte				varchar(30);
define _cedula					varchar(30);
define _ruc						varchar(30);
define _nom_primer_cli			char(100);
define _nom_conductor			char(100);
define _nom_cliente				char(100);
define _error_desc				char(100);																	  
define _nom_ramo				char(50);																	  
define _email					char(50);																	  
define _nom_segundo_cli			char(40);
define _casada_ape_cli			char(40);
define _ape_conductor			char(40);													   
define _ape_cliente				char(40);													   
define _seg_ape_cli				char(40);													   
define _no_motor				char(30);
define _no_documento			char(20);
define _cod_acreedor_agt		char(10);
define _cod_prod_agt			char(10);
define _nom_uso_auto			char(10);
define _tel_residenc			char(10);
define _tel_oficina				char(10);
define _cod_cliente				char(10);
define _no_poliza				char(10);
define _vig_inic				char(10);
define _vig_fin					char(10);
define _celular					char(10);
define _tipo					char(10);
define _periodo					char(7);
define _cod_cobertura			char(5);															   
define _cod_producto			char(5);															   
define _cod_acreedor			char(5);
define _cod_agente				char(5);															   
define _cod_agente2				char(5);															   
define _no_unidad				char(5);
define _cod_impuesto			char(3);															   
define _cod_subramo				char(3);												   
define _cod_ramo				char(3);
define _sexo_conductor			char(1);												   
define _tipo_persona			char(1);												   
define _uso_auto				char(1);												   
define _limite_comprensivo1		dec(16,2);
define _limite_comprensivo2		dec(16,2);																							  
define _prima_lesiones_corp		dec(16,2);																							  																						  
define _limite_gastos_med2		dec(16,2);																							  
define _limite_gastos_med1		dec(16,2);												 
define _prima_comprensivo		dec(16,2);													 
define _limite_colision1		dec(16,2);												  
define _limite_colision2		dec(16,2);												 	 
define _limite_lesiones1		dec(16,2);												 
define _limite_lesiones2		dec(16,2);
define _prima_gastos_med		dec(16,2);
define _limite_incedio1			dec(16,2);					   
define _limite_incedio2			dec(16,2);					   					   
define _deducible_cober			dec(16,2);
define _monto_impuesto			dec(16,2);												   
define _limite_endoso1			dec(16,2);												   
define _limite_endoso2			dec(16,2);												   
define _porc_comis_agt			dec(16,2);												   
define _prima_incendio 			dec(16,2);
define _prima_sin_desc 			dec(16,2);
define _suma_asegurada			dec(16,2);
define _prima_colision			dec(16,2);
define _limite_muerte1			dec(16,2);
define _limite_muerte2			dec(16,2);
define _limite1_cober			dec(16,2);
define _limite2_cober			dec(16,2);
define _limite_danos1			dec(16,2);
define _limite_danos2			dec(16,2);
define _limite_robo1			dec(16,2);
define _limite_robo2			dec(16,2);
define _prima_endoso			dec(16,2);
define _prima_muerte			dec(16,2);
define _prima_bruta				dec(16,2);
define _prima_danos				dec(16,2);
define _prima_cober				dec(16,2);
define _prima_robo				dec(16,2);
define _prima_neta				dec(16,2);
define _monto_desc				dec(16,2);
define _porc_desc				dec(16,2);
define _monto_imp				dec(16,2);
define _porc_imp				dec(16,2);
define _prima		   			dec(16,2);
define _fact_impuesto			dec(5,2);
define _opcion_final			smallint;
define _es_pasaporte			smallint;
define _cnt_existe				smallint;
define _tipo_cober				smallint;
define _error_isam				smallint;
define _cant_pagos				smallint;
define _flag_agt				smallint;
define _enviado					smallint;
define _error					smallint;
define _vigencia_inic			date;
define _vigencia_fin			date;
define _fecha_hoy			    date;
define _cod_grupo               char(5);

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

--set debug file to "sp_pro371.trc";
--trace on;

set isolation to dirty read;

let _cod_agente				= '00035';
let _cod_acreedor_agt		= '';
let _nom_segundo_cli		= '';
let _deducible_char			= '';
let	_sexo_conductor			= '';
let _nom_primer_cli			= '';
let _ape_conductor			= '';
let	_nom_conductor			= '';
let _cod_prod_agt			= '';
let _nom_acreedor			= '';
let _cod_acreedor			= '';
let _nom_producto			= '';
let _pasaporte				= '';
let _cedula					= '';
let _ruc					= '';
let _limite_comprensivo1	= 0.00;		
let _limite_comprensivo2	= 0.00;	
let _prima_lesiones_corp	= 0.00;	
let _limite_gastos_med2		= 0.00;
let _limite_gastos_med1		= 0.00;
let _prima_comprensivo		= 0.00;
let _limite_colision1		= 0.00;
let _limite_colision2		= 0.00;
let _limite_lesiones1		= 0.00;
let _limite_lesiones2		= 0.00;
let _prima_gastos_med		= 0.00;
let _limite_incedio1		= 0.00;	
let _limite_incedio2		= 0.00;	
let _deducible_cober		= 0.00;	
let _monto_impuesto			= 0.00;
let _limite_endoso1			= 0.00;
let _limite_endoso2			= 0.00;
let _porc_comis_agt			= 0.00;
let _prima_incendio			= 0.00;
let _prima_sin_desc 		= 0.00;	
let _suma_asegurada			= 0.00;
let _prima_colision			= 0.00;
let _limite_muerte1			= 0.00;
let _limite_muerte2			= 0.00;
let _limite1_cober			= 0.00;
let _limite2_cober			= 0.00;
let _limite_danos1			= 0.00;
let _limite_danos2			= 0.00;
let _fact_impuesto			= 0.00;
let _limite_robo1			= 0.00;
let _limite_robo2			= 0.00;
let _prima_endoso			= 0.00;
let _prima_muerte			= 0.00;
let _prima_bruta			= 0.00;	
let _prima_danos			= 0.00;	
let _prima_cober			= 0.00;	
let _prima_robo				= 0.00;
let _prima_neta				= 0.00;
let _monto_desc				= 0.00;
let _porc_desc				= 0.00;
let _monto_imp				= 0.00;
let _porc_imp				= 0.00;
let _prima		   			= 0.00;
let _flag_agt				= 0;
let _fecha_hoy			    = current;

--call sp_sis21(a_no_documento) returning _no_poliza;																   

select cod_ramo,
	   cod_subramo,																									   
	   cod_contratante,																							   
	   no_pagos,																								   
	   to_char(vigencia_inic,"%m/%d/%Y"),
	   to_char(vigencia_final,"%m/%d/%Y"),
	   prima,
	   descuento,
	   prima_bruta,
	   impuesto,
	   no_documento,
	   prima_neta,
	   cod_grupo
  into _cod_ramo,
	   _cod_subramo,	
	   _cod_cliente,
	   _cant_pagos,
	   _vig_inic,
	   _vig_fin,
	   _prima_sin_desc,
	   _monto_desc,
	   _prima_bruta,
	   _monto_imp,
	   _no_documento,
	   _prima_neta,
	   _cod_grupo
  from emipomae
 where no_poliza = a_no_poliza;

select cod_agente
  into _cod_agente2
  from emipoagt
 where no_poliza = a_no_poliza
   and cod_agente in ('00035','00166','01743','01744','01745','01751','01851','02618','02904','02656','02154'); --

if _cod_agente2 is null then
	let _cod_agente2 = '';
end if

let _no_poliza = sp_sis21(_no_documento);
let _periodo = _vig_inic[7,10] || '-' || _vig_inic[1,2];

if _cod_ramo not in ('002','020','023') or _cod_agente2 = '' then
	return 0,'No aplica para la insercion en el archivo';
else
	select count(*)
	  into _cnt_existe
	  from emirenduc
	 where no_documento = _no_documento
	   and periodo      = _periodo;

	if _cnt_existe > 0 then
		select enviado
		  into _enviado
		  from emirenduc
		 where no_documento = _no_documento
		   and periodo = _periodo;

		if _enviado = 0 then
			delete from emirenduc
			 where no_documento = _no_documento;
		else
			return 0,'La Póliza ya fue enviada y no puede ser actualizada';
		end if
	end if
end if

-- Se busca la informacion de endedmae endoso 0, ID de la solicitud	# 6580 Amado 18-05-2023
select prima,
	   descuento,
	   prima_bruta,
	   impuesto,
	   prima_neta
  into _prima_sin_desc,
	   _monto_desc,
	   _prima_bruta,
	   _monto_imp,
	   _prima_neta
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = '00000';

select porc_comis_agt
  into _porc_comis_agt
  from emipoagt
 where no_poliza = a_no_poliza
   and cod_agente = '00035';

let _porc_comis_agt = _porc_comis_agt/100;

foreach
	select cod_impuesto
	  into _cod_impuesto
	  from emipolim
	 where no_poliza = a_no_poliza

	select factor_impuesto
	  into _fact_impuesto
	  from prdimpue
	 where cod_impuesto = _cod_impuesto;

	let _porc_imp = _porc_imp + _fact_impuesto;
end foreach

let _porc_imp = _porc_imp / 100;

select aseg_primer_nom,
	   aseg_segundo_nom,
	   aseg_primer_ape,
	   aseg_segundo_ape,
	   aseg_casada_ape,
	   e_mail,
	   cedula,
	   celular,
	   pasaporte,
	   telefono1,
	   telefono2,
	   tipo_persona
  into _nom_primer_cli,
	   _nom_segundo_cli,
	   _ape_cliente,
	   _seg_ape_cli,
	   _casada_ape_cli,
	   _email,
	   _cedula,
	   _celular,
	   _es_pasaporte,
	   _tel_residenc,
	   _tel_oficina,
	   _tipo_persona
  from cliclien
 where cod_cliente = _cod_cliente;

if _nom_segundo_cli is not null and _nom_segundo_cli <> '' then						 
	let _nom_cliente = trim(_nom_primer_cli) || ' ' || trim(_nom_segundo_cli);
else
	let _nom_cliente = trim(_nom_primer_cli);
end if

if _casada_ape_cli is not null and _casada_ape_cli <> '' then
	let _nom_segundo_cli = _casada_ape_cli;
end if

if _nom_cliente is null then
	select trim(nombre_razon)
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
end if

if _tipo_persona = 'N' then
	if _es_pasaporte = 1 then
		let _pasaporte	= _cedula;
		let _cedula		= '';
	end if
elif _tipo_persona = 'J' then
	let _ruc	= _cedula;
	let _cedula	= '';
end if

foreach
	select cod_acreedor
	  into _cod_acreedor
	  from emipoacr
	 where no_poliza = a_no_poliza

	exit foreach;
end foreach

if _cod_acreedor is not null and _cod_acreedor <> '' then
	select nombre
	  into _nom_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;

	foreach
		select cod_acreedor_agt
		  into _cod_acreedor_agt
		  from equiacre
		 where cod_agente			= '00035'
		   and cod_acreedor_ancon	= _cod_acreedor
		exit foreach;
	end foreach
end if
	   	
foreach
	select cod_producto,
		   suma_asegurada,
		   no_unidad
	  into _cod_producto,
		   _suma_asegurada,
		   _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	
	if _cod_producto in ('00320','00326','00921') then
		let _cod_producto = '00315';
	end if
	
	select nombre
	  into _nom_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	foreach
		select cod_producto_agt
		  into _cod_prod_agt
		  from equiprod
		 where cod_agente = _cod_agente
		   and cod_producto_ancon = _cod_producto		   
		 order by cod_producto_agt asc
		 
		exit foreach;
	end foreach

	select sum(porc_descuento)
	  into _porc_desc
	  from emiunide
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	select no_motor,
		   uso_auto
	  into _no_motor,
	  	   _uso_auto
	  from emiauto
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	if _uso_auto = 'P' then
		let _nom_uso_auto = 'Particular';
	elif _uso_auto = 'C' then
		let _nom_uso_auto = 'Comercial';
	end if

	call sp_pro368a(a_no_poliza,_no_unidad,'00035') returning _error,_error_desc;

	if _error <> 0 then
		return _error,_error_desc;
	end if

	begin
		on exception in(-239,-268)
			update emirenduc
			   set cod_ramo			= _cod_ramo,   
			   	   vigencia_inic	= _vig_inic,   
			   	   vigencia_fin		= _vig_fin,
			   	   nom_cliente		= _nom_cliente,   
			   	   ape_cliente		= _ape_cliente,   
			   	   seg_ape_cliente	= _seg_ape_cli,   
			   	   cedula			= _cedula,   
			   	   pasaporte		= _pasaporte,   
			   	   ruc				= _ruc,   
			   	   tel_residencial	= _tel_residenc,   
			   	   tel_oficina		= _tel_oficina,   
			   	   celular			= _celular,   
			   	   email			= _email,   
			   	   prima_sin_desc	= _prima_sin_desc,  
			   	   monto_desc		= _monto_desc,   
			   	   porc_desc		= _porc_desc,   
			   	   prima			= _prima_neta,   
			   	   porc_imp			= _porc_imp,   
			   	   monto_imp		= _monto_imp,   
			   	   tot_prima		= _prima_bruta,
			   	   cant_pagos		= _cant_pagos,   
			   	   suma_aseg		= _suma_asegurada,  
			   	   nom_acreedor		= _nom_acreedor,   
			   	   cod_acreedor_agt	= _cod_acreedor_agt,
			   	   nom_conductor	= _nom_conductor,   
			   	   ape_conductor	= _ape_conductor,   
			   	   sexo_conductor	= _sexo_conductor,  
			   	   uso_auto			= _nom_uso_auto,   
			   	   no_motor			= _no_motor,   
			   	   renovar			= 0,
			   	   enviado			= 0,
			   	   no_poliza_ant	= _no_poliza,
			   	   cod_producto_agt	= _cod_prod_agt,
			   	   nom_producto		= _nom_producto,
				   periodo			= _periodo,
				   fecha_envio      = _fecha_hoy,
				   cod_grupo        = _cod_grupo
			 where no_documento		= _no_documento
			   and periodo			= _periodo;
		end exception
	
		insert into emirenduc
				(no_documento, 									
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
				tipo,   										
				prima_sin_desc,   								
				monto_desc,   									
				porc_desc,   									
				prima,   										
				porc_imp,   									
				monto_imp,   									
				tot_prima,   									
				cant_pagos,   									
				suma_aseg,   									
				nom_acreedor,   								
				cod_acreedor_agt,   							
				nom_conductor,   								
				ape_conductor,   								
				sexo_conductor,  							
				uso_auto,   									
				no_motor,   									
				renovar,   										
				enviado,
				no_poliza_ant,
				cod_producto_agt,
				nom_producto,
				periodo,
				fecha_envio,
				cod_agente,
				cod_grupo
				)
		values	(_no_documento,   	
				_cod_ramo,   
				_vig_inic,   
				_vig_fin,
				_nom_cliente,   
				_ape_cliente,   
				_seg_ape_cli,   
				_cedula,   
				_pasaporte,   
				_ruc,   
				_tel_residenc,   
				_tel_oficina,   
				_celular,   
				_email,   
				'Poliza',   
				_prima_sin_desc,   
				_monto_desc,   
				_porc_desc,   
				_prima_neta,   
				_porc_imp,   
				_monto_imp,   
				_prima_bruta,
				_cant_pagos,   
				_suma_asegurada,   
				_nom_acreedor,   
				_cod_acreedor_agt,   
				_nom_conductor,   
				_ape_conductor,   
				_sexo_conductor,     
				_nom_uso_auto,   
				_no_motor,   
				0,   
				0,
				_no_poliza,
				_cod_prod_agt,
				_nom_producto,
				_periodo,
				_fecha_hoy,
				_cod_agente2,
				_cod_grupo);
	end
--set debug file to "sp_pro371.trc";
--trace on;
	foreach
		select prima,
			   limite1,
			   limite2,
			   deducible,
			   tipo_cober
		  into _prima_cober,
		  	   _limite1_cober,
			   _limite2_cober,
			   _deducible_cober,
			   _tipo_cober
		  from tmp_cober2

		if _tipo_cober = 1 then --Lesiones		
			update emirenduc
			   set prima_lesiones_corp	= _prima_cober,
				   lesiones_limite1		= _limite1_cober,
				   lesiones_limite2		= _limite2_cober
			 where no_documento			= _no_documento;
		elif _tipo_cober = 2 then --Daños
			update emirenduc
			   set prima_danos		= _prima_cober,
				   danos_limite1	= _limite1_cober,
				   danos_limite2	= _limite2_cober,
				   deducible_danos	= _deducible_cober
			 where no_documento		= _no_documento;
		elif _tipo_cober = 3 then	--Gastos
			update emirenduc
			   set prima_gastos_med		= _prima_cober,
				   gastos_med_limite1	= _limite1_cober,
				   gastos_med_limite2	= _limite2_cober
			 where no_documento			= _no_documento;
		elif _tipo_cober = 4 then --Comprensivo
			update emirenduc
			   set prima_comprensivo		= _prima_cober,
				   comprensivo_limite1		= _limite1_cober,
				   comprensivo_limite2		= _limite2_cober,
				   deducible_comprensivo	= _deducible_cober
			 where no_documento				= _no_documento;
		elif _tipo_cober = 5 then --Colision
			update emirenduc
			   set prima_colision		= _prima_cober,
				   colision_limite1		= _limite1_cober,
				   colision_limite2		= _limite2_cober,
				   deducible_colision	= _deducible_cober
			 where no_documento			= _no_documento;
		elif _tipo_cober = 6 then --Muerte Accidental
			update emirenduc
			   set prima_muerte		= _prima_cober,
				   muerte_limite1	= _limite1_cober,
				   muerte_limite2	= _limite2_cober
			 where no_documento		= _no_documento;
		elif _tipo_cober = 7 then --Incendio
			update emirenduc
			   set prima_incendio		= _prima_cober,
				   incendio_limite1		= _limite1_cober,
				   incendio_limite2		= _limite2_cober,
				   deducible_incendio	= _deducible_cober
			 where no_documento			= _no_documento;			 
		elif _tipo_cober = 8 then --Robo
			update emirenduc
			   set prima_robo		= _prima_cober,
				   robo_limite1		= _limite1_cober,
				   robo_limite2		= _limite2_cober,
				   deducible_robo	= _deducible_cober
			 where no_documento		= _no_documento;
		elif _tipo_cober = 9 then	--Endoso
			update emirenduc
			   set prima_endoso		= _prima_cober
			 where no_documento		= _no_documento;
		elif _tipo_cober = 10 then	--Caida de Objetos
			update emirenduc
			   set caida_objetos_prima		= _prima_cober,
				   caida_objetos_limite1	= _limite1_cober,
				   caida_objetos_limite2	= _limite2_cober,
				   caida_objetos_deducible	= _deducible_cober
			 where no_documento		= _no_documento;
		elif _tipo_cober = 11 then	--Vidrios
			update emirenduc
			   set vidrios_prima		= _prima_cober,
				   vidrios_limite1		= _limite1_cober,
				   vidrios_limite2		= _limite2_cober,
				   vidrios_deducible	= _deducible_cober
			 where no_documento		= _no_documento;
		end if

		let _prima_cober		= 0.00;
		let _limite1_cober		= 0.00;
		let _limite2_cober		= 0.00;
		let _deducible_cober	= 0.00; 
	end foreach
	drop table tmp_cober2;
end foreach	
end

return 0,'Insersion Exitosa del Registro';
end procedure 