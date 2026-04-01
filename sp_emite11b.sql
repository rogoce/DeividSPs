-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11b;

create procedure "informix".sp_emite11b() 
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
define _no_doc_auto			varchar(20);
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
define _error_isam			smallint;
define _capacidad			smallint;
define _ano_actual			smallint;
define _ano_tarifa			smallint;
define _auto_nuevo			smallint;
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
	let _cod_ramo = '009';
	let _cod_subramo = '009';
	let _cod_compania = '001';
	let _cod_sucursal = '001';
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
		select first 100 
			   poliza_maestra_trans,
			   asegurado,
			   cedula,
			   tipo_persona,
			   poliza_ant,
			   email,
			   suma_aseg_tr,
			   prima_neta_tr,
			   prima_bruta_tr,
			   no_documento
		  into _poliza_maestra_tran,
			   _asegurado,
			   _cedula,
			   _tipo_persona,
			   _poliza_ant,
			   _email,
			   _suma_asegurada,
			   _subtotal,
			   _prima,
			   _no_doc_auto
		  from deivid_tmp:carga_serafin
		 where no_documento is not null
		   and suma_aseg_tr is not null
		   and procesado = 0
		   order by no_documento

		let _no_poliza_mae = sp_sis21(_poliza_maestra_tran);
		let _impuesto = _prima - _subtotal;
		
		select * 
		  from emipomae
		 where no_poliza = _no_poliza_mae
		  into temp tmp_poliza_mae;

		let _no_poliza = sp_sis13 ("001", 'PRO', '02', 'par_no_poliza');
		let _error = sp_pro222 (_no_poliza,'00001',_suma_asegurada,'001',0);
		let _no_documento = sp_sis19(_cod_compania, _cod_sucursal, _no_poliza_mae);  
		
		
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
				   poliza_maestra = _poliza_maestra_tran,
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

			/*let _porc_comision = sp_pro305(_cod_agente, _cod_ramo,_cod_subramo);

			if _porc_comision is null then
				let _porc_comision = 0.00;
			end if*/
			
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
		
		-- Insertar Unidad
		select *
		  from emipouni
		 where no_poliza = _no_poliza_mae
		 into temp tmp_unidad_mae;

		update tmp_unidad_mae
		   set no_poliza = _no_poliza,
			   cod_asegurado = _cod_cliente,
			   impuesto =  _impuesto,
			   prima_neta = _subtotal,
			   prima_bruta = prima,
			   suma_asegurada = _suma_asegurada;

		insert into emipouni
		select *
		  from tmp_unidad_mae;

		-- Descripcion de la Unidad
		Insert into emipode2
				(no_poliza,
				no_unidad,
				descripcion)
		 select first 1 _no_poliza,
				'00001',
				descripcion
		   from emipode2
		  where no_poliza = _no_poliza_mae;


		--Insert de Coberturas
		insert into emipocob
		select _no_poliza,
			   '00001',
			   cod_cobertura,
			   orden,
			   0,
			   '', --deducible
			   0, --limite?1
			   0, --limite_2
			   _subtotal, --prima_anual
			   _subtotal, --prima
			   0, --descuento
			   0, --recargo
			   _subtotal, --prima_neta
			   _fecha_hoy,
			   _fecha_hoy,
			   1, --factor_vigencia
			   '',
			   '',
			   0, --prima_vida
			   0, --prima_vida_orig
			   0  --subir_bo
		  from emipocob
		 where no_poliza = _no_poliza_mae;
	

		/*--Cargar el Reaseguro Individual de la Unidad
		call sp_sis107a(_no_poliza)	returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if*/
		
		insert into emifacon
		select _no_poliza,
			   no_endoso,
			   no_unidad,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   cod_ruta,
			   porc_partic_suma,
			   porc_partic_prima,
			   _suma_asegurada,
			   _subtotal,
			   0,
			   0
		 from emifacon
		 where no_poliza = _no_poliza_mae;

		--Actualizar los valores en las unidades
		call sp_proe02(_no_poliza, '00001', '001') returning li_return;

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
		call sp_sis17(_no_poliza) returning _error;

		if _error > 0 then
			call sp_sis61b(_no_poliza) returning _error_isam,_no_poliza;
			
			update deivid_tmp:carga_serafin
			   set procesado = -1,motivo = _error_desc
			 where poliza_ant = _poliza_ant; 
			 
			return _error,_error_desc with resume;
			
			continue foreach;
		end if

		update deivid_tmp:carga_serafin
		   set no_documento_tr = _no_documento,
			   procesado = 1
		 where no_documento = _no_doc_auto; 
	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
