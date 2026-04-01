-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 07/09/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro370b;

create procedure "informix".sp_pro370b(a_cod_agente char(5),a_num_carga char(5),a_error smallint, a_opcion char(1))
returning	char(20),	  	--1 _no_documento,  			
			char(50),		--2 _nom_ramo,					
			date,			--3 _vigencia_inic,				
			date,			--4 _vigencia_fin,
			char(250),  	--5_observaciones,
			dec(16,2),      --6 _suma_asegurada
			char(5),        --7 _no_unidad
			char(50),       --8 _nom_producto
			char(250),  	--9 _desc_unidad
			varchar(30),	--10 _cedula,
			varchar(30),	--11 _pasaporte
			varchar(30),	--12 _ruc
			char(100),		--13 _cliente_nom,
			char(100),		--14 _conductor_nom,				
			char(50),		--15 _cliente_ape,				
			char(50),		--16 _cliente_ape_seg,			
			char(20),		--17 _cliente_ape_casada,		
			char(1),		--18 _tipo_persona,								
			date,			--19 _fecha_aniversario,			
			char(1),		--20_sexo,						
			char(10),		--21 _estado_civil,				
			char(10),		--22_telefono1,					
			char(10),		--23_telefono2,					
			char(10),		--24_celular,					
			char(50),		--25_e_mail,	
			char(100),  	--26_direccion,								
			char(100),  	--27_direccion_cobros,	
			dec(16,2),		--28_prima_sin_desc,			
			dec(16,2),		--29_descuento,					
			dec(16,2),		--30_prima_neta,				
			dec(16,2),		--31_porc_impuesto,				
			dec(16,2),		--32_tot_impuesto,				
			dec(16,2),		--33_prima_bruta,				
			date,			--34_fecha_registro,			
			char(50),		--35_nom_formapag,				
			char(50),		--36_nom_perpago,				
			smallint,		--37_no_pagos,
			smallint,       --38
			varchar(50),    --39
			smallint,       --40
			smallint,       --41
			smallint,       --42
			char(1),        --43
			varchar(10),    --44
			varchar(5);     --45

define _pasaporte					varchar(30);
define _ruc							varchar(30);
define _nom_producto				char(50);
define _nom_formapag				char(50);
define _nom_subramo					char(50);
define _nom_perpago					char(50);
define _nom_ramo					char(50);
define _cedula_contratante			char(30);
define _cedula						char(30);
define _observaciones				char(250);
define _desc_unidad                 char(250);
define _direccion_cobros			char(100);
define _cliente_nom					varchar(100);
define _cliente_nom1				char(100);
define _descripcion					char(100);
define _direccion					char(100);
define _cliente_ape_seg				varchar(50);

define _cliente_ape					varchar(50);
define _error_desc					char(50);
define _e_mail						char(50);

define _cliente_ape_casada			varchar(20);
define _responsable_cobro			char(20);
define _no_documento				char(20);
define _cod_contratante				char(10);
define _estado_civil				char(10);
define _cod_formapag				char(10);
define _cod_acreedor				char(20);
define _cod_producto				char(20);
define _cod_subramo					char(10);
define _cod_perpago					char(10);

define _no_poliza					char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _cod_color					char(20);
define _cod_ramo					char(10);
define _celular						char(10);
define _placa						char(10);
define _cod_producto_ancon			char(5);
define _cod_acreedor_ancon			char(5);
define _cod_cobertura				char(5);
define _cod_agente					char(5);
define _cod_marca					char(20);
define _num_carga					char(5);
define _cod_perpago_ancon			char(3);
define _cod_subramo_ancon			char(3);
define _cod_ramo_ancon				char(3);
define _tipo_persona				char(1);
define _opcion						char(1);
define _sexo						char(1);
define _prima_sin_desc				dec(16,2);
define _suma_asegurada				dec(16,2);
define _porc_descuento				dec(16,2);
define _porc_impuesto				dec(16,2);
define _tot_impuesto				dec(16,2);
define _prima_bruta					dec(16,2);
define _prima_neta					dec(16,2);
define _descuento					dec(16,2);
define _saldo						dec(16,2);
define _actualizado					smallint;
define _cnt_existe					smallint;
define _emitir						smallint;
define _return						smallint;
define _existe						smallint;
define _error_excep					integer;
define _declarativa					integer;
define _facultativo					integer;
define _error_isam					integer;
define _coaseguro					integer;
define _no_pagos					integer;
define _tot_reg						integer;
define _renglon						integer;
define _fecha_aniversario			date;
define _fecha_primer_pago			date;
define _fecha_registro				date;
define _vigencia_inic				date;
define _vigencia_fin				date;
define _no_unidad                   char(5);
define _capacidad                   smallint;
define _conductor_nom               varchar(100);


--set debug file to "sp_pro370.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error_excep,_error_isam,_error_desc

--	return _error_excep,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

let _cod_cobertura	= '';
let _cod_producto	= '';
let _cod_subramo	= '';
let _cod_perpago	= '';
let _pasaporte		= '';
let _cod_ramo		= '';
let _ruc			= '';
let _capacidad      = "";

select count(*)
  into _tot_reg
  from prdemielctdet
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga
   and proceso		= a_opcion;

foreach
	select no_documento,                         --1
		   cod_ramo,                             --2 
		   cod_subramo,
		   vigencia_inic,                        --3
		   vigencia_final,                       --4
		   observaciones,                        --5
           suma_asegurada,                       --6
           no_unidad,                            --7
           cod_producto,                         --8
           desc_unidad,                          --9
           cedula,                              --10
		   pasaporte,                           --11
		   ruc,                                 --12
		   cliente_nom,                         --13
		   cliente_ape,                         --14
		   cliente_ape_seg,                     --15
		   cliente_ape_casada,                  --16
		   tipo_persona,                        --17
		   fecha_aniversario,                   --18
		   sexo,                                --19
		   estado_civil,                        --20
		   telefono1,                           --21
		   telefono2,                           --22
		   celular,                             --23
		   e_mail,                              --24
     	   direccion,                           --25
		   direccion_cobros,                    --26
           prima_sin_desc,                      --27
		   descuento,                           --28
		   prima_neta,                          --29
		   porc_impuesto,                       --30
		   tot_impuesto,                        --31
		   prima_bruta,                         --32
		   fecha_registro,                      --33
		   cod_formapag,                        --34
		   cod_perpago,                         --35
		   no_pagos,                            --36
		   proceso,                             --37
		   emitir,                              --38
		   actualizado,                          --39
		   capacidad,                            --40
		   renglon,
		   conductor_nom
	  into _no_documento,  
      	   _cod_ramo,
		   _cod_subramo,
		   _vigencia_inic,
		   _vigencia_fin,
		   _observaciones,
		   _suma_asegurada,
		   _no_unidad,
		   _cod_producto,
		   _desc_unidad,
		   _cedula,
		   _pasaporte,
		   _ruc,
		   _cliente_nom,
		   _cliente_ape,
		   _cliente_ape_seg,
		   _cliente_ape_casada,
		   _tipo_persona,
		   _fecha_aniversario,
		   _sexo,
		   _estado_civil,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _e_mail,
		   _direccion,
		   _direccion_cobros,
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
		   _opcion,
		   _emitir,
		   _actualizado,
		   _capacidad,
		   _renglon,
		   _conductor_nom
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
	
	let _cliente_nom  = trim(_cliente_nom)||' '||trim(_cliente_ape)||' '||trim(_cliente_ape_seg);--||''||trim(_cliente_ape_casada);
/*
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
*/
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
/*
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
*/
	/*
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
			_opcion
			with resume;*/	
	return	_no_documento,  			--1 char(20),	  	
			_nom_ramo,					--2 char(50),	 	 
			_vigencia_inic,				--3 date,			
			_vigencia_fin,				--4 date,
			_observaciones,				--5 char(250),  
			_suma_asegurada,			--6 dec(16,2),  	
			_no_unidad,                 --7 char(5),
			_nom_producto,				--8 char(50),	
			_desc_unidad,                --9 char(250), 
			_cedula,					--10 varchar(30),	
			_pasaporte,                 --11
			_ruc,                       --12
			_cliente_nom,				--13 char(100),
			_conductor_nom,             --14
			_cliente_ape,				--15 char(50),		
			_cliente_ape_seg,			--16 char(50),		
			_cliente_ape_casada,		--17 char(20),		
			_tipo_persona,				--18 char(1),		
			_fecha_aniversario,			--19 date,			
			_sexo,						--20 char(1),		
			_estado_civil,				--21 char(10),		
			_telefono1,					--22 char(10),		
			_telefono2,					--23 char(10),		
			_celular,					--24 char(10),		
			_e_mail,					--25 char(50),		
			_direccion,					--26 char(100),  	
			_direccion_cobros,			--27 char(100),  	
			_prima_sin_desc,			--28 dec(16,2),	
			_descuento,					--29 dec(16,2),	
			_prima_neta,				--30 dec(16,2),	
			_porc_impuesto,				--31 dec(16,2),	
			_tot_impuesto,				--32 dec(16,2),	
			_prima_bruta,				--33 dec(16,2),	
			_fecha_registro,			--34 date,			
			_nom_formapag,				--35 char(50),	 	
			_nom_perpago,				--36 char(50),	 	
			_no_pagos,					--37 smallint,
			_emitir,                    --38,
			_nom_subramo,               --39
			_actualizado,               --40
			_capacidad,                 -- 41
			_renglon,                   --42
			_opcion,                    -- 43
			a_num_carga,                 --44
			a_cod_agente               --45
			with resume;			
end foreach														 
end																   
end procedure													 
																