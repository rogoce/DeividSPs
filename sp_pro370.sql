-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 07/09/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro370;

create procedure "informix".sp_pro370(
a_cod_agente	char(5),
a_num_carga		char(5),
a_error			smallint,
a_opcion		char(1))
returning	char(20),	  	--1_no_documento,  			
			char(50),		--2_nom_ramo,					
			date,			--3_vigencia_inic,				
			date,			--4_vigencia_fin,				
			char(100),		--5_cliente_nom,				
			char(50),		--6_cliente_ape,				
			char(50),		--7_cliente_ape_seg,			
			char(20),		--8_cliente_ape_casada,		
			char(1),		--9_tipo_persona,				
			varchar(30),	--10_cedula,					
			date,			--11_fecha_aniversario,			
			char(1),		--12_sexo,						
			char(10),		--13_estado_civil,				
			char(10),		--14_telefono1,					
			char(10),		--15_telefono2,					
			char(10),		--16_celular,					
			char(50),		--17_e_mail,					
			dec(16,2),		--18_prima_sin_desc,			
			dec(16,2),		--19_descuento,					
			dec(16,2),		--20_prima_neta,				
			dec(16,2),		--21_porc_impuesto,				
			dec(16,2),		--22_tot_impuesto,				
			dec(16,2),		--23_prima_bruta,				
			date,			--24_fecha_registro,			
			char(50),		--25_nom_formapag,				
			char(50),		--26_nom_perpago,				
			smallint,		--27_no_pagos,					
			dec(16,2),  	--28_saldo,						
			dec(16,2),  	--29_impuesto_saldo,			
			dec(16,2),  	--30_saldo_con_impuesto,		
			char(50),		--31_nom_producto,				
			char(20),		--32_responsable_cobro,   		
			smallint,		--33_facultativo,				
			smallint,		--34_declarativa,				
			smallint,		--35_coaseguro,					
			char(10),		--36_cod_contratante,			
			varchar(30),	--37_cedula_contratante,		
			dec(16,2),  	--38_prima_vida,				
			dec(16,2),  	--39_suma_asegurada,			
			char(50),		--40_nom_acreedor,				
			char(50),		--41_nom_marca,					
			char(1),		--42_uso_auto,					
			char(50),		--43_nom_color,					
			char(30),		--44_no_chasis,					
			char(50),		--45_conductor_nom,				
			char(10),		--46_placa,						
			smallint,		--47_capacidad,					
			char(30),		--48_vin,						
			char(30),		--49_no_motor,					
			smallint,		--50_no_auto,					
			dec(16,2),		--51_suma_edificio,				
			dec(16,2),		--52_suma_contenido,			
			char(50),		--53_nom_edificio,				
			dec(16,2),		--54_mercancia_desde,			
			dec(16,2),		--55_mercancia_hasta,			
			char(50),		--56_beneficiario1,				
			char(50),		--57_beneficiario2,				
			char(50),		--58_beneficiario3,				
			char(50),		--59_beneficiario4,				
			dec(16,2),		--60_prima_lesiones_corp,		
			dec(16,2),		--61_limite_lesiones1,			
			dec(16,2),		--62_limite_lesiones2,			
			dec(16,2),		--63_prima_danos,				
			dec(16,2),		--64_limite_danos1,				
			dec(16,2),		--65_limite_danos2,	
			dec(16,2),		--_deducible_danos
			dec(16,2),		--66_prima_gastos_med,			
			dec(16,2),		--67_limite_gastos_med1,		
			dec(16,2),		--68_limite_gastos_med2,		
			dec(16,2),		--69_prima_comprensivo,			
			dec(16,2),		--70_limite_comprensivo1,		
			dec(16,2),		--71_limite_comprensivo2,		
			dec(16,2),		--72_deducible_comprensivo,		
			dec(16,2),		--73_prima_colision,			
			dec(16,2),		--74_limite_colision1,			
			dec(16,2),		--75_limite_colision2,			
			dec(16,2),		--76_deducible_colision,		
			dec(16,2),		--77_otras_cob,					
			dec(16,2),		--78_prima_explosion,			
			dec(16,2),		--79_prima_terremoto,			
			dec(16,2),		--80_prima_vendabal,			
			dec(16,2),		--81_prima_otros_incendio,		
			dec(16,2),		--82_prima_total_transporte,	
			dec(16,2),		--83_prima_total_otros_riesgos,
			char(50),		--84_nom_ocupacion,				
			char(100),  	--85_direccion,					
			char(250),  	--86_observaciones,				
			char(100),  	--87_direccion_cobros,			
			dec(16,2),  	--88_porc_descuento,			
			date,			--89_fecha_primer_pago,			
			dec(16,2),  	--90_porc_desc_tarjeta,			
			dec(16,2),  	--91_tarjeta_descuento,   		
			char(5),		--92a_num_carga,				
			char(5),		--93a_cod_agente				
			smallint,		--94_renglon,					
			smallint,		--95_emitir						
			char(50),		--96_nom_modelo,				
			char(50),		--97_nom_subramo				
			smallint, 		--98_actualizado
			char(50),		--99_conductor_ape
			char(10),		--100_no_poliza
			smallint,		--101_opcion_final
			varchar(30),	--102_pasaporte
			varchar(30),	--103_ruc
			char(1),
			char(1);

define _pasaporte					varchar(30);
define _ruc							varchar(30);
define _nom_ocupacion				char(50); 
define _nom_producto				char(50);
define _nom_acreedor				char(50);
define _nom_formapag				char(50);
define _nom_subramo					char(50);
define _nom_perpago					char(50);
define _nom_modelo					char(50);
define _nom_color					char(50);
define _nom_marca					char(50);
define _nom_ramo					char(50);
define _cedula_contratante			char(30);
define _cedula						char(30);
define _observaciones				char(250);
define _direccion_cobros			char(100);
define _cliente_nom					char(100);
define _descripcion					char(100);
define _direccion					char(100);
define _cliente_ape_seg				char(50);
define _beneficiario3				char(50);
define _beneficiario4				char(50);
define _beneficiario1				char(50);
define _beneficiario2				char(50);
define _conductor_nom				char(50);
define _conductor_ape				char(50);
define _nom_edificio				char(50);
define _cliente_ape					char(50);
define _error_desc					char(50);
define _e_mail						char(50);
define _no_chasis					char(30);
define _no_motor					char(30);
define _campo						char(30);
define _vin							char(30);
define _cliente_ape_casada			char(20);
define _responsable_cobro			char(20);
define _no_documento				char(20);
define _cod_contratante				char(10);
define _cod_ocupacion				char(10);
define _estado_civil				char(10);
define _cod_formapag				char(10);
define _cod_acreedor				char(20);
define _cod_producto				char(20);
define _cod_subramo					char(10);
define _cod_perpago					char(10);
define _cod_modelo					char(20);
define _no_poliza					char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _cod_color					char(20);
define _cod_ramo					char(10);
define _celular						char(10);
define _placa						char(10);
define _cod_cobertura_ancon			char(5);
define _cod_producto_ancon			char(5);
define _cod_acreedor_ancon			char(5);
define _cod_modelo_ancon			char(5);
define _cod_marca_ancon				char(5);
define _cod_cobertura				char(5);
define _cod_agente					char(5);
define _cod_marca					char(20);
define _num_carga					char(5);
define _cod_ocupacion_ancon			char(3);
define _cod_perpago_ancon			char(3);
define _cod_subramo_ancon			char(3);
define _cod_color_ancon				char(3);
define _cod_ramo_ancon				char(3);
define _tipo_persona				char(1);
define _uso_auto					char(1);
define _opcion						char(1);
define _pool						char(1);
define _sexo						char(1);
define _prima_total_otros_riesgos	dec(16,2);
define _prima_total_transporte		dec(16,2);
define _deducible_comprensivo		dec(16,2);
define _prima_otros_incendio		dec(16,2);
define _limite_comprensivo1			dec(16,2);
define _limite_comprensivo2			dec(16,2);
define _prima_lesiones_corp			dec(16,2);
define _limite_gastos_med2			dec(16,2);
define _limite_gastos_med1			dec(16,2);
define _saldo_con_impuesto			dec(16,2);
define _deducible_colision			dec(16,2);
define _porc_desc_tarjeta			dec(16,2);
define _prima_comprensivo			dec(16,2);
define _tarjeta_descuento			dec(16,2);
define _limite_colision1			dec(16,2);
define _limite_colision2			dec(16,2);
define _limite_lesiones1			dec(16,2);
define _limite_lesiones2			dec(16,2);
define _prima_gastos_med			dec(16,2);
define _prima_terremoto				dec(16,2);
define _mercancia_desde				dec(16,2);
define _mercancia_hasta				dec(16,2);
define _prima_explosion				dec(16,2);
define _deducible_danos				dec(16,2);
define _impuesto_saldo				dec(16,2);
define _prima_colision				dec(16,2);
define _prima_sin_desc				dec(16,2);
define _prima_vendabal				dec(16,2);
define _suma_asegurada				dec(16,2);
define _suma_contenido				dec(16,2);
define _porc_descuento				dec(16,2);
define _limite_danos1				dec(16,2);
define _limite_danos2				dec(16,2);
define _porc_impuesto				dec(16,2);
define _suma_edificio				dec(16,2);
define _tot_impuesto				dec(16,2);
define _prima_bruta					dec(16,2);
define _prima_danos					dec(16,2);
define _prima_vida					dec(16,2);
define _prima_neta					dec(16,2);
define _descuento					dec(16,2);
define _otras_cob					dec(16,2);
define _saldo						dec(16,2);
define _opcion_final				smallint;
define _actualizado					smallint;
define _importancia					smallint;
define _cnt_existe					smallint;
define _emitir						smallint;
define _return						smallint;
define _existe						smallint;
define _error_excep					integer;
define _declarativa					integer;
define _facultativo					integer;
define _error_isam					integer;
define _coaseguro					integer;
define _capacidad					integer;
define _no_pagos					integer;
define _ano_auto					integer;
define _tot_reg						integer;
define _renglon						integer;
define _fecha_aniversario			date;
define _fecha_primer_pago			date;
define _fecha_registro				date;
define _vigencia_inic				date;
define _vigencia_fin				date;

--set debug file to "sp_pro370.trc";
--trace on;

set isolation to dirty read;
begin
on exception set _error_excep,_error_isam,_error_desc

--	return _error_excep,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

let _cod_cobertura	= '';
let _cod_ocupacion	= '';
let _cod_acreedor	= '';
let _cod_producto	= '';
let _cod_subramo	= '';
let _cod_perpago	= '';
let _cod_modelo		= '';
let _pasaporte		= '';
let _cod_marca		= '';
let _cod_color		= '';
let _cod_ramo		= '';
let _ruc			= '';

select count(*)
  into _tot_reg
  from prdemielctdet
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga
   and proceso		= a_opcion;

foreach
	select no_documento,						
		   cod_ramo,							
		   vigencia_inic,						
		   vigencia_final,						
		   cliente_nom,							
		   cliente_ape,							
		   cliente_ape_seg,						
		   cliente_ape_casada,					
		   tipo_persona,						
		   cedula,
		   pasaporte,
		   ruc,
		   fecha_aniversario,					
		   sexo,								
		   estado_civil,						
		   telefono1,							
		   telefono2,							
		   celular,								
		   e_mail,								
		   prima_sin_desc,						
		   descuento,							
		   prima_neta,							
		   porc_impuesto,						
		   tot_impuesto,						
		   prima_bruta,							
		   fecha_registro,						
		   cod_formapag,						
		   cod_perpago,							
		   no_pagos,							
		   saldo,								
		   impuesto_saldo,						
		   saldo_con_impuesto,					
		   cod_producto,						
		   responsable_cobro,   				
		   facultativo,							
		   declarativa,							
		   coaseguro,							
		   cod_contratante,						
		   cedula_contratante,					
		   prima_vida,							
		   suma_asegurada,						
		   cod_acreedor,						
		   cod_marca,							
		   uso_auto,							
		   cod_color,							
		   no_chasis,							
		   conductor_nom,
		   conductor_ape,						
		   placa,								
		   capacidad,							
		   vin,									
		   no_motor,							
		   ano_auto,							
		   suma_edificio,						
		   suma_contenido,						
		   nom_edificio,						
		   mercancia_desde,						
		   mercancia_hasta,						
		   beneficiario1,						
		   beneficiario2,						
		   beneficiario3,						
		   beneficiario4,						
		   prima_lesiones_corp,					
		   limite_lesiones1,					
		   limite_lesiones2,					
		   prima_danos,							
		   limite_danos1,						
		   limite_danos2,
		   deducible_danos,
		   prima_gastos_med,					
		   limite_gastos_med1,					
		   limite_gastos_med2,					
		   prima_comprensivo,					
		   limite_comprensivo1,					
		   limite_comprensivo2,					
		   deducible_comprensivo,				
		   prima_colision,						
		   limite_colision1,					
		   limite_colision2,					
		   deducible_colision,					
		   otras_cob,							
		   prima_explosion,						
		   prima_terremoto,						
		   prima_vendabal,						
		   prima_otros_incendio,				
		   prima_total_transporte,				
		   prima_total_otros_riesgos,			
		   cod_ocupacion,						
		   direccion,							
		   observaciones,						
		   direccion_cobros,					
		   porc_descuento,						
		   fecha_primer_pago,					
		   porc_desc_tarjeta,					
		   tarjeta_descuento,   				
		   renglon,								
		   cod_modelo,							
		   cod_subramo,							
		   emitir,								
		   actualizado,
		   no_poliza,
		   opcion_final,
		   proceso,
		   pool
	  into _no_documento,  
      	   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_fin,
		   _cliente_nom,
		   _cliente_ape,
		   _cliente_ape_seg,
		   _cliente_ape_casada,
		   _tipo_persona,
		   _cedula,
		   _pasaporte,
		   _ruc,
		   _fecha_aniversario,
		   _sexo,
		   _estado_civil,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _e_mail,
		   _prima_sin_desc,
		   _descuento,
		   _prima_neta,
		   _porc_impuesto,
		   _tot_impuesto,
		   _prima_bruta,
		   _fecha_registro,
		   _cod_formapag,
		   _cod_perpago,
		   _no_pagos,
		   _saldo,
		   _impuesto_saldo,
		   _saldo_con_impuesto,
		   _cod_producto,
		   _responsable_cobro,   
		   _facultativo,
		   _declarativa,
		   _coaseguro,
		   _cod_contratante,
		   _cedula_contratante,
		   _prima_vida,
		   _suma_asegurada,
		   _cod_acreedor,
		   _cod_marca,
		   _uso_auto,
		   _cod_color,
		   _no_chasis,
		   _conductor_nom,
		   _conductor_ape,
		   _placa,
		   _capacidad,
		   _vin,
		   _no_motor,
		   _ano_auto,
		   _suma_edificio,
		   _suma_contenido,
		   _nom_edificio,
		   _mercancia_desde,
		   _mercancia_hasta,
		   _beneficiario1,
		   _beneficiario2,
		   _beneficiario3,
		   _beneficiario4,
		   _prima_lesiones_corp,
		   _limite_lesiones1,
		   _limite_lesiones2,
		   _prima_danos,
		   _limite_danos1,
		   _limite_danos2,
		   _deducible_danos,
		   _prima_gastos_med,
		   _limite_gastos_med1,
		   _limite_gastos_med2,
		   _prima_comprensivo,
		   _limite_comprensivo1,
		   _limite_comprensivo2,
		   _deducible_comprensivo,
		   _prima_colision,
		   _limite_colision1,
		   _limite_colision2,
		   _deducible_colision,
		   _otras_cob,
		   _prima_explosion,
		   _prima_terremoto,
		   _prima_vendabal,
		   _prima_otros_incendio,
		   _prima_total_transporte,
		   _prima_total_otros_riesgos,
		   _cod_ocupacion,
		   _direccion,
		   _observaciones,
		   _direccion_cobros,
		   _porc_descuento,
		   _fecha_primer_pago,
		   _porc_desc_tarjeta,
		   _tarjeta_descuento,   
		   _renglon,
		   _cod_modelo,
		   _cod_subramo,
		   _emitir,
		   _actualizado,
		   _no_poliza,
		   _opcion_final,
		   _opcion,
		   _pool
	  from prdemielctdet
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and error		= a_error
	   --and actualizado	= 0

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _nom_ramo is null or _nom_ramo = '' then
		let _nom_ramo = _cod_ramo;
		let _nom_subramo = _cod_subramo;
	else
		select nombre
		  into _nom_subramo
		  from prdsubra
		 where cod_ramo		= _cod_ramo
		   and cod_subramo	= _cod_subramo;

		if _nom_subramo is null or _nom_subramo = '' then
			let _nom_subramo = _cod_subramo;
		end if
	end if

	select nombre
	  into _nom_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	if _nom_producto is null or _nom_producto = '' then
		let _nom_producto = _cod_producto;
	end if

	select nombre
	  into _nom_marca
	  from emimarca
	 where cod_marca = _cod_marca;

	if _nom_marca is null or _nom_marca = '' then
		let _nom_marca	= _cod_marca;
		let _nom_modelo	= _cod_modelo;													  
	end if																				  

	select nombre																		  
	  into _nom_modelo																	  
	  from emimodel																		  
	 where cod_modelo	= _cod_modelo;

	if _nom_modelo is null or _nom_marca = '' then
		let _nom_modelo = _cod_modelo;
	end if

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _nom_formapag is null or _nom_formapag = '' then
		let _nom_formapag = _cod_formapag;
	end if

	select nombre
	  into _nom_perpago
	  from cobperpa
	 where cod_perpago	= _cod_perpago;

	if _nom_perpago is null or _nom_perpago = '' then
		let _nom_perpago = _cod_perpago;
	end if

	select nombre
	  into _nom_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;

	if _nom_acreedor is null or _nom_acreedor = '' then
		let _nom_acreedor = _cod_acreedor;
	end if

	select nombre
	  into _nom_color
	  from emicolor
	 where cod_color = _cod_color;																

	if _nom_color is null or _nom_color = '' then												
		let _nom_color = _cod_color;																																														
	end if																						

	select nombre																				
	  into _nom_ocupacion																		
	  from cliocupa
	 where cod_ocupacion = _cod_ocupacion;														

	if _nom_ocupacion is null or _nom_ocupacion = '' then
		let _nom_ocupacion = _cod_ocupacion;
	end if

	
	return	_no_documento,  			--char(20),	  	
			_nom_ramo,					--char(50),	 	 
			_vigencia_inic,				--date,			
			_vigencia_fin,				--date,			
			_cliente_nom,				--char(100),	
			_cliente_ape,				--char(50),		
			_cliente_ape_seg,			--char(50),		
			_cliente_ape_casada,		--char(20),		
			_tipo_persona,				--char(1),		
			_cedula,					--varchar(30),	
			_fecha_aniversario,			--date,			
			_sexo,						--char(1),		
			_estado_civil,				--char(10),		
			_telefono1,					--char(10),		
			_telefono2,					--char(10),		
			_celular,					--char(10),		
			_e_mail,					--char(50),		
			_prima_sin_desc,			--dec(16,2),	
			_descuento,					--dec(16,2),	
			_prima_neta,				--dec(16,2),	
			_porc_impuesto,				--dec(16,2),	
			_tot_impuesto,				--dec(16,2),	
			_prima_bruta,				--dec(16,2),	
			_fecha_registro,			--date,			
			_nom_formapag,				--char(50),	 	
			_nom_perpago,				--char(50),	 	
			_no_pagos,					--smallint,		
			_saldo,						--dec(16,2),  	
			_impuesto_saldo,			--dec(16,2),  	
			_saldo_con_impuesto,		--dec(16,2),  	
			_nom_producto,				--char(50),	 	
			_responsable_cobro,   		--char(20),		
			_facultativo,				--smallint,		
			_declarativa,				--smallint,		
			_coaseguro,					--smallint,		
			_cod_contratante,			--char(10),		
			_cedula_contratante,		--varchar(30),	
			_prima_vida,				--dec(16,2),  	
			_suma_asegurada,			--dec(16,2),  	
			_nom_acreedor,				--char(50),	 	
			_nom_marca,					--char(50),	 	
			_uso_auto,					--char(1),		
			_nom_color,					--char(50),	 	
			_no_chasis,					--char(30),		
			_conductor_nom,				--char(50),
			_placa,						--char(10),		
			_capacidad,					--smallint,		
			_vin,						--char(30),		
			_no_motor,					--char(30),		
			_ano_auto,					--smallint,		
			_suma_edificio,				--dec(16,2),	
			_suma_contenido,			--dec(16,2),	
			_nom_edificio,				--char(50),		
			_mercancia_desde,			--dec(16,2),	
			_mercancia_hasta,			--dec(16,2),	
			_beneficiario1,				--char(50),		
			_beneficiario2,				--char(50),		
			_beneficiario3,				--char(50),		
			_beneficiario4,				--char(50),		
			_prima_lesiones_corp,		--dec(16,2),	
			_limite_lesiones1,			--dec(16,2),	
			_limite_lesiones2,			--dec(16,2),	
			_prima_danos,				--dec(16,2),	
			_limite_danos1,				--dec(16,2),	
			_limite_danos2,				--dec(16,2),
		    _deducible_danos,			--dec(16,2),
			_prima_gastos_med,			--dec(16,2),	
			_limite_gastos_med1,		--dec(16,2),	
			_limite_gastos_med2,		--dec(16,2),	
			_prima_comprensivo,			--dec(16,2),	
			_limite_comprensivo1,		--dec(16,2),	
			_limite_comprensivo2,		--dec(16,2),	
			_deducible_comprensivo,		--dec(16,2),	
			_prima_colision,			--dec(16,2),	
			_limite_colision1,			--dec(16,2),	
			_limite_colision2,			--dec(16,2),	
			_deducible_colision,		--dec(16,2),	
			_otras_cob,					--dec(16,2),	
			_prima_explosion,			--dec(16,2),	
			_prima_terremoto,			--dec(16,2),	
			_prima_vendabal,			--dec(16,2),	
			_prima_otros_incendio,		--dec(16,2),	
			_prima_total_transporte,	--dec(16,2),	
			_prima_total_otros_riesgos,	--dec(16,2),	
			_nom_ocupacion,				--char(50),	 	
			_direccion,					--char(100),  	
			_observaciones,				--char(250),  	
			_direccion_cobros,			--char(100),  	
			_porc_descuento,			--dec(16,2),  	
			_fecha_primer_pago,			--date,			
			_porc_desc_tarjeta,			--dec(16,2),  	
			_tarjeta_descuento,   		--dec(16,2),  	
			a_num_carga,				--char(5),		
			a_cod_agente,				--char(5),		
			_renglon,					--smallint,		
			_emitir,					--smallint,		
			_nom_subramo,				--char(50),	 	
			_nom_modelo,				--char(50);	 	
			_actualizado,				--smallint
			_conductor_ape,				--char(50),
			_no_poliza,					--char(10),
			_opcion_final,				--smallint
			_pasaporte,
			_ruc,
			_opcion,
			_pool
			with resume;								
end foreach														 
end																   
end procedure													 
