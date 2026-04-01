-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas 
--https://app.asegurancon.com/poliza_web/view_varias_polizas_download.php
-- Creado    : 28/07/2022 - Autor: Román  Gordón
-- Modificado: 27/03/2026 - Autor: Federico Coronado  sp que se utiliza en la pagina web para emitir AP
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite14;
create procedure "informix".sp_emite14(a_no_poliza char(10), a_cod_producto varchar(20),a_cod_benef varchar(30)) 
returning	smallint, char(10),varchar(200);


define _error_title				varchar(200);
define _error_desc				varchar(200);					
define _nom_asegurado			varchar(50);                       
define _nom_benef				varchar(50);                       
define _tipo					varchar(50);                       
define _no_documento			varchar(20);                       
define _cod_producto			char(10);  
define _cod_producto_tmp		char(10);                        
define _cod_contratante			char(10);
define _cod_pagador             char(10);         
define _cod_asegurado			char(10);                      
define _cod_benef				char(10);                      
define _no_poliza_auto			char(10);                      
define _no_poliza_mae			char(10);                      
define _no_poliza				char(10);                          
define _user_emitio				char(8);
define _periodo					char(7);
define _cod_agente				char(5);                        
define _cod_parentesco			char(3);
define _cod_compania			char(3);                            
define _cod_sucursal			char(3);                            
define _cod_impuesto			char(3);                            
define _cod_subramo				char(3);                        
define _cod_ramo				char(3);                            
define _null					char(1);                            
define _suma_asegurada			dec(16,2);                     
define _impuesto				dec(16,2);
define _factor_impuesto			dec(5,2);
define _porc_partic_ben			dec(5,2);
define _porc_comision			dec(5,2);
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_hoy				date;
define _error_isam				smallint;
define li_return				smallint;
define _error					smallint;
define _cod_formapago           char(3);
define _no_pagos                integer;
define _cod_perpago             char(3);
define _cotizacion				char(16);
define _cod_grupo               char(5); 

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,'',_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite14.trc"; 
	--trace on;

	drop table if exists tmp_productos;
	drop table if exists tmp_beneficiarios;

 	drop table if exists tmp_codigos;
	let _tipo = sp_sis04(a_cod_producto);
	
	select *
	  from tmp_codigos
	 into temp tmp_productos;
	 
	drop table if exists tmp_codigos;
	
	let _tipo = sp_sis04(a_cod_benef);
	
	select *
	  from tmp_codigos
	 into temp tmp_beneficiarios;
	 
	drop table if exists tmp_codigos;
	
	select emi.no_poliza,
		    emi.vigencia_inic,
			emi.vigencia_final,
			emi.cod_contratante,
			emi.user_added,
			agt.cod_agente,
			uni.cod_asegurado,
			cli.nombre,
			emi.cod_formapag,
			emi.no_pagos,
			emi.cod_perpago,
			emi.cod_sucursal,
			emi.cotizacion,
			emi.cod_pagador,
			emi.cod_grupo
	  into _no_poliza_auto,
		    _vigencia_inic,
			_vigencia_final,
			_cod_contratante,
			_user_emitio,
			_cod_agente,
			_cod_asegurado,
			_nom_asegurado,
			_cod_formapago,
			_no_pagos,
			_cod_perpago,
			_cod_sucursal,
			_cotizacion,
			_cod_pagador,
			_cod_grupo
	  from emipomae emi
	 inner join emipoagt agt on agt.no_poliza = emi.no_poliza
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
	 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
	 where emi.no_poliza = a_no_poliza;
	
	
	let _fecha_hoy = today;
	--let _cod_contratante = '11465'; --Contratante AA
	let _null = null;
	
	select emi_periodo 														   
	  into _periodo
	  from parparam;

	drop table if exists tmp_poliza_mae;
	drop table if exists tmp_unidad_mae;
	drop table if exists tmp_emipocob;

	foreach
		    select codigo
			  into _cod_producto_tmp
			  from tmp_productos
		foreach
			select first 1 emi.no_poliza,
					emi.cod_compania,
					emi.cod_ramo,
					emi.cod_subramo,
				--	uni.cod_asegurado,
					uni.cod_producto,
					emi.suma_asegurada
			  into _no_poliza_mae,
					_cod_compania,
					_cod_ramo,
					_cod_subramo,
				--	_cod_asegurado,
					_cod_producto,
					_suma_asegurada
			  from emipomae emi
			 inner join emipouni uni on uni.no_poliza = emi.no_poliza
			 --inner join tmp_productos tmp on tmp.codigo = uni.cod_producto
			 where emi.cod_contratante = '11465'
			   and uni.cod_producto = _cod_producto_tmp
			 order by emi.no_poliza--,tmp.codigo
		 end foreach

		select * 
		  from emipomae
		 where no_poliza = _no_poliza_mae
		  into temp tmp_poliza_mae;

		let _no_poliza = sp_sis13 ("001", 'PRO', '02', 'par_no_poliza');
		let _error = sp_pro222 (_no_poliza,'00001',_suma_asegurada,'001',0);
		let _no_documento = sp_sis19(_cod_compania, _cod_sucursal, _no_poliza_mae);  
		
		update tmp_poliza_mae
		   set no_poliza 		= _no_poliza,
			   --serie = 2025,
			   pol_maestra 			= 0,
			   no_documento 		= _no_documento,
			   cod_contratante 		= _cod_contratante,
			   cod_pagador 			= _cod_pagador,
			   no_factura 			= null,
			   fecha_suscripcion 	= current,
			   fecha_impresion 		= current,
			   date_changed 		= current,
			   date_added 			= current,
			   nueva_renov 			= 'N',
			   user_added 			= _user_emitio,
			   reemplaza_poliza 	= null,
			   actualizado 			= 0,
			   estatus_poliza 		= 1,
			   cod_no_renov 		= null,
			   vigencia_inic 		= _vigencia_inic,
			   fecha_primer_pago 	= _vigencia_inic,
			   vigencia_final 		= _vigencia_final,
			   wf_aprob 			= 0,
			   wf_firma_aprob 		= null,
			   wf_incidente 		= null,
			   wf_fecha_entro 		= null,
			   cod_formapag 		= _cod_formapago,
			   no_pagos     		= _no_pagos,
			   cod_sucursal 		= _cod_sucursal,
			   cotizacion           = _cotizacion,
			   cod_perpago			= _cod_perpago,
			   cod_grupo 			= _cod_grupo,
			   wf_fecha_aprob 		= null;

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
			_porc_comision,		--porc_comis_agt
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
				0
				);
			end foreach
		
		-- Insertar Unidad
		select *
		  from emipouni
		 where no_poliza = _no_poliza_mae
		 into temp tmp_unidad_mae;

		update tmp_unidad_mae
		   set no_poliza = _no_poliza,
			   cod_asegurado = _cod_asegurado,
			   desc_unidad = _nom_asegurado;

		insert into emipouni
		select *
		  from tmp_unidad_mae;
		  
		-- Descripcion de la Unidad
		Insert into emiunide
				(no_poliza,
				no_unidad,
				cod_descuen,
				porc_descuento,
				subir_bo
				)
		 select first 1 _no_poliza,
				'00001',
				cod_descuen,
				porc_descuento,
				subir_bo
		   from emiunide
		  where no_poliza = _no_poliza_mae;		

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

		--Insert a emipocob
		--insert into emipocob
		--select * from tmp_emipocob;
				--Insert a emipocob
		select * from emipocob 
		 where no_poliza = _no_poliza_mae
		into temp tmp_emipocob;

		update tmp_emipocob
		   set no_poliza = _no_poliza;

		insert into emipocob
		select *
		  from tmp_emipocob;

		foreach
			select ben.codigo,
				    cli.apartado,
					cli.cod_clasehosp,
					cli.nombre
			  into _cod_benef,
				   _porc_partic_ben,
				   _cod_parentesco,
				   _nom_benef
			  from tmp_beneficiarios ben
			 inner join cliclien cli on cli.cod_cliente = ben.codigo

			insert into emibenef(
			no_poliza,
			no_unidad,
			cod_cliente,
			cod_parentesco,
			benef_desde,
			nombre,
			porc_partic_ben)			
			values(
			_no_poliza,
			'00001',
			_cod_benef,
			_cod_parentesco,
			_vigencia_inic,
			_nom_benef,
			_porc_partic_ben
			);		
		end foreach

		--Actualizar los valores en las Coberturas
		call sp_proe01(_no_poliza, '00001', '001') returning li_return;
		
		--Cargar el Reaseguro Individual de la Unidad
		call sp_sis107a(_no_poliza)	returning _error,_error_desc;

		if _error <> 0 then
			return _error,_no_poliza,_error_desc;
		end if

		--Actualizar los valores en emifacon		
		call sp_proe04(_no_poliza, '00001',_suma_asegurada, '001') returning li_return;

		--Actualizar los valores en las unidades
		call sp_proe02(_no_poliza, '00001', '001') returning li_return;


		if li_return = 0 then
			let li_return = sp_proe03(_no_poliza,'001');
			
			if li_return <> 0 then
				return li_return,_no_poliza,_error_desc;
			end if
		else
			return li_return,_no_poliza,_error_desc;
		end if

		call sp_proe03(_no_poliza,'001') returning li_return;

		if li_return <> 0 then
			return li_return,_no_poliza,'Error al Emitir la Póliza ';
		end if

		drop table if exists tmp_poliza_mae;
		drop table if exists tmp_unidad_mae;
		drop table if exists tmp_emipocob;

		-- Actualización de la Póliza
		--call sp_pro374 (_no_poliza) returning _error,_error_isam,_error_title,_error_desc;		
		call sp_sis17(_no_poliza) returning _error;

		if _error > 0 then
			--call sp_sis61b(_no_poliza) returning _error_isam,_no_poliza;			
			return _error,_no_poliza,_error_desc with resume;
			
			continue foreach;
		end if
	return _error,_no_poliza,"Actualización Exitosa" with resume;	
	end foreach
	end
end procedure
