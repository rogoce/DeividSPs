-- actualizacion de cambios de usuarios
-- creado    : 17/08/2011 - autor: Roman Gordon 
-- sis v.2.0 - deivid, s.a.  

drop procedure sp_seg008;
create procedure "informix".sp_seg008(a_usuario char(8), a_registro integer)
returning smallint, char(30);

define _acd_agente		   	smallint; 
define _acd_supervisor 	   	smallint; 
define _aprueba_wf_auto    	smallint; 
define _business_obj 	   	smallint; 
define _buzon_print 	   	smallint; 
define _buzon_print2 	   	smallint;
define _claimssearch 	   	smallint;
define _cot_web 		   	smallint; 
define _crear_cliente 	   	smallint;
define _emis_firma_aut 	   	smallint;
define _emite_wf_auto 	   	smallint; 
define _es_medico 		   	smallint;
define _internet		   	smallint; 
define _llamada_celular    	smallint; 
define _llamada_ldi 	   	smallint; 
define _llamada_ldn 	   	smallint;
define _transito 		   	smallint;
define _supervisor_ren 	   	smallint;
define _workflow		   	smallint;
define _registro			smallint;
define _clave_correo 	   	char(30);
define _e_mail			   	char(30);
define _cod_telefono		char(10);
define _buzon_clave2 	   	char(10);
define _buzon_clave		   	char(10); 
define _tel_directo 	   	char(10); 
define _tel_extenci		   	char(10);
define _cod_equipo 		   	char(8);
define _usuario				char(8); 
define _cia_depto 		   	char(5); 
define _cod_perfil_wf_auto 	char(3); 
define _cod_perfil_wf_emis 	char(3); 
define _codigo_perfil	   	char(3);
define _ubicacion_print1   	char(3); 
define _ubicacion_print2   	char(3); 
define _fgl_ver_web 	   	char(1);  
define _status 			   	char(1);
define _fecha_status 	   	date;
define _cod_carnet          integer;
define _control_acceso		integer;


--SET DEBUG FILE TO "sp_seg008.trc"; 
--TRACE ON;
							
let _usuario = a_usuario;
let _registro = a_registro;
 								 
	select acd_agente,			
		   acd_supervisor, 		
		   aprueba_wf_auto, 	
		   business_obj, 		
		   buzon_clave,			
		   buzon_clave2, 		
		   buzon_print, 		
		   buzon_print2, 			
		   claimssearch, 		
		   clave_correo, 		
		   cod_equipo, 			
		   cod_perfil_wf_auto, 	
		   cod_perfil_wf_emis, 	 	
		   codigo_perfil,		
		   control_acceso, 		
		   cot_web, 			
		   crear_cliente, 		 		
		   e_mail,				
		   emis_firma_aut, 		
		   emite_wf_auto, 		
		   es_medico, 		
		   fecha_status, 		
		   fgl_ver_web, 		
		   internet, 			
		   llamada_celular, 	
		   llamada_ldi, 		
		   llamada_ldn, 				
		   status, 				
		   supervisor_ren, 		
		   tel_directo, 		
		   tel_extenci,			 		
		   transito, 			 			
		   ubicacion_print1, 	
		   ubicacion_print2, 	
		   workflow,
		   cod_telefono
	  into _acd_agente,
		   _acd_supervisor, 		
		   _aprueba_wf_auto, 	
		   _business_obj, 		
		   _buzon_clave,		
		   _buzon_clave2, 		
		   _buzon_print, 		
		   _buzon_print2, 		
		   _claimssearch, 		
		   _clave_correo, 		
		   _cod_equipo, 			
		   _cod_perfil_wf_auto, 	
		   _cod_perfil_wf_emis, 	
		   _codigo_perfil,		
		   _control_acceso, 		
		   _cot_web, 			
		   _crear_cliente, 			
		   _e_mail,				
		   _emis_firma_aut, 		
		   _emite_wf_auto, 		
		   _es_medico, 			 		
		   _fecha_status, 		
		   _fgl_ver_web, 		
		   _internet, 			
		   _llamada_celular, 	
		   _llamada_ldi, 		
		   _llamada_ldn, 						
		   _status, 				
		   _supervisor_ren, 		
		   _tel_directo, 		
		   _tel_extenci,					
		   _transito, 			 			
		   _ubicacion_print1, 	
		   _ubicacion_print2, 	
		   _workflow,
		   _cod_telefono
	  from insuser
	 where usuario = a_usuario;
											 
update cambio_user set acd_agente			= _acd_agente,
				   	   acd_supervisor 		= _acd_supervisor, 		
				   	   aprueba_wf_auto 		= _aprueba_wf_auto, 	
				   	   business_obj 		= _business_obj, 		
				   	   buzon_clave			= _buzon_clave,		
				   	   buzon_clave2 		= _buzon_clave2, 		
				   	   buzon_print 			= _buzon_print, 		
				   	   buzon_print2 		= _buzon_print2, 		
				   	   claimssearch 		= _claimssearch, 		
				   	   clave_correo 		= _clave_correo, 		
				   	   cod_equipo 			= _cod_equipo, 			
				   	   cod_perfil_wf_auto	= _cod_perfil_wf_auto, 		
				   	   cod_perfil_wf_emis 	= _cod_perfil_wf_emis, 		
				   	   codigo_perfil		= _codigo_perfil,		
				   	   control_acceso 		= _control_acceso, 		
				   	   cot_web 				= _cot_web, 			
				   	   crear_cliente 		= _crear_cliente, 			
				   	   e_mail				= _e_mail,				
				   	   emis_firma_aut 		= _emis_firma_aut, 		
				   	   emite_wf_auto 		= _emite_wf_auto, 		
				   	   es_medico 			= _es_medico, 				
				   	   fecha_status 		= _fecha_status, 		
				   	   fgl_ver_web 			= _fgl_ver_web, 		
				   	   internet 			= _internet, 			
				   	   llamada_celular 		= _llamada_celular, 	
				   	   llamada_ldi 			= _llamada_ldi, 		
				   	   llamada_ldn 			= _llamada_ldn, 						
				   	   status 				= _status, 				
				   	   supervisor_ren 		= _supervisor_ren, 		
				   	   tel_directo 			= _tel_directo, 		
				   	   tel_extenci			= _tel_extenci,			 		
				   	   transito 			= _transito, 			 			
				   	   ubicacion_print1 	= _ubicacion_print1, 	
				   	   ubicacion_print2 	= _ubicacion_print2, 	
				   	   workflow				= _workflow,
					   cod_telefono			= _cod_telefono
			 	 where usuario  = a_usuario
			   	   and registro = a_registro;
				   
insert into segv05:insuserh
select * 
  from insuser
 where usuario  = a_usuario;
 
end procedure








































































































































