-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11_corp_cred_ajust;

create procedure "informix".sp_emite11_corp_cred_ajust() 
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

	drop table if exists tmp_poliza_mae;
	drop table if exists tmp_unidad_mae;

	foreach
		select first 10 
				vigencia_inic,
				vigencia_final,
				suma_asegurada,
				deduc_comprensivo,
				deduc_colision,
				deduc_robo,
				prima_lesiones,
				prima_dpa,
				prima_asist,
				prima_muerte,
				prima_endoso,
				prima_sin_impuesto,
				prima_con_impuesto,
				no_poliza
		  into _vigencia_inic,       
			   _vigencia_final,     
			   _suma_asegurada,    
			   _deduc_comprensivo, 
			   _deducible_colision,
			   _deducible_robo,     
			   _prima_lesiones,     
			   _prima_dpa, 
			   _prima_asistencia,    
			   _prima_muerte,      
			   _prima_naviera,       
			   _prima,
			   _subtotal,
			   _no_poliza
		  from deivid_tmp:carga_corp_cred
		 where procesado = 0 
		   and vigencia_inic = '01/07/2025'
		 order by no_poliza

		update emipomae
		   set actualizado = 0
		 where no_poliza = _no_poliza;
		 
		update endedmae
		   set actualizado = 0
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
		 
		let _prima_colision = (_subtotal - (_prima_lesiones / 1.55) - (_prima_dpa/ 1.55) - (_prima_asistencia/1.55) - _prima_naviera)/2;
		let _prima_comprensivo = (_subtotal - (_prima_lesiones / 1.55) - (_prima_dpa/ 1.55) - (_prima_asistencia/1.55) - _prima_naviera)/2;

		update emipocob
		   set prima_anual = _prima_colision,
			   prima = _prima_colision,
			   prima_neta = _prima_colision
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00119'; --COLISION
		
		update emipocob
		   set prima_anual = _prima_comprensivo,
			   prima = _prima_comprensivo,
			   prima_neta = _prima_comprensivo
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00118'; --COMPRENSIVO
		
		update endedcob
		   set prima_anual = _prima_colision,
			   prima = _prima_colision,
			   prima_neta = _prima_colision
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00119' --COLISION
		   and no_endoso = '00000';
		
		update endedcob
		   set prima_anual = _prima_comprensivo,
			   prima = _prima_comprensivo,
			   prima_neta = _prima_comprensivo
		 where no_poliza = _no_poliza
		   and no_unidad = '00001'
		   and cod_cobertura = '00118' --COMPRENSIVO
		   and no_endoso = '00000';
			
	
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
		
		update emipomae
		   set prima_neta = _subtotal,
			   prima_suscrita =_subtotal,
			   prima_bruta = _prima,
			   actualizado = 1
		 where no_poliza = _no_poliza;
		 
		update endedmae
		   set prima_neta = _subtotal,
			   prima_suscrita =_subtotal,
			   prima_bruta = _prima,
			   actualizado = 1
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';

		update endedhis
		   set prima_neta = _subtotal,
			   prima_suscrita =_subtotal,
			   prima_bruta = _prima,
			   actualizado = 1
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';

		update emipouni
		   set prima_neta = _subtotal,
			   prima_suscrita =_subtotal,
			   prima_bruta = _prima
		 where no_poliza = _no_poliza;
		 
		update endeduni
		   set prima_neta = _subtotal,
			   prima_suscrita =_subtotal,
			   prima_bruta = _prima
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';

		-- Actualización de la Póliza
		--call sp_pro374 (_no_poliza) returning _error,_error_isam,_error_title,_error_desc;		
		/*call sp_sis17(_no_poliza) returning _error;

		if _error > 0 then
			--call sp_sis61b(_no_poliza) returning _error_isam,_no_poliza;
			
			update deivid_tmp:carga_corp_cred
			   set procesado = -1,motivo = _error_desc
			 where no_motor = _no_motor; 
			 
			return _error,_error_desc with resume;
			
			continue foreach;
		end if
		*/

		update deivid_tmp:carga_corp_cred
		   set procesado = 1
		 where no_poliza = _no_poliza;
		 
	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
