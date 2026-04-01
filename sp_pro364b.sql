-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas tecnica de seguros.
-- Creado    : 25/08/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro364b;

create procedure "informix".sp_pro364b(a_cod_agente char(5),a_num_carga char(5),a_opcion char(1))
returning integer,
		  smallint,
		  char(30),
          char(100);

define _no_documento     			varchar(20);
define _cod_ramo        		   	varchar(30);
define _observaciones     			varchar(250);
define _desc_unidad					varchar(250);
define _cedula						varchar(30);
define _ruc							varchar(30);
define _cliente_nom				    varchar(50);
define _segundo_nombre				varchar(50);
define _primer_apellido				varchar(50);
define _segundo_apellido			varchar(50);
define _apellido_cazada				varchar(50);
define _email						varchar(50);
define _direccion                   varchar(100);
define _direccion_cobros            varchar(100);
define _pasaporte                   varchar(30);
define _no_poliza                   varchar(10);
define _codigo                      varchar(10);
define _cod_formapag                varchar(30);
define _prima                       dec(10,2);
define _descuento                   dec(10,2);
define _prima_neta                  dec(10,2);
define _porc_impuesto               dec(10,2);
define _impuesto                    dec(10,2);
define _prima_bruta                 dec(10,2);
define _suma_asegurada				dec(10,2);
define _no_pagos                    integer;
define _li_bandera_tipo             integer;
define _existe                      integer;
define _error_excep					integer;
define _error_isam					integer;
define _renglon						integer;
define _tot_reg                     smallint;
define _cnt_existe					smallint;
define _cnt_error					smallint;
define _cnt_ramo					smallint;
define _cnt_prod					smallint;
define _cnt_unidad                  smallint;
define _contador                 smallint;
define _return						smallint;
define _tot_polizas					smallint;
define _error_desc					char(50);
define _sexo                        char(1);
define _estado_civil                char(1);
define _tipo_persona				char(1);
define _cod_subramo                 char(3);
define _telefono1                   char(10);
define _telefono2					char(10);
define _celular						char(10);
define _proceso                     char(1);
define _cod_formapago               char(20);
define _cod_perpago                 char(20);
define _responsable_cobro			char(20);
define _cod_ramo_ancon				char(3);
define _cod_subramo_ancon			char(3);
define _cod_producto_ancon			char(5);
define _cod_perpago_ancon			char(3);
define _cod_ramo_verif				char(3);
define _no_unidad					char(5);
define _cod_producto				char(10);
define _fecha_registro              date;
define _vigencia_inic				date;
define _fecha_aniversario           date;
define _vigencia_fin				date;


set debug file to "sp_pro364b.trc";
trace on;

set isolation to dirty read;

begin
on exception set _error_excep,_error_isam,_error_desc
	delete from equierror 
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion;

	return _error_excep,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

let _cod_producto	= '';
let _cod_subramo	= '';
let _cod_perpago	= '';
let _pasaporte		= '';
let _cod_ramo		= '';
let _ruc			= '';
let _no_poliza		= null;
let _responsable_cobro = '';

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
		   observaciones,
		   suma_asegurada, 
		   no_unidad, 
		   cod_producto, 
		   desc_unidad, 
		   cedula,
		   pasaporte, 
		   ruc, 
		   cliente_nom,
		   conductor_nom,
		   cliente_ape, 
		   cliente_ape_seg, 
		   cliente_ape_casada, 
		   tipo_persona, 
		   fecha_aniversario, 
		   sexo,
		   estado_civil, 
		   telefono1,
		   telefono2,
		   celular, 
		   e_mail, 
		   direccion,
		   direccion_cobros,
		   proceso, 
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
		   renglon
	  into _no_documento,
		   _cod_ramo,
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
		   _segundo_nombre,
		   _primer_apellido,
		   _segundo_apellido,
		   _apellido_cazada,
		   _tipo_persona,
		   _fecha_aniversario,
		   _sexo,
		   _estado_civil,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _email,
		   _direccion,
		   _direccion_cobros,
		   _proceso,
		   _prima,
		   _descuento,
		   _prima_neta,
		   _porc_impuesto,
		   _impuesto,
		   _prima_bruta,
		   _fecha_registro,
		   _cod_formapago,
		   _cod_perpago,
		   _no_pagos,
		   _renglon
	  from prdemielctdet
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	
	let	_apellido_cazada = sp_sis179(_apellido_cazada);
	--let	_direccion_cobros = sp_sis179(_direccion_cobros);
	let	_segundo_apellido = sp_sis179(_segundo_apellido);
	if trim(_cliente_nom) <> '' then
		let _cliente_nom = sp_sis179(_cliente_nom);
	end if
	if trim(_segundo_nombre) <> '' then
		let _segundo_nombre = sp_sis179(_segundo_nombre);
	end if
	if trim(_primer_apellido) <> '' then
		let _primer_apellido = sp_sis179(_primer_apellido);
	end if
	--let _cliente_nom = trim(_cliente_nom) || " " || trim(_segundo_nombre);
	
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
	
	if a_cod_agente = '00180' then
		let _cod_formapag	= '008';
	end if
	
	update prdemielctdet
	   set cliente_nom			= _cliente_nom,
		   cliente_ape			= _primer_apellido,
		   cliente_ape_seg		= _segundo_apellido,
		   cliente_ape_casada	= _apellido_cazada,
		   cod_formapag			= _cod_formapag,
		   conductor_nom		= " "
		--   direccion			= _direccion,
		--   direccion_cobros		= _direccion_cobros
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and renglon		= _renglon;

	if _cedula is null then 
		let _cedula	= '';
	end if
	
	if _pasaporte is null then
		let _pasaporte = '';
	end if

	if _ruc is null then
		let _ruc = '';
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

	if _cod_ramo is null then
		let _cod_ramo		= '';
	end if

	if _no_documento[1,2] = '20' then
		let _cod_ramo = 'SODA';
	end if

	--let _cod_ramo = trim('016');

	select cod_ramo_ancon
	  into _cod_ramo_ancon
	  from equiramo
	 where cod_agente = a_cod_agente
	   and cod_ramo_agt = _cod_ramo;

	let _cod_subramo = trim('002');

	select cod_subramo_ancon
	  into _cod_subramo_ancon
	  from equisubra
	 where cod_agente		= a_cod_agente
	   and cod_ramo_ancon	= _cod_ramo_ancon
	   and cod_subramo_agt	= _cod_subramo;
	
	let _cod_producto = trim(_cod_producto);

	if (_cod_ramo_ancon is null or _cod_ramo_ancon = '') 
	or (_cod_subramo_ancon is null or _cod_subramo_ancon = '') then   

		select cod_subramo_ancon,
			   cod_producto_ancon
		  into _cod_subramo_ancon,
			   _cod_producto_ancon
		  from equiprod
		 where cod_agente 		= a_cod_agente
		   and cod_producto_agt = _cod_producto;
	else
		select cod_producto_ancon
		  into _cod_producto_ancon
		  from equiprod
		 where cod_agente 			= a_cod_agente
		   and cod_ramo_ancon		= _cod_ramo_ancon
		   and cod_subramo_ancon	= _cod_subramo_ancon
		   and cod_producto_agt 	= _cod_producto;
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

	if (_primer_apellido is null or _primer_apellido = '') and _tipo_persona = 'N' then
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

	if (_telefono1 is null or _telefono1 = '') and (_telefono2 is null or _telefono2 = '') then
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
					   'El # de Teléfono es requerido para Crear al cliente.',
					   _renglon,
					   3,
					   a_opcion);	
			end if
		end if
	end if

/*	if _telefono2 is null or _telefono2 = '' then
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
	else
*/
	if _telefono2 is not null or _telefono2 <> '' then
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
						'telefono1',
					   'El # de Teléfono no es válido.',
					   _renglon,
					   2,
					   a_opcion);
			end if	
		end if
	end if

/*
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
			   'El # de Teléfono no es válido.',
			   _renglon,
			   2,
			   a_opcion);
	else
*/
	if _celular is not null or _celular <> '' then
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
				    'El # de Teléfono no es válido.',
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

end foreach
--trace off;

select count(*)
  into _tot_polizas
  from prdemielctdet
 where cod_agente = a_cod_agente
   and num_carga  = a_num_carga
   and proceso	  = a_opcion;
   
	if a_opcion = 'C' or a_opcion = 'E' then  
		select count(distinct(no_documento))
		  into _tot_polizas
		  from prdemielctdet
		 where cod_agente = a_cod_agente
		   and num_carga = a_num_carga
		   and proceso		= a_opcion;
	end if
	
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

foreach
	select no_documento
	 into _no_documento
	 from prdemielctdet
    where cod_agente	= a_cod_agente
	  and num_carga		= a_num_carga
	  and proceso		= a_opcion
	  
   select count(no_unidad)
	 into _cnt_unidad
	 from prdemielctdet
    where cod_agente	= a_cod_agente
	  and num_carga		= a_num_carga
	  and proceso		= a_opcion
	  and no_documento  = _no_documento;

	  let _contador = 0;
	  
		if _cnt_unidad > 1 then
		foreach
		    select no_unidad
			  into _no_unidad
			  from prdemielctdet
			 where cod_agente	= a_cod_agente
			   and num_carga    = a_num_carga
			   and proceso		= a_opcion
			   and no_documento = _no_documento
				if _contador = 0 then
					update prdemielctdet
					   set capacidad = 0
					 where cod_agente	 = a_cod_agente
					   and num_carga	 = a_num_carga
					   and proceso		 = a_opcion
					   and no_documento  = _no_documento
					   and no_unidad 	 = _no_unidad;
					   let _contador = _contador + 1;
				else
					update prdemielctdet
					   set capacidad     = NULL
					 where cod_agente	 = a_cod_agente
					   and num_carga	 = a_num_carga
					   and proceso		 = a_opcion
					   and no_documento  = _no_documento
					   and no_unidad 	 = _no_unidad;
				end if
		end foreach
		else
			update prdemielctdet
			   set capacidad = 0
			 where cod_agente	 = a_cod_agente
			   and num_carga	 = a_num_carga
			   and proceso		 = a_opcion
			   and no_documento  = _no_documento;
		end if
		--continue foreach;
end foreach	  
	  
--drop table equierror;

return 0,_tot_reg,'Verificacion Exitosa','';
end
end procedure	