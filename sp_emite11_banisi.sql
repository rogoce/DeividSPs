-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11_banisi;

create procedure "informix".sp_emite11_banisi() 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);					
define _deducible_colision	varchar(50);                  
define _deducible_incendio	varchar(50);                  
define _deducible_robo		varchar(50);                  
define _aseg_primer_nom	varchar(50);                      
define _aseg_segundo_nom	varchar(50);                               
define _aseg_segundo_ape	varchar(50);                               
define _aseg_primer_ape	varchar(50);                               
define _aseg_ape_casada	varchar(50);                               
define _asegurado			varchar(50);                       
define _email				varchar(50);                       
define _modelo				varchar(50);                   
define _marca				varchar(50);                      
define _color				varchar(50);                      
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
define _cod_grupo			char(5);                            
define _cod_marca			char(5);                            
define _cod_compania		char(3);                            
define _cod_sucursal		char(3);                            
define _cod_impuesto		char(3);                            
define _cod_subramo			char(3);                        
define _cod_tipoveh			char(3);                        
define _tipo_veh			char(3);                            
define _cod_ramo			char(3);                            
define _provincia			char(2);                            
define _inicial				char(2);                        
define _nuevo_usado		char(1);                            
define _tipo_persona		char(1);                            
define _null				char(1);                            
define _limite_lesiones1		dec(16,2);                     
define _limite_lesiones2		dec(16,2);                     
define _limite_muerte1		dec(16,2);                     
define _limite_muerte2		dec(16,2);                     
define _deduc_comprensivo		dec(16,2);                  
define _prima_comprensivo		dec(16,2);                  
define _tarifa_colision		dec(16,2);                     
define _suma_asegurada		dec(16,2);                     
define _limite_asist1		dec(16,2);                     
define _limite_asist2		dec(16,2);                     
define _limite_dpa1			dec(16,2);                     
define _limite_dpa2			dec(16,2);                     
define _prima_asistencia		dec(16,2);
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
define _fecha_aniversario		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _error_isam			smallint;
define _capacidad			smallint;
define _ano_actual			smallint;
define _ano_tarifa			smallint;
define _auto_nuevo			smallint;
define _no_pagos			smallint;
define _puertas				smallint;
define _serie				smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _ano_auso			smallint;
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
	--let _serie = year(_vigencia_inic);
	let _cod_ramo = '002';
	let _cod_subramo = '001';
	let _cod_compania = '001';
	let _cod_sucursal = '001';
	let _poliza_maestra_auto = '0225-01276-01';
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
		select first 10 aseg_primer_nom,
				trim(aseg_segundo_nom),
				trim(aseg_primer_ape),
				trim(aseg_segundo_ape),
				trim(aseg_casada_ape),
				cedula,
				fecha_aniversario,
				nuevo_usado,
				uso_auto,
				vigencia_inic,
				vigencia_final,
				codgrupo,
				cod_agente,
				cod_marca,
				nombre_marca,
				cod_modelo,
				nombre_modelo,
				ano_auto,
				ano_uso,
				placa,
				no_motor,
				no_chasis,
				puertas,
				color,
				tipo_veh,
				cod_producto,
				suma_asegurada,
				deduc_comprensivo,
				deduc_colision,
				deduc_robo,
				lesiones_lim1,
				lesiones_lim2,
				prima_lesiones,
				dpa_lim1,
				dpa_lim2,
				prima_dpa,
				asist_medica_lim1,
				asist_medica_lim2,
				prima_asist,
				muerte_lim1,
				muerte_lim2,
				prima_muerte,
				prima_endoso,
				prima_sin_impuesto,
				prima_con_impuesto,
				no_pagos
		  into _aseg_primer_nom,
			   _aseg_segundo_nom,   
			   _aseg_primer_ape,    
			   _aseg_segundo_ape,   
			   _aseg_ape_casada,    
			   _cedula,              
			   _fecha_aniversario,  
			   _nuevo_usado,        
			   _uso_auto,            
			   _vigencia_inic,       
			   _vigencia_final,     
			   _cod_grupo,           
			   _cod_agente,          
			   _cod_marca,           
			   _marca,               
			   _cod_modelo,          
			   _modelo,              
			   _ano_auto,            
			   _ano_auso,            
			   _placa,
			   _no_motor,            
			   _no_chasis,           
			   _puertas,            
			   _color,
			   _tipo_veh,
			   _cod_producto,       
			   _suma_asegurada,    
			   _deduc_comprensivo, 
			   _deducible_colision,
			   _deducible_robo,     
			   _limite_lesiones1,    
			   _limite_lesiones2,   
			   _prima_lesiones,     
			   _limite_dpa1,        
			   _limite_dpa2,
			   _prima_dpa, 
			   _limite_asist1,     
			   _limite_asist2,     
			   _prima_asistencia,    
			   _limite_muerte1,     
			   _limite_muerte2,    
			   _prima_muerte,      
			   _prima_naviera,       
			   _subtotal,
			   _prima,
			   _no_pagos
		  from deivid_tmp:carga_corp_cred
		 where procesado = 0 
		   and motivo is null
		 order by cedula

		let _no_poliza_mae = sp_sis21(_poliza_maestra_auto);
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
		let _tipo_persona = 'N';
		
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
						   _aseg_primer_nom,			--ls_primernombre char(40),  			   ,	    
						   _aseg_segundo_nom,			--ls_segundonombre char(40), 			   , 
						   _aseg_primer_ape,			--ls_primerapellido char(40), 			   , 
						   _aseg_segundo_ape,						--ls_segundoapellido char(40),			   ,
						   _aseg_ape_casada,		--ls_apellidocasada char(40),			   ,
						   '',  			--ls_razonsocial char(100),   			   ,
						   _cedula,		   			--ls_cedula char(30),        			   ,	 
						   _ruc,		   			--ls_ruc char(30),           			   _estado_civil,	 
						   '',		   		--ls_pasaporte char(30),     			   ,	 
						   '',		   		--ls_direccion char(50),     			   ,	 
						   _null,		   			--ls_apartado char(20),      			   ,	 
						   '210-8700',		   		--ls_telefono1 char(10),     			   ,	 
						   _null,		   		--ls_telefono2 char(10),     			   ,
						   _null,		   			--ls_fax char(10),           			   ,_cod_ocupacion
						   'atencionclientes@asegurancon.com',		   			--ls_email char(50),         			 
						   _fecha_aniversario,		--ld_fechaaniversario	date,			 
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
					   direccion_cob	= 'BANISI',
					   digito_ver		= '00'
				 where cod_cliente		= _cod_cliente;
			end if
		else
			update cliclien
			   set --cod_ocupacion	= _cod_ocupacion,
				   direccion_cob	= 'BANISI',
				   e_mail = 'atencionclientes@asegurancon.com'
			 where cod_cliente		= _cod_cliente;
		end if
			
			update tmp_poliza_mae
			   set no_poliza = _no_poliza,
				   pol_maestra = 0,
				   no_documento = _no_documento,
				   cod_contratante = _cod_cliente,
				   cod_pagador = _cod_cliente,
				   cod_formapag = '006',
				   no_factura = null,
				   fecha_suscripcion = current,
				   fecha_impresion = current,
				   date_changed = current,
				   date_added = current,
				   user_added = 'DEIVID',
				   reemplaza_poliza = null,
				   actualizado = 0,
				   fecha_primer_pago = _vigencia_inic,
				   vigencia_inic = _vigencia_inic,
				   vigencia_final = _vigencia_final,
				   wf_aprob =0,
				   wf_firma_aprob = null,
				   wf_incidente =null,
				   wf_fecha_entro = null,
				   wf_fecha_aprob = null;

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
		
		-- Insertar Unidad
		select *
		  from emipouni
		 where no_poliza = _no_poliza_mae
		 into temp tmp_unidad_mae;

		update tmp_unidad_mae
		   set no_poliza = _no_poliza,
			   cod_producto = _cod_producto,
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
		   from prddesc
		  where cod_producto = _cod_producto;


		-- Insercion de las Tablas de Soda y Automovil
		if _ramo_sis = 1 then

			let _ano_actual = year(today);
			--let _ano_tarifa = _ano_actual - _ano_auto + 1;

			if _ano_auso <= 1 then
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
						5);
			else
				update emivehic
				   set valor_auto = _suma_asegurada, placa = _placa
				 where no_motor = _no_motor;
			end if 
			
			let _cod_tipoveh = '005';

			if _cod_producto in ('08259','08256','08261','08127','08255') then --PESADO
				let _cod_tipoveh = '010';
			elif _cod_producto in ('08258') then --MEDIANO
				let _cod_tipoveh = '009';
			elif _cod_producto in ('08257') then --LIVIANO
				let _cod_tipoveh = '008';
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
					'00001',
					_tipo_veh,		--??????????
					_no_motor,
					'P',
					_ano_auso,
					0);
		end if
		
		--Insert de Acreedores
		insert into emipoacr(no_poliza,no_unidad,cod_acreedor,limite)
		values(_no_poliza,'00001','02412',_suma_asegurada);

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
		 where cod_producto = _cod_producto;
		 
		let _prima_colision = (_subtotal - (_prima_lesiones / 1.55) - (_prima_dpa/ 1.55) - (_prima_asistencia/1.55) - _prima_naviera)/2;
		let _prima_comprensivo = (_subtotal - (_prima_lesiones / 1.55) - (_prima_dpa/ 1.55) - (_prima_asistencia/1.55) - _prima_naviera)/2;

		update emipocob
		   set limite_1 = _limite_lesiones1,
			   limite_2 = _limite_lesiones2,
			   prima_anual = _prima_lesiones,
			   prima = _prima_lesiones,
			   prima_neta = _prima_lesiones / 1.55
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00102'; --LESIONES
			
		update emipocob
		   set limite_1 = _limite_dpa1,
			   prima_anual = _prima_dpa,
			   prima = _prima_dpa,
			   prima_neta = _prima_dpa/ 1.55
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00113'; -- DPA
			
		update emipocob
		   set deducible = _deducible_colision,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_colision,
			   prima = _prima_colision,
			   prima_neta = _prima_colision
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00119'; --COLISION
		
		update emipocob
		   set deducible = _deduc_comprensivo,
			   limite_1 = _suma_asegurada,
			   prima_anual = _prima_comprensivo,
			   prima = _prima_comprensivo,
			   prima_neta = _prima_comprensivo
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00118'; --COMPRENSIVO
			
		update emipocob
		   set deducible = _deduc_comprensivo,
			   limite_1 = _suma_asegurada,
			   prima_anual = 0,
			   prima = 0,
			   prima_neta = 0
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00120'; --INCENDIO
			
		update emipocob
		   set deducible = _deduc_comprensivo,
			   limite_1 = _suma_asegurada,
			   prima_anual = 0,
			   prima = 0,
			   prima_neta = 0
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00103'; --ROBO
			
		update emipocob
		   set limite_1 = _limite_muerte1,
			   limite_2 = _limite_muerte2,
			   prima_anual = _prima_muerte,
			   prima = _prima_muerte,
			   prima_neta = _prima_muerte
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00123'; --MUERTE
			
		/*update emipocob
		   set limite_1 = 15000,
			   limite_2 = 10000
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00108'; --INVALIDEZ
		*/
			
		update emipocob
		   set limite_1 = _limite_asist1,
			   limite_2 = _limite_asist2,
			   prima_anual = _prima_asistencia,
			   prima = _prima_asistencia,
			   prima_neta = _prima_asistencia/1.55
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00117'; --ASISTENCIA

		update emipocob
		   set prima_anual = _prima_naviera,
			   prima = _prima_naviera,
			   prima_neta = _prima_naviera
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '01535'; -- EXTRA PLUS

		--Cargar el Reaseguro Individual de la Unidad
		call sp_sis107a(_no_poliza)	returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if

		--Actualizar los valores en las unidades
		call sp_proe02(_no_poliza, '00001', '001') returning li_return;
		--call sp_proe04(_no_poliza, '00001',_suma_asegurada, '001') returning li_return;

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
			--call sp_sis61b(_no_poliza) returning _error_isam,_no_poliza;
			
			update deivid_tmp:carga_corp_cred
			   set procesado = -1,motivo = _error_desc
			 where no_motor = _no_motor; 
			 
			return _error,_error_desc with resume;
			
			continue foreach;
		end if

		update deivid_tmp:carga_corp_cred
		   set no_documento = _no_documento,
			   no_poliza = _no_poliza,
			   procesado = 1
		 where no_motor = _no_motor; 
	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
