-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro364;

create procedure "informix".sp_pro364(a_cod_agente char(5),a_num_carga char(5),a_opcion char(1))
returning integer,
		  smallint,
		  char(30),
          char(100);

define _cedula_contratante			varchar(30);
define _pasaporte					varchar(30);
define _cedula						varchar(30);
define _ruc							varchar(30);
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
define _no_documento_dup			char(20);
define _cod_formapag				char(20);
define _no_documento				char(20);
define _cod_contratante				char(10);
define _conductor_nom				char(50);
define _cod_ocupacion				char(10);
define _estado_civil				char(10);
define _cod_acreedor				char(10);
define _cod_producto				char(10);
define _cod_subramo					char(10);
define _cod_perpago					char(10);
define _cod_modelo					char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _no_poliza					char(10);
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
define _no_unidad_dup				char(5);
define _cod_agente					char(5);
define _cod_marca					char(5);
define _num_carga					char(5);
define _cod_ocupacion_ancon			char(3);
define _cod_perpago_ancon			char(3);
define _cod_subramo_ancon			char(3);
define _cod_color_ancon				char(3);
define _cod_ramo_verif				char(3);
define _cod_ramo_ancon				char(3);
define _tipo_persona				char(1);
define _uso_auto					char(1);
define _proceso						char(1);
define _sexo						char(1);
define _pool						char(1);
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
define _impuesto_saldo				dec(16,2);
define _prima_colision				dec(16,2);
define _prima_sin_desc				dec(16,2);
define _desc_calculado				dec(16,2);
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
define _importancia					smallint;
define _tot_polizas					smallint;
define _cnt_existe					smallint;
define _cnt_error					smallint;
define _cnt_ramo					smallint;
define _cnt_prod					smallint;
define _return						smallint;
define _existe						smallint;
define _error						smallint;
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
define _vig_final_dup				date;
define _vigencia_fin				date;


--set debug file to "sp_pro364.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error_excep,_error_isam,_error_desc
	delete from equierror 
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion;

	return _error_excep,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
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
let _no_poliza		= null;
let _cod_producto_ancon = '';

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
		   upper(cliente_nom),
		   upper(cliente_ape),
		   upper(cliente_ape_seg),
		   upper(cliente_ape_casada),
		   tipo_persona,
		   cedula,
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
		   pasaporte,
		   ruc
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
		   _pasaporte,
		   _ruc
	  from prdemielctdet
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	
	let	_cliente_ape_casada = sp_sis179(_cliente_ape_casada);
	--let	_direccion_cobros = sp_sis179(_direccion_cobros);
	let	_cliente_ape_seg = sp_sis179(_cliente_ape_seg);
	let _cliente_nom = sp_sis179(_cliente_nom);
	let _cliente_ape = sp_sis179(_cliente_ape);
	--let	_direccion = sp_sis179(_direccion);
	
	let _cnt_ramo = 0;
	let _cnt_prod = 0;
	if trim (upper (_responsable_cobro)) in ('DUCRUET','SEMUSA') then
		if trim(upper(_cod_formapag)) in ('ACH','DESC.TARJETA','DESC.TARJETA CREDITO') and a_cod_agente = '00035' then
			let _cod_formapag = '092';	--Ducruet - Electrónico
		else
			let _cod_formapag	= '008';
		end if
	elif _responsable_cobro in ('Ancon','Aseguradora','ANCON','ASEGURADORA') then 
		let _cod_formapag = '006';	--Ancon
	end if	
		
	update prdemielctdet
	   set cliente_nom			= _cliente_nom,
		   cliente_ape			= _cliente_ape,
		   cliente_ape_seg		= _cliente_ape_seg,
		   cliente_ape_casada	= _cliente_ape_casada,
		   cod_formapag			= _cod_formapag
		--   direccion			= _direccion,
		--   direccion_cobros		= _direccion_cobros
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and renglon		= _renglon;

	if _cod_cobertura is null then 
		let _cod_cobertura	= '';
	end if
	
	if _cod_ocupacion is null then
		let _cod_ocupacion	= '';
	end if

	if _cod_acreedor is null then
		let _cod_acreedor	= '';
	end if

	if _cod_producto is null then
		let _cod_producto	= '';
	end if
	
	if _cod_subramo is null then
		let _cod_subramo	= '';
	end if

	if _cod_perpago is null then
		let _cod_perpago	= '';
	end if

	if _cod_modelo is null then
		let _cod_modelo		= '';
	end if

	if _cod_marca is null then
		let _cod_marca		= '';
	end if

	if _cod_color is null then
		let _cod_color		= '';
	end if

	if _cod_ramo is null then
		let _cod_ramo		= '';
	end if

	if _no_documento[1,2] = '20' then
		let _cod_ramo = 'SODA';
	end if

	let _cod_ramo = trim(_cod_ramo);

	select cod_ramo_ancon
	  into _cod_ramo_ancon
	  from equiramo
	 where cod_agente = a_cod_agente
	   and cod_ramo_agt = _cod_ramo;

	let _cod_subramo = trim(_cod_subramo);

	select cod_subramo_ancon
	  into _cod_subramo_ancon
	  from equisubra
	 where cod_agente		= a_cod_agente
	   and cod_ramo_ancon	= _cod_ramo_ancon
	   and cod_subramo_agt	= _cod_subramo;
	
	let _cod_producto = trim(_cod_producto);

	if (_cod_ramo_ancon is null or _cod_ramo_ancon = '') 
	or (_cod_subramo_ancon is null or _cod_subramo_ancon = '') then   
       
	   foreach
			select cod_subramo_ancon,
				   cod_producto_ancon
			  into _cod_subramo_ancon,
				   _cod_producto_ancon
			  from equiprod
			 where cod_agente 		= a_cod_agente
			   and cod_producto_agt = _cod_producto
			   exit foreach;
		end foreach	   
	else
		foreach
			select cod_producto_ancon
			  into _cod_producto_ancon
			  from equiprod
			 where cod_agente 			= a_cod_agente
			   and cod_ramo_ancon		= _cod_ramo_ancon
			   and cod_subramo_ancon	= _cod_subramo_ancon
			   and cod_producto_agt 	= _cod_producto
			exit foreach;
		end foreach
	end if

	if _cod_ramo_ancon is null or _cod_ramo_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_ramo',
				'No se encontro la Equivalencia para este Ramo.',
				_renglon,
				3,
				a_opcion);
		select count(*)
		  into _cnt_existe
		  from equiramo
		 where cod_agente		= a_cod_agente
		   and cod_ramo_agt		= _cod_ramo;

		if _cnt_existe = 0 then 
			insert into equiramo(
					cod_agente,
					cod_ramo_ancon,
					cod_ramo_agt)
			values	(a_cod_agente,
					null,
					_cod_ramo);
		end if
		
		let _cnt_existe = 0;		
	else
		update prdemielctdet
		   set cod_ramo		= _cod_ramo_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

	if _cod_subramo_ancon is null or _cod_subramo_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_subramo',
				'No se encontro la Equivalencia para este Subramo.',
				_renglon,
				3,
				a_opcion);

		select count(*)
		  into _cnt_existe
		  from equisubra
		 where cod_agente = a_cod_agente
		   and cod_subramo_agt = _cod_subramo;
		
		if _cnt_existe = 0 then
			insert into equisubra(
					cod_agente,
					cod_ramo_ancon,
					cod_subramo_ancon,
					cod_subramo_agt)
			values	(a_cod_agente,
					null,
					null,
					_cod_subramo);
		end if

		let _cnt_existe = 0;

	else
		update prdemielctdet
		   set cod_subramo	= _cod_subramo_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

	if _cod_producto_ancon is null or _cod_producto_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_producto',
			   'No se encontro la Equivalencia para este Producto.',
			   _renglon,
			   3,
			   a_opcion);

		select count(*)
		  into _cnt_existe
		  from equiprod
		 where cod_agente = a_cod_agente
		   and cod_producto_agt	= _cod_producto;

		if _cnt_existe = 0 then
			insert into equiprod(
					cod_agente,
					cod_ramo_ancon,
					cod_subramo_ancon,
					cod_producto_ancon,
					cod_producto_agt)

			values	(a_cod_agente,
					null,
					null,
					null,
					_cod_producto);
		end if
		
		let _cnt_existe = 0;				
	else
		update prdemielctdet
		   set cod_producto	= _cod_producto_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

	let _cod_acreedor = trim(_cod_acreedor);

	if _cod_acreedor <> '0' and _cod_acreedor <> '' then
		select cod_acreedor_ancon
		  into _cod_acreedor_ancon
		  from equiacre
		 where cod_agente		= a_cod_agente
		   and cod_acreedor_agt = _cod_acreedor;

		if _cod_acreedor_ancon is null or _cod_acreedor_ancon = '' then
			insert into equierror(
				   cod_agente,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia,
				   proceso)
			values (a_cod_agente,
					a_num_carga,
					'cod_acreedor',
				   'No se encontro la Equivalencia para este Acreedor.',
				   _renglon,
				   3,
				   a_opcion);
			select count(*)
			  into _cnt_existe
			  from equiacre
			 where cod_agente = a_cod_agente
			   and cod_acreedor_agt = _cod_acreedor;
			   
			if _cnt_existe = 0 then	
				insert into equiacre(
						cod_agente,
						cod_acreedor_ancon,
						cod_acreedor_agt)

				values	(a_cod_agente,
						null,
						_cod_acreedor);
			end if
			let _cnt_existe = 0;
		else
			update prdemielctdet
			   set cod_acreedor	= _cod_acreedor_ancon	
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;
		end if
	end if
	
	let _cod_color = trim(_cod_color);

	select cod_color_ancon
	  into _cod_color_ancon
	  from equicolor
	 where cod_agente		= a_cod_agente
	   and cod_color_agt	= _cod_color;

	if _cod_color_ancon is null or _cod_color_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_color',
			   'No se encontro la Equivalencia para este Color.',
			   _renglon,
			   3,
			   a_opcion);
		select count(*)
		  into _cnt_existe
		  from equicolor
		 where cod_agente = a_cod_agente
		   and cod_color_agt = _cod_color;

		if _cnt_existe = 0 then
			insert into equicolor(
					cod_agente,
					cod_color_ancon,
					cod_color_agt)
			values	(a_cod_agente,
					null,
					_cod_color);
		end if
		let _cnt_existe = 0;

	else
		update prdemielctdet
		   set cod_color	= _cod_color_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

	let _cod_perpago = trim(_cod_perpago);

	select cod_perpago_ancon
	  into _cod_perpago_ancon
	  from equiperpa
	 where cod_agente		= a_cod_agente
	   and cod_perpago_agt	= _cod_perpago;

	if _cod_perpago_ancon is null or _cod_perpago_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_perpago',
			   'No se encontro la Equivalencia para este Periodo de Pago.',
			   _renglon,
			   3,
			   a_opcion);
		select count(*)
		  into _cnt_existe
		  from equiperpa
		 where cod_agente = a_cod_agente
		   and cod_perpago_agt = _cod_perpago;
		   
		if _cnt_existe = 0 then	
			insert into equiperpa(
					cod_agente,
					cod_perpago_ancon,
					cod_perpago_agt)
			values	(a_cod_agente,
					null,
					_cod_perpago);
		end if
		let _cnt_existe = 0;
	else
		update prdemielctdet
		   set cod_perpago	= _cod_perpago_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

   {let _cod_modelo	= _cod_marca;
	let _cod_marca	= null;}
	let _cod_marca = trim(_cod_marca);

	select cod_marca_ancon
	  into _cod_marca_ancon
	  from equimarca
	 where cod_agente		= a_cod_agente
	   and cod_marca_agt	= _cod_marca;

	let _cod_modelo = trim(_cod_modelo);

	if _cod_marca_ancon is not null and _cod_marca_ancon <> '' then 
		select cod_modelo_ancon
		  into _cod_modelo_ancon
		  from equimodel
		 where cod_agente		= a_cod_agente
		   and cod_marca_ancon	= _cod_marca_ancon
		   and cod_modelo_agt	= _cod_modelo;
	else
		
		let _cod_modelo_ancon = '';
		let _cod_marca_ancon = '';
		
		foreach
			select cod_modelo_ancon,
				   cod_marca_ancon	
			  into _cod_modelo_ancon,
				   _cod_marca_ancon	
			  from equimodel
			 where cod_agente		= a_cod_agente
			   and cod_modelo_agt	= _cod_modelo
			exit foreach;
		end foreach
	end if

	if _cod_marca_ancon is null or _cod_marca_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_marca',
			   'No se encontro la Equivalencia para esta Marca.',
			   _renglon,
			   3,
			   a_opcion);

		select count(*)
		  into _cnt_existe
		  from equimarca
		 where cod_agente = a_cod_agente
		   and cod_marca_agt = _cod_marca;

		if _cnt_existe = 0 then
			
			insert into equimarca(
					cod_agente,
					cod_marca_ancon,
					cod_marca_agt)
			values	(a_cod_agente,
					null,
					_cod_marca);
		end if
		let _cnt_existe = 0;

	else
		update prdemielctdet
		   set cod_marca	= _cod_marca_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon; 
	end if
	
	if _cod_modelo_ancon is null or _cod_modelo_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_modelo',
			   'No se encontro la Equivalencia para este Modelo.',
			   _renglon,
			   3,
			   a_opcion);
		
		select count(*)
		  into _cnt_existe
		  from equimodel
		 where cod_agente = a_cod_agente
		   and cod_modelo_agt = _cod_modelo;

		if _cnt_existe = 0 then
			insert into equimodel(
					cod_agente,
					cod_marca_ancon,
					cod_modelo_ancon,
					cod_modelo_agt)
			values	(a_cod_agente,
					null,
					null,
					_cod_modelo);
		end if
		let _cnt_existe = 0;
	else
		update prdemielctdet
		   set cod_modelo	= _cod_modelo_ancon	
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if

	let _cod_ocupacion = trim(_cod_ocupacion);

	select cod_ocupacion_ancon
	  into _cod_ocupacion_ancon
	  from equiocupa
	 where cod_agente			= a_cod_agente
	   and cod_ocupacion_agt	= _cod_ocupacion;

	if _cod_ocupacion_ancon is null or _cod_ocupacion_ancon = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cod_ocupacion',
			   'No se encontro la Equivalencia para esta Ocupación.',
			   _renglon,
			   2,
			   a_opcion);
		select count(*)
		  into _cnt_existe
		  from equiocupa
		 where cod_agente = a_cod_agente
		   and cod_ocupacion_agt = _cod_ocupacion;

		if _cnt_existe = 0 then

			insert into equiocupa(
					cod_agente,
					cod_ocupacion_ancon,
					cod_ocupacion_agt)
			values (a_cod_agente,
					null,
					_cod_ocupacion);
		end if

		let _cnt_existe = 0;
	else
		update prdemielctdet
		   set cod_ocupacion	= _cod_ocupacion_ancon	
		 where cod_agente		= a_cod_agente
		   and num_carga		= a_num_carga
		   and proceso			= a_opcion
		   and renglon			= _renglon;
	end if

	if _cedula is null or _cedula = '' then
		if _tipo_persona = 'N' then
			if _pasaporte is null or _pasaporte = '' then
				insert into equierror(
					   cod_agente,
					   num_carga,
					   campo,
					   descripcion,
					   renglon,
					   importancia,
					   proceso)
				values (a_cod_agente,
						a_num_carga,
						'cedula',
					   'La Cédula no puede ser dejada en blanco.',
					   _renglon,
					   3,
					   a_opcion);
			end if
		else
			if _ruc is null or _ruc = '' then
				insert into equierror(
					   cod_agente,
					   num_carga,
					   campo,
					   descripcion,
					   renglon,
					   importancia,
					   proceso)
				values (a_cod_agente,
						a_num_carga,
						'cedula',
					   'El Ruc no puede ser dejada en blanco.',
					   _renglon,
					   3,
					   a_opcion);
			end if
		end if
	else
		call sp_sis400b(_cedula) returning _cedula;
		update prdemielctdet
		   set cedula = _cedula
		 where cod_agente		= a_cod_agente
		   and num_carga		= a_num_carga
		   and proceso			= a_opcion
		   and renglon			= _renglon;
	end if

	if _cliente_nom is null or _cliente_nom = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cliente_nom',
			   'El Nombre del Cliente no puede ser dejado en blanco.',
			   _renglon,
			   3,
			   a_opcion);		
	end if

	if (_cliente_ape is null or _cliente_ape = '') and _tipo_persona = 'N' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'cliente_ape',
			   'El Apellido del Cliente no puede ser dejado en blanco.',
			   _renglon,
			   3,
			   a_opcion);
	end if

	if _no_documento is null or _no_documento = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'no_documento',
			   'El No. de Póliza es Requerido para Emitir la Póliza.',
			   _renglon,
			   3,
			   a_opcion);
	end if 
	
	if _vigencia_inic is null or _vigencia_inic = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'vigencia_inic',
			   'La Vigencia Inicial es requerida para Emitir la Póliza.',
			   _renglon,
			   3,
			   a_opcion);
	end if 
	
	if _vigencia_fin is null or _vigencia_fin = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'vigencia_final',
			   'La Vigencia Final es requerida para Emitir la Póliza.',
			   _renglon,
			   3,
			   a_opcion);
	end if

	select count(*)
	  into _existe
	  from equierror
	 where campo in ('vigencia_final');

	if _existe = 0 then
		if _vigencia_inic > _vigencia_fin then
			insert into equierror(
				   cod_agente,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia,
				   proceso)
			values (a_cod_agente,
					a_num_carga,
					'vigencia_inic',
					'La Vigencia Inicial no puede ser mayor a la Vigencia Final.',
					_renglon,
				   3,
				   a_opcion);
				   
			insert into equierror(
				   cod_agente,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia,
				   proceso)
			values (a_cod_agente,
					a_num_carga,
					'vigencia_final',
				   'La Vigencia Final no puede ser mayor a la Vigencia Inicial.',
				   _renglon,
				   3,
				   a_opcion);	
		end if
	end if

	if (_telefono1 is null or _telefono1 = '') and (_telefono2 is null or _telefono2 = '') and (_celular is null or _celular = '') then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'telefono1',
			   'El # de Teléfono es requerido para Crear al cliente.',
			   _renglon,
			   3,
			   a_opcion);
	else
		call sp_cas021(_telefono1) returning _return;
		if _return = 1 and (_telefono2 is null or _telefono2 = '') then
			call sp_cas021a(_telefono1) returning _return;
			if _return = 1 then
				insert into equierror(
					   cod_agente,
					   num_carga,
					   campo,
					   descripcion,
					   renglon,
					   importancia,
					   proceso)
				values (a_cod_agente,
						a_num_carga,
						'telefono1',
					   'El # de Teléfono no es válido.',
					   _renglon,
					   3,
					   a_opcion);	
			end if
		end if
	end if

if (_telefono1 is null or _telefono1 = '') and (_celular is null or _celular = '') then
	if _telefono2 is null or _telefono2 = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'telefono2',
			   'El # de Teléfono no es válido.',
			   _renglon,
			   2,
			   a_opcion);
	end if
end if
if _telefono2 is null or _telefono2 = '' then
else
	call sp_cas021(_telefono2) returning _return;
	if _return = 1 then
		call sp_cas021a(_telefono2) returning _return;
		if _return = 1 then
			insert into equierror(
				   cod_agente,
				   num_carga,			  
				   campo,
				   descripcion,
				   renglon,
				   importancia,
				   proceso)
			values (a_cod_agente,
					a_num_carga,
					'telefono2',
				   'El # de Teléfono no es válido.',
				   _renglon,
				   2,
				   a_opcion);
		end if	
	end if
end if
if (_telefono1 is null or _telefono1 = '') and (_telefono2 is null or _telefono2 = '') then
	if _celular is null or _celular = '' then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'celular',
			   'El # de Celular es requerido para Crear al cliente.',
			   _renglon,
			   2,
			   a_opcion);
	end if
end if
if _celular is null or _celular = '' then
else
	call sp_cas021a(_celular) returning _return;
	if _return = 1 then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'celular',
			   'El # de Celular no es válido.',
			   _renglon,
			   2,
			   a_opcion);
	end if
end if

	if (_cod_ramo_ancon is not null and _cod_ramo_ancon <> '')
	and (_cod_producto_ancon is not null and _cod_producto_ancon <> '') then
		--Verificación del Producto vs el Ramo
		select count(*)
		  into _cnt_ramo
		  from equierror
		 where cod_agente	= a_cod_agente
		   and proceso		= a_opcion
		   and num_carga	= a_num_carga
		   and renglon		= _renglon
		   and campo		= 'cod_ramo';
		
		select count(*)
		  into _cnt_prod
		  from equierror
		 where cod_agente	= a_cod_agente
		   and proceso		= a_opcion
		   and num_carga	= a_num_carga
		   and renglon		= _renglon
		   and campo		= 'cod_producto';
		
		if _cnt_ramo = 0 and _cnt_prod = 0 then
			foreach
				select cod_ramo_ancon
				  into _cod_ramo_verif
				  from equiprod
				 where cod_agente = a_cod_agente
				   and cod_producto_ancon = _cod_producto_ancon
				exit foreach;
			end foreach
			
			if _cod_ramo_verif <> _cod_ramo_ancon then
				insert into equierror(
						cod_agente,
						num_carga,
						campo,
						descripcion,
						renglon,
						importancia,
						proceso)
				values	(a_cod_agente,
						a_num_carga,
						'no_documento',
						'El Producto no pertenece al Ramo a Emitir.',
						_renglon,
						3,
						a_opcion);
			end if
		end if
	end if		
	
	if _no_motor is not null then
		--Verifica si el Motor Tiene Guiones
		call sp_sis174(_no_motor) returning _return;
		
		if _return < 0 then
			return _return,0,'Error al verificar las Equivalencias y Excepciones de la carga.','';
		elif _return = 1 then
			--Elimina los guiones del motor
			call sp_sis174a(_no_motor) returning _no_motor;
			update prdemielctdet
			   set no_motor	    = _no_motor
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;
		end if
		
		--Verifica que el motor no este asegurado en otra póliza
		call sp_proe23('00000',_no_motor,_vigencia_inic) returning _return,_no_documento_dup,_vig_final_dup,_no_unidad_dup;
	else
		let _return = 1;
	end if	

	if _return = 1 then
		insert into equierror(
				cod_agente,
				num_carga,
				campo,
				descripcion,
				renglon,
				importancia,
				proceso)
		values (a_cod_agente,
				a_num_carga,
				'no_motor',
				'El Motor esta asegurado en la póliza ' || trim(_no_documento_dup) || ' con Vigencia Final: ' || trim(cast(_vig_final_dup as char(10))),
				_renglon,
				3,
				a_opcion);
				
		return 1,_tot_reg,'','' with resume;
		continue foreach;
	end if

	if _porc_descuento > 1 then
		let _porc_descuento = _porc_descuento /100;
		update prdemielctdet
		   set porc_descuento = _porc_descuento
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
	end if
	--Verificación de diferencia entre Descuento Calculado y Descuento del Archivo

	{let _desc_calculado = _prima_sin_desc * _porc_descuento;
	
	if _descuento <> _desc_calculado then
		insert into equierror(
			   cod_agente,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia,
			   proceso)
		values (a_cod_agente,
				a_num_carga,
				'descuento',
				'El Descuento Calculado por % de Descuento NO coincide con el Monto del Descuento en el Archivo.',
				_renglon,
				3,
				a_opcion);
	end if}

	select proceso
	  into _proceso
	  from prdemielect
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion;

--set debug file to "sp_pro364.trc";
--trace on;

	if _proceso = 'R' then
		let _error = 0;
		let _pool = '';
		let _no_poliza = '';

		if _no_documento[1,2] = '20' then
			call sp_sis21(_no_documento) returning _no_poliza;
			
			if _no_poliza is null or _no_poliza = '' then
				insert into equierror(
					   cod_agente,
					   num_carga,
					   campo,
					   descripcion,
					   renglon,
					   importancia,
					   proceso)
				values (a_cod_agente,
						a_num_carga,
						'no_documento',
					   'No se Encuentra la Póliza en el Sistema.',
					   _renglon,
					   3,
					   a_opcion);
				
				return 1,_tot_reg,'','' with resume;
				continue foreach;
			else
				if _no_documento = '2014-11937-01' then
					set debug file to "sp_pro364.trc";
					trace on;
				end if
					
				call sp_pro318a(_no_poliza) returning _error,_error_desc;
			
				if _error <> 0 then
					return _error,-1,_error_desc,'';
				end if
			end if
		end if

		if _error = 0 then
			
			foreach
				select no_poliza
				  into _no_poliza
				  from emirepol
				 where no_documento = _no_documento
				 order by vigencia_final desc

				let _pool = 'M';
				exit foreach;
			end foreach

			if _pool is null or _pool = '' then
				foreach
					select no_poliza
					  into _no_poliza
					  from emirepo
					 where no_documento = _no_documento
					   and estatus = 1
					 order by vigencia_final desc

					let _pool = 'A';
					exit foreach;
				end foreach	
			end if

			if _no_poliza is null or _no_poliza = '' then
				let _pool = '';
			end if
		else
			let _no_poliza = null;
		end if

		if _no_poliza is null or _no_poliza = '' then
			insert into equierror(
				   cod_agente,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia,
				   proceso)
			values (a_cod_agente,
					a_num_carga,
					'no_documento',
				   'No se Encuentra la Póliza en el Set de Renovación.',
				   _renglon,
				   3,
				   a_opcion);
		else
			let _opcion_final = 0;
	
			{select no_poliza_ant,
				   opcion_final	
			  into _no_poliza,
				   _opcion_final	
			  from emirenduc
			 where no_documento = _no_documento;}

			update prdemielctdet
			   set no_poliza	= _no_poliza,
				   opcion_final	= _opcion_final,
				   pool			= _pool
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;
		end if
	end if

	return 1,_tot_reg,'','' with resume;

end foreach
--trace off;

select count(*)
  into _tot_polizas
  from prdemielctdet
 where cod_agente = a_cod_agente
   and num_carga = a_num_carga
   and proceso		= a_opcion;

select count(*)
  into _cnt_error
  from equierror
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga
   and proceso		= a_opcion
   and importancia	= 3;

if _cnt_error > 0 then   
	update prdemielect
	   set error = 1,
		   tot_polizas	= _tot_polizas
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion;
else
	update prdemielect
	   set tot_polizas = _tot_polizas
	 where cod_agente = a_cod_agente 
	   and num_carga = a_num_carga
	   and proceso		= a_opcion;
end if
   
foreach
	select distinct renglon
	  into _renglon
	  from equierror
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and importancia	= 3

	update prdemielctdet
	   set error = 1
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and renglon		= _renglon;	  
end foreach

--drop table equierror;

return 0,_tot_reg,'Verificacion Exitosa','';
end
end procedure	