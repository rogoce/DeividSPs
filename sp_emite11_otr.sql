-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11_otr;
create procedure "informix".sp_emite11_otr() 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);
define _deducible_colision	varchar(50);
define _deducible_incendio	varchar(50);
define _deducible_robo		varchar(50);
define _asegurado			varchar(50);
define _email				varchar(50);
define _poliza_ant			varchar(30);
define _cedula				varchar(30);
define _no_documento		varchar(20);
define _no_chasis			varchar(30);
define _no_motor			varchar(30);
define _uso_auto			char(30);
define _ruc					char(30);
define _poliza_maestra_auto	char(20);
define _poliza_maestra_tran	char(20);
define _cod_producto		char(10);
define _cod_cliente			char(10);
define _no_poliza_mae		char(10);
define _no_poliza			char(10);
define _estatus				char(10);
define _tipo				char(10);
define _periodo				char(7);
define _asiento				char(7);
define _tomo				char(7);
define _placa				char(6);
define _cod_agente			char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_impuesto		char(3);
define _cod_subramo			char(3);
define _cod_tipoveh			char(3);
define _cod_ramo			char(3);
define _provincia			char(2);
define _inicial				char(2);
define _tipo_persona		char(1);
define _null				char(1);
define _limite_lesiones1	dec(16,2);
define _limite_lesiones2	dec(16,2);
define _tarifa_colision		dec(16,2);
define _suma_asegurada		dec(16,2);
define _limite_dpa1			dec(16,2);
define _limite_dpa2			dec(16,2);
define _prima_asistencia	dec(16,2);
define _prima_extraterr		dec(16,2);
define _prima_lesiones		dec(16,2);
define _prima_colision		dec(16,2);
define _prima_incendio		dec(16,2);
define _prima_naviera		dec(16,2);
define _prima_muerte		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_robo			dec(16,2);
define _prima_dpa			dec(16,2);
define _impuesto			dec(16,2);
define _subtotal			dec(16,2);
define _prima				dec(16,2);
define _factor_impuesto		dec(5,2);
define _porc_comision		dec(5,2);
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _no_unidad_int		smallint;
define _error_isam			smallint;
define _capacidad			smallint;
define _ano_actual			smallint;
define _ano_tarifa			smallint;
define _auto_nuevo			smallint;
define _tipo_veh			smallint;
define _serie				smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _tipo_doc			smallint;
define _cnt_auto			smallint;
define _existe				smallint;
define _error				smallint;

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

 -- Actualización del Endoso
	--call sp_pro43(a_poliza, a_endoso) returning _error,_error_desc;

--	if _error <> 0 then
--		return _error,_error_desc;
--	end if

	let _fecha_hoy = today;
	let _cod_agente = '02311';
	--let _serie = year(_vigencia_inic);
	let _cod_ramo = '002';
	let _cod_subramo = '016';
	let _cod_compania = '001';
	let _cod_sucursal = '001';
	let _prima_muerte = 0.00;
	let _prima_extraterr = 0.00;
	let _prima_naviera = 0.00;
	let _null = null;
	
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	select emi_periodo 														   
	  into _periodo
	  from parparam;
	  
	drop table if exists tmp_poliza_mae;
	drop table if exists tmp_unidad_mae;

	foreach
		select first 5 
			   no_unidad,
			   contratante,
			   cod_marca,
			   cod_modelo,
			   anio,
			   placa,
			   no_motor,
			   chasis,
			   suma_asegurada,
			   tipo_auto,
			   uso,
			   prima_itbms,
			   cod_producto,
			   limite_lesiones1,
			   limite_lesiones2,
			   prima_lesiones,
			   limite_dpa1,
			   --limite_dpa2,
			   prima_dpa,
			   asistencia_vial,
			   ded_col_vuelco,
			   --prima_incendio,
			   incendio_robo,
			   --prima_robo,
			   --deduc_robo,
			   prima_asiento,
			   --prima_naviera,
			   --extraterritorial,
			  --prima_asistencia,
			   sub_total_prima,
			   cant_puesto
		  into _no_unidad_int,
			   _asegurado,
			   _cod_marca,
			   _cod_modelo,
			   _ano_auto,
			   _placa,
			   _no_motor,
			   _no_chasis,
			   _suma_asegurada,
			   _tipo_veh,
			   _uso_auto,
			   _prima,
			   _cod_producto,
			   _limite_lesiones1,
			   _limite_lesiones2,
			   _prima_lesiones,
			   _limite_dpa1,
			   --_limite_dpa2,
			   _prima_dpa,
			   _prima_asistencia,
			   _deducible_colision,
			   --_prima_incendio,
			   _deducible_incendio,
			   --_prima_robo,
			   --_deducible_robo,
			   _prima_muerte,
			   --_prima_naviera,
			   --_prima_extraterr,
			   --_prima_asistencia,
			   _subtotal,
			   _capacidad
		  from deivid_tmp:carga_dist_otr
		 where procesado = 0 
		   and motivo is null
		  -- and cod_producto not in ('12004','12005')
		 order by no_unidad

		let _no_unidad = '00000';
		let _cod_tipoveh = '000';
		let _limite_dpa2 = 0.00;
		
		if _prima_muerte is null then
			let _prima_muerte = 0.00;
		end if
		
		if _no_unidad_int > 99 then
			let _no_unidad[3,5] = _no_unidad_int;
		elif _no_unidad_int > 9   then
			let _no_unidad[4,5] = _no_unidad_int;
		else
			let _no_unidad[5,5] = _no_unidad_int;
		end if

		/*if _tipo_veh > 99 then
			let _cod_tipoveh[3,5] = _tipo_veh;
		elif _tipo_veh > 9   then
			let _cod_tipoveh[4,5] = _tipo_veh;
		else
			let _cod_tipoveh[5,5] = _tipo_veh;
		end if*/
		
		if _tipo_veh = 5 then
			let _cod_tipoveh = '005';
		elif _tipo_veh = 8 then
			let _cod_tipoveh = '008';
		elif _tipo_veh = 9 then
			let _cod_tipoveh = '009';
		elif _tipo_veh = 10 then
			let _cod_tipoveh = '010';
		end if

		let _impuesto = _prima - _subtotal;
		let _cod_cliente = '153447';
		let _no_poliza = '0003290281';

		/*
		let _tipo_doc = 1;
		call sp_sis108(_cedula,_tipo_doc) returning _existe,_cod_cliente;			
		
		let _ruc = '';
		
		if _tipo_persona = 'J' then
			let _ruc = _cedula;
			let _cedula = '';
		end if

		if _existe = 0 then
			call sp_sis400(_cedula) returning _provincia,_inicial,_tomo,_asiento;
			let _null = null;

			call sp_sis372(_cod_cliente,			--ls_valor_nuevo char(10),				    
						   0,						--ll_nrocotizacion int,  			   
						   _tipo_persona,			--ls_tipopersona char(1),   				    
						   'A',						--ls_tipocliente char(1),   			   	   ,
						   _asegurado,			--ls_primernombre char(40),  			   ,	    
						   '',						--ls_segundonombre char(40), 			   , 
						   '',			--ls_primerapellido char(40), 			   , 
						   '',						--ls_segundoapellido char(40),			   ,
						   '',		--ls_apellidocasada char(40),			   ,
						   _asegurado,  			--ls_razonsocial char(100),   			   ,
						   _cedula,		   			--ls_cedula char(30),        			   ,	 
						   _ruc,		   			--ls_ruc char(30),           			   _estado_civil,	 
						   '',		   		--ls_pasaporte char(30),     			   ,	 
						   '',		   		--ls_direccion char(50),     			   ,	 
						   _null,		   			--ls_apartado char(20),      			   ,	 
						   '210-8700',		   		--ls_telefono1 char(10),     			   ,	 
						   _null,		   		--ls_telefono2 char(10),     			   ,
						   _null,		   			--ls_fax char(10),           			   ,_cod_ocupacion
						   _email,		   			--ls_email char(50),         			 
						   _null,		--ld_fechaaniversario	date,			 
						   _null,		   			--ls_sexo char(1),   			 
						   'DEIVID',	   			--ls_usuario char(8),			 
						   '001',		   				--ls_compania	char(3),			 
						   '001',		   				--ls_agencia char(3),			 
						   _provincia,	   			--ls_provincia char(2),			 
						   _inicial,	   			--ls_inicial char(2),			 
						   _tomo,		   			--ls_tomo char(7),			 
						   '',			   			--ls_folio char(7),			 
						   _asiento,	   			--ls_asiento char(7),			 
						   '',			   			--ls_direccion2 varchar(50) de			 
						   _null)	   			--ls_celular varchar(10)
						   returning _error;

			if _error <> 0 then
				return _error,'Error al crear al Cliente, intente nuevamente';
			else		
				update cliclien
				   set --cod_ocupacion	= _cod_ocupacion,
					   direccion_cob	= 'TOTAL SEGUROS',
					   digito_ver		= '00'
				 where cod_cliente		= _cod_cliente;
			end if
		else
			update cliclien
			   set --cod_ocupacion	= _cod_ocupacion,
				   direccion_cob	= 'TOTAL SEGUROS',
				   e_mail = 'cobros@totalsegurospa.com'
			 where cod_cliente		= _cod_cliente;
		end if
			
			update tmp_poliza_mae
			   set no_poliza = _no_poliza,
				   poliza_maestra = _poliza_maestra_auto,
				   pol_maestra = 0,
				   no_documento = _no_documento,
				   no_factura = null,
				   fecha_suscripcion = current,
				   fecha_impresion = current,
				   date_changed = current,
				   date_added = current,
				   user_added = 'DEIVID',
				   reemplaza_poliza = null,
				   actualizado = 0;

			--Insert a Emipomae
			insert into emipomae
			select * from tmp_poliza_mae;

			let _porc_comision = sp_pro305(_cod_agente, _cod_ramo,_cod_subramo);

			if _porc_comision is null then
				let _porc_comision = 0.00;
			end if
			
			--Insert Emipoagt
			insert into emipoagt(
			cod_agente,
			no_poliza,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc
			)
			values (
			_cod_agente,		--cod_agente
			_no_poliza,		--no_poliza
			100,			    --porc_partic_agt
			0,		--porc_comis_agt
			100					--porc_produc
			);
			
			insert into emigloco
					(no_poliza,
					no_endoso,
					orden,
					cod_contrato,
					porc_partic_prima,
					porc_partic_suma,
					suma_asegurada,
					prima,
					cod_ruta)
			select _no_poliza,
				   no_endoso,
				   orden,
				   cod_contrato,
				   porc_partic_prima,
				   porc_partic_suma,
				   suma_asegurada,
				   prima,
				   cod_ruta
			 from emigloco
			 where no_poliza = _no_poliza_mae;

			-- Información de Impuestos
			foreach 
				select cod_impuesto 
				  into _cod_impuesto
				  from prdimsub
				 where cod_ramo    = _cod_ramo
				   and cod_subramo = _cod_subramo

				select factor_impuesto
				  into _factor_impuesto
				  from	prdimpue
				 where cod_impuesto = _cod_impuesto;

			   
				insert into emipolim(
				no_poliza,
				cod_impuesto,
				monto
				)
				values (
				_no_poliza,	   --no_poliza
				_cod_impuesto,	   --cod_impuesto
				_impuesto
				);
			end foreach
		*/
		
		
		-- Insertar Unidad
		select *
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		 into temp tmp_unidad_mae;

		update tmp_unidad_mae
		   set cod_producto = _cod_producto,
			   cod_asegurado = _cod_cliente,
			   impuesto =  _impuesto,
			   prima_neta = _subtotal,
			   prima_bruta = prima,
			   suma_asegurada = _suma_asegurada,
			   no_unidad = _no_unidad;

		if _no_unidad = '00001' then
			update emipouni
			   set cod_producto = _cod_producto,
				   cod_asegurado = _cod_cliente,
				   impuesto =  _impuesto,
				   prima_neta = _subtotal,
				   prima_bruta = prima,
				   suma_asegurada = _suma_asegurada
			 where no_poliza = _no_poliza
		       and no_unidad = _no_unidad;
		else
			insert into emipouni
			select *
			  from tmp_unidad_mae;
			  
			-- Descuento de la Unidad
			Insert into emiunide
					(no_poliza,
					no_unidad,
					cod_descuen,
					porc_descuento,
					subir_bo)
			 select no_poliza,
					_no_unidad,
					cod_descuen,
					porc_descuento,
					subir_bo
			   from emiunide
			  where no_poliza = _no_poliza
				and no_unidad = '00001';
		end if

		-- Descripcion de la Unidad
		Insert into emipode2
				(no_poliza,
				no_unidad,
				descripcion)
		 select first 1 _no_poliza,
				_no_unidad,
				descripcion
		   from prddesc
		  where cod_producto = _cod_producto;

		-- Insercion de las Tablas de Soda y Automovil
		if _ramo_sis = 1 then

			let _ano_actual = year(today);
			let _ano_tarifa = _ano_actual - _ano_auto + 1;

			if _ano_tarifa <= 1 then
				let _auto_nuevo = 1;
			else
				let _auto_nuevo = 0;
			end if

			select count(*)
			  into _cnt_auto
			  from emivehic
			 where no_motor = _no_motor;

			if _cnt_auto = 0 then
				call sp_sis178(_placa) returning _placa;
				insert into emivehic(
						no_motor,
						cod_marca,
						cod_modelo,
						valor_auto,
						valor_original,
						ano_auto,
						no_chasis,
						vin,
						placa,
						placa_taxi,
						nuevo,
						user_added,
						date_added,
						cod_color,
						capacidad)
				values	(_no_motor,
						_cod_marca,										   
						_cod_modelo,									   
						_suma_asegurada,
						0.00,
						_ano_auto,
						_no_chasis,
						_no_chasis,
						_placa,
						null,
						_auto_nuevo,
						'DEIVID',
						today,
						'001',
						_capacidad);
			else
				update emivehic
				   set valor_auto = _suma_asegurada, placa = _placa,
					   capacidad = _capacidad
				 where no_motor = _no_motor;
			end if 

			if _cod_producto in ('12000') then	--P
				--let _cod_tipoveh = '005';
				let _uso_auto = 'P';
			elif _cod_producto in ('12001') then	--LIVIANO
				--let _cod_tipoveh = '005';
				let _uso_auto = 'C';
			else								--PESADO
				--let _cod_tipoveh = '008';
				let _uso_auto = 'C';
			end if
			
			insert into emiauto																						  	
				   (no_poliza,
					no_unidad,
					cod_tipoveh,
					no_motor,
					uso_auto,
					ano_tarifa,
					subir_bo
				   )
			 values(_no_poliza,
					_no_unidad,
					_cod_tipoveh,		--??????????
					_no_motor,
					_uso_auto,
					_ano_tarifa,
					0);
		end if

		--Insert de Coberturas
		insert into emipocob
		select _no_poliza,
			   _no_unidad,
			   cod_cobertura,
			   orden,
			   0,
			   '', --deducible
			   0, --limite?1
			   0, --limite_2
			   0, --prima_anual
			   0, --prima
			   0, --descuento
			   0, --recargo
			   0, --prima_neta
			   _fecha_hoy,
			   _fecha_hoy,
			   1, --factor_vigencia
			   desc_limite1,
			   desc_limite2,
			   0, --prima_vida
			   0, --prima_vida_orig
			   0  --subir_bo
		  from prdcobpd
		 where cod_producto = _cod_producto
		   and cob_default = 1;

		update emipocob
		   set limite_1 = _limite_lesiones1,
			   limite_2 = _limite_lesiones2,
			   prima_anual = _prima_lesiones,
			   prima = _prima_lesiones,
			   prima_neta = _prima_lesiones
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01299'; --LESIONES
			
		update emipocob
		   set limite_1 = _limite_dpa1,
			   prima_anual = _prima_dpa,
			   prima = _prima_dpa,
			   prima_neta = _prima_dpa
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01304'; -- DPA
			
		update emipocob
		   set deducible = _deducible_colision,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_colision,
			   prima = _prima_colision,
			   prima_neta = _prima_colision
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01307'; --COLISION
			
		update emipocob
		   set deducible = _deducible_colision,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_colision,
			   prima = _prima_colision,
			   prima_neta = _prima_colision
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01306'; --COLISION
			
		update emipocob
		   set deducible = _deducible_incendio,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_incendio,
			   prima = _prima_incendio,
			   prima_neta = _prima_incendio
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01308'; --INCENDIO
			
		update emipocob
		   set deducible = _deducible_robo,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_robo,
			   prima = _prima_robo,
			   prima_neta = _prima_robo
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01300'; --ROBO
			
		update emipocob
		   set limite_1 = 1500,
			   limite_2 = 5000,
			   prima_anual = _prima_muerte,
			   prima = _prima_muerte,
			   prima_neta = _prima_muerte
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01309'; --MUERTE
			
		update emipocob
		   set limite_1 = 15000,
			   limite_2 = 10000
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01303'; --INVALIDEZ
			
		update emipocob
		   set limite_1 = 0,
			   limite_2 = 0,
			   prima_anual = _prima_asistencia,
			   prima = _prima_asistencia,
			   prima_neta = _prima_asistencia
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01310'; --ASISTENCIA

		update emipocob
		   set limite_1 = 10000,
			   limite_2 = 10000			   
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01302'; --GASTOS MEDICOS
			
		update emipocob
		   set limite_1 = 10000,
			   limite_2 = 10000			   
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01305'; --GASTOS MEDICOS
		   
			
		update emipocob
		   set prima_anual = _prima_naviera,
			   prima = _prima_naviera,
			   prima_neta = _prima_naviera
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01315'; -- NAVIERA
			
		update emipocob
		   set limite_1 = _suma_asegurada,
			   prima_anual = _prima_extraterr,
			   prima = _prima_extraterr,
			   prima_neta = _prima_extraterr
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01841'; -- EXTRATERRITORIAL
		
		update emipocob
		   set prima_anual = _prima_naviera,
			   prima = _prima_naviera,
			   prima_neta = _prima_naviera
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = '01657'; -- EXTRA PLUS
			

		--Cargar el Reaseguro Individual de la Unidad
		call sp_sis107a(_no_poliza)	returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if

		--Actualizar los valores en las unidades
		call sp_proe02(_no_poliza, _no_unidad, '001') returning li_return;

		if li_return = 0 then
			let li_return = sp_proe03(_no_poliza,'001');
			
			if li_return <> 0 then
				return li_return,_error_desc;
			end if
		else
			return li_return,_error_desc;
		end if

		call sp_proe03(_no_poliza,'001') returning li_return;

		if li_return <> 0 then
			return li_return,'Error al Emitir la Póliza ';
		end if

		drop table if exists tmp_poliza_mae;
		drop table if exists tmp_unidad_mae;

		-- Actualización de la Póliza
		--call sp_pro374 (_no_poliza) returning _error,_error_isam,_error_title,_error_desc;		
		/*call sp_sis17(_no_poliza) returning _error;

		if _error > 0 then
			--call sp_sis61b(_no_poliza) returning _error_isam,_no_poliza;
			
			update deivid_tmp:carga_truckingV2
			   set procesado = -1,motivo = _error_desc
			 where poliza_ant = _poliza_ant; 
			 
			return _error,_error_desc with resume;
			
			continue foreach;
		end if
		*/
		update deivid_tmp:carga_dist_otr
		   set procesado = 1
		 where no_unidad = _no_unidad; 
	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
