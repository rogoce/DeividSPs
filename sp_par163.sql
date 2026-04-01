-- Procedimiento para crear en clibitacora todos los registros de clientes nuevos y modificados
--
-- Creado    : 13/09/2005 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par163;

CREATE PROCEDURE "informix".sp_par163(a_cliente CHAR(10), a_tipo_mov CHAR(1))
 
define _username	char(32);
DEFINE _CANT        INTEGER;

let _username = sp_sis84();

-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;   

SELECT COUNT(*) 
  INTO _CANT                                                                
  FROM CLICLIEN
 WHERE COD_CLIENTE = a_cliente;

IF _CANT > 0 THEN

	INSERT INTO clibitacora(
		cod_cliente,       
		cod_compania,      
		cod_sucursal,      
		cod_origen,        
		cod_grupo,         
		cod_clasehosp,     
		cod_espmedica,     
		cod_ocupacion,     
		cod_trabajo,       
		cod_actividad,     
		code_pais,         
		code_provincia,    
		code_ciudad,       
		code_distrito,     
		code_correg,       
		nombre,            
		nombre_razon,      
		direccion_1,       
		direccion_2,       
		apartado,          
		tipo_persona,      
		actual_potencial,  
		cedula,            
		telefono1,         
		telefono2,         
		e_mail,            
		fax,               
		date_added,        
		user_added,        
		de_la_red,         
		mala_referencia,   
		desc_mala_ref,     
		fecha_aniversario, 
		sexo,              
		digito_ver,        
		date_changed,      
		user_changed,      
		nombre_original,   
		ced_provincia,     
		ced_inicial,       
		ced_tomo,          
		ced_folio,         
		ced_asiento,       
		aseg_primer_nom,   
		aseg_segundo_nom,  
		aseg_primer_ape,   
		aseg_segundo_ape,  
		aseg_casada_ape,   
		ced_correcta,      
		pasaporte,         
		cotizacion,        
		de_cotizacion,     
		celular,           
		dia_cobros1,       
		dia_cobros2,       
		contacto,          
		telefono3,         
		direccion_cob,     
		es_taller,         
		proveedor_autorizado,
		ip_number,
		tipo_mov,
		fecha_modif,
		cod_mala_refe,
		user_mala_refe,
		periodo_pago,
		tipo_cuenta,
		cod_cuenta,
		cod_banco,
		tipo_pago          
		)
		SELECT cod_cliente,       
			   cod_compania,      
			   cod_sucursal,      
			   cod_origen,        
			   cod_grupo,         
			   cod_clasehosp,     
			   cod_espmedica,     
			   cod_ocupacion,     
			   cod_trabajo,       
			   cod_actividad,     
			   code_pais,         
			   code_provincia,    
			   code_ciudad,       
			   code_distrito,     
			   code_correg,       
			   nombre,            
			   nombre_razon,      
			   direccion_1,       
			   direccion_2,       
			   apartado,          
			   tipo_persona,      
			   actual_potencial,  
			   cedula,            
			   telefono1,         
			   telefono2,         
			   e_mail,            
			   fax,               
			   date_added,        
			   user_added,        
			   de_la_red,         
			   mala_referencia,   
			   desc_mala_ref,     
			   fecha_aniversario, 
			   sexo,              
			   digito_ver,        
			   date_changed,      
			   _username,      
			   nombre_original,   
			   ced_provincia,     
			   ced_inicial,       
			   ced_tomo,          
			   ced_folio,         
			   ced_asiento,       
			   aseg_primer_nom,   
			   aseg_segundo_nom,  
			   aseg_primer_ape,   
			   aseg_segundo_ape,  
			   aseg_casada_ape,   
			   ced_correcta,      
			   pasaporte,         
			   cotizacion,        
			   de_cotizacion,     
			   celular,           
			   dia_cobros1,       
			   dia_cobros2,       
			   contacto,          
			   telefono3,         
			   direccion_cob,     
		 	   es_taller,         
			   proveedor_autorizado,
			   ip_number,
			   a_tipo_mov,
			   current,
			   cod_mala_refe,
			   user_mala_refe,
			   periodo_pago,
			   tipo_cuenta,
			   cod_cuenta,
			   cod_banco,
			   tipo_pago          
		  FROM cliclien
	 WHERE cod_cliente = a_cliente; 	             

END IF

END PROCEDURE
