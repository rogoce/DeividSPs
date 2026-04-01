-- Actualizacion de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.  

--drop procedure sp_seg004a;
create procedure "informix".sp_seg004a(a_usuario CHAR(8), a_status CHAR(1), a_fecha_status date, a_chg_user  char(8), a_registro integer)
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          		INTEGER  ;
DEFINE r_error        		SMALLINT ;
DEFINE r_error_isam   		SMALLINT ;
DEFINE r_descripcion  		CHAR(30) ;
DEFINE _fecha_status    	DATE     ;
DEFINE _fecha_proceso   	DATE     ;
DEFINE _usuario				CHAR(8)  ;
DEFINE _status				CHAR(1)  ;
DEFINE _cargo				CHAR(50) ;										
DEFINE _codigo_compania		CHAR(3)	 ;										
DEFINE _cia_depto			CHAR(5)	 ;										
DEFINE _codigo_agencia		CHAR(3)	 ;										
DEFINE _ubicacion			CHAR(50) ;										
DEFINE _observ				CHAR(255);										
DEFINE _equipo				SMALLINT ;										
DEFINE _tipo_equipo			SMALLINT ;										
DEFINE _llamada_celular		SMALLINT ;										
DEFINE _llamada_ldn			SMALLINT ;										
DEFINE _llamada_ldi			SMALLINT ;										
DEFINE _control_acceso		SMALLINT ;										
DEFINE _fgl_ver_web			CHAR(1)	 ;										
DEFINE _crear_cliente		SMALLINT ;										
DEFINE _claimssearch		SMALLINT ;										
DEFINE _cot_web				SMALLINT ;										
DEFINE _transito			SMALLINT ;										
DEFINE _workflow			SMALLINT ;										
DEFINE _internet			SMALLINT ;										
DEFINE _business_obj		SMALLINT ;										
DEFINE _cod_perfil_wf_auto	CHAR(3)	 ;										
DEFINE _emite_wf_auto		SMALLINT ;										
DEFINE _aprueba_wf_auto		SMALLINT ;										
DEFINE _h_usuario			CHAR(8)	 ;
DEFINE _h_fecha_inicio		DATE	 ;
DEFINE _h_dias_password		SMALLINT ;
DEFINE _h_hora_inicio		DATE     ;	
DEFINE _h_hora_final		DATE     ;	
DEFINE _h_ultimo_login		DATE	 ;
DEFINE _h_no_login_permitido SMALLINT;	
DEFINE _h_ult_cbio_password	DATE	 ;
DEFINE _h_codigo_perfil		CHAR(3)	 ;
DEFINE _h_descripcion		CHAR(30) ;	
DEFINE _h_password			CHAR(10) ;
DEFINE _h_e_mail			CHAR(30) ;	
DEFINE _h_fecha_final		DATE	 ;
DEFINE _h_status			CHAR(1)	 ;
DEFINE _h_fecha_status		DATE	 ;
DEFINE _h_fecha_cambio		DATE	 ;
DEFINE _h_code_idioma		CHAR(2)	 ;
DEFINE _h_codigo_menu		CHAR(40) ;	
DEFINE _h_nivel				CHAR(2)	 ;
DEFINE _h_crear_cliente		SMALLINT ;
DEFINE _h_aut_endoso		SMALLINT ;	
DEFINE _h_windows_user		CHAR(20) ;
DEFINE _h_supervisor_ren	SMALLINT ;	
DEFINE _h_fvac_out			DATE	 ;
DEFINE _h_sac_user			SMALLINT ;
DEFINE _h_cia_depto			CHAR(5)	 ;
DEFINE _h_tel_directo		CHAR(10) ;	
DEFINE _h_tel_extenci		CHAR(10) ;	
DEFINE _h_fgl_ver_web		CHAR(1)	 ;
DEFINE _h_com_ejecutivo		CHAR(1)	 ;
DEFINE _h_codigo_compania	CHAR(3)	 ;
DEFINE _h_codigo_agencia	CHAR(3)	 ;
DEFINE _h_ubicacion			CHAR(50) ;
DEFINE _h_observ			CHAR(255);	
DEFINE _h_cod_carnet		INTEGER	 ;
DEFINE _h_tipo_equipo		SMALLINT ;	
DEFINE _h_llamada_celular	SMALLINT ;	
DEFINE _h_llamada_ldn		SMALLINT ;	
DEFINE _h_llamada_ldi		SMALLINT ;	
DEFINE _h_control_acceso	SMALLINT ;	
DEFINE _h_acd_agente		SMALLINT ;	
DEFINE _h_acd_supervisor	SMALLINT ;	
DEFINE _h_claimssearch		SMALLINT ;
DEFINE _h_transito			SMALLINT ;
DEFINE _h_cot_web			SMALLINT ;	
DEFINE _h_clave_correo		CHAR(30) ;
DEFINE _h_buzon_print		SMALLINT ;	
DEFINE _h_cod_telefono		CHAR(10) ;
DEFINE _h_cod_equipo		CHAR(8)	 ;
DEFINE _h_buzon_clave		CHAR(10) ;	
DEFINE _h_cod_motivo		CHAR(3)	 ;
DEFINE _h_cargo				CHAR(50) ;
DEFINE _h_cod_perfil_wf_auto CHAR(3) ;	
DEFINE _h_emite_wf_auto		SMALLINT ;
DEFINE _h_aprueba_wf_auto	SMALLINT ;	
DEFINE _h_es_medico			SMALLINT ;
DEFINE _h_buzon_print2		SMALLINT ;
DEFINE _h_buzon_clave2		CHAR(10) ;
DEFINE _h_workflow			SMALLINT ;
DEFINE _h_internet			SMALLINT ;
DEFINE _h_business_obj		SMALLINT ;									  
DEFINE _registro            INTEGER  ;
DEFINE s_usuario 			CHAR(8)  ;
DEFINE s_status 			CHAR(1)  ;
DEFINE s_fecha_status 		date 	 ;
DEFINE s_chg_user  			char(8)  ;
DEFINE s_codigo_perfil 		CHAR(3)  ;
DEFINE s_tel_directo 		CHAR(10) ;
DEFINE s_tel_extenci 		CHAR(10) ;
DEFINE s_e_mail 			CHAR(30) ;
DEFINE s_clave_correo 		CHAR(30) ;
DEFINE s_cod_equipo 		CHAR(8)  ;
DEFINE s_buzon_print 		SMALLINT ;
DEFINE s_buzon_clave 		CHAR(10) ;
DEFINE s_buzon_print2 		SMALLINT ;
DEFINE s_buzon_clave2	 	CHAR(10) ;
DEFINE s_registro 			integer	 ;
DEFINE s_descripcion		CHAR(30) ;	   
DEFINE s_acd_agente	   		SMALLINT ;    
DEFINE s_acd_supervisor		SMALLINT ;
DEFINE _agt_error 			SMALLINT ;
DEFINE _agt_mensaje			CHAR(30) ;
  									  
BEGIN								  
									  
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;	  
END EXCEPTION						  
									  
SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET _agt_error 	  = 0;
LET _agt_mensaje  = 'Actualizacion de Agencia Exitosa ...';


SET DEBUG FILE TO "sp_seg004.trc"; 
TRACE ON;

LET _fecha_proceso = current;
LET _registro = 0;

  select cargo				,							   
		 codigo_compania	,							  
		 cia_depto			,							    
		 codigo_agencia		,							    
		 ubicacion			,							    
		 observ				,							     
		 equipo				,							  
		 tipo_equipo		,							   
		 llamada_celular	,							  
		 llamada_ldn		,							  
		 llamada_ldi		,							  
		 control_acceso		,							    
		 fgl_ver_web		,							  
		 crear_cliente		,							  
		 claimssearch		,							   
		 cot_web			,							  
		 transito			,							  
		 workflow			,							  
		 internet			,							  
		 business_obj		,							  
		 cod_perfil_wf_auto	,							  
		 emite_wf_auto		,							  
		 aprueba_wf_auto	,							  
		 codigo_perfil	 	,							 
		 tel_directo  	 	,							  
		 tel_extenci  	 	,							    
		 e_mail 		 	,							  
		 clave_correo 	 	,							  
		 cod_equipo	 	 	,							  
		 buzon_print  	 	,							  
		 buzon_clave  	 	,							  
		 buzon_print2 	 	,							  
		 buzon_clave2 	 	,							  
		 registro        	,
		 descripcion		,   
		 acd_agente			,    
		 acd_supervisor		 		 		 							  
    into _cargo				,							  
		 _codigo_compania	,							  
		 _cia_depto			,							  
		 _codigo_agencia	,							   
		 _ubicacion			,							  
		 _observ			,							  
		 _equipo			,							   
		 _tipo_equipo		,							  
		 _llamada_celular	,	
		 _llamada_ldn		,	
		 _llamada_ldi		,	
		 _control_acceso	,	
		 _fgl_ver_web		,	
		 _crear_cliente		,
		 _claimssearch		,
		 _cot_web			,	
		 _transito			,
		 _workflow			,
		 _internet			,
		 _business_obj		,
		 _cod_perfil_wf_auto,	
		 _emite_wf_auto		,
		 _aprueba_wf_auto	,
		 s_codigo_perfil	,
		 s_tel_directo 		,
		 s_tel_extenci		,
		 s_e_mail 			,
		 s_clave_correo 	,
		 s_cod_equipo 		,
		 s_buzon_print 		,
		 s_buzon_clave 		,
		 s_buzon_print2 	,
		 s_buzon_clave2		,
		 s_registro			,
		 s_descripcion		,   
		 s_acd_agente	   	,    
		 s_acd_supervisor		
    from cambio_user  
   where usuario = a_usuario
     and registro = a_registro
     and status = a_status; --"R";       -- Modificacion -> despues de haber actualizado, tiene que volver a imprimir el preliminar.


-- Backup de historico.
if a_status = "C" then

	select  usuario				   ,
			fecha_inicio		   ,
			dias_password		   ,
			hora_inicio			   ,
			hora_final			   ,
			ultimo_login		   ,
			no_login_permitido	   ,
			ult_cbio_password	   ,
			codigo_perfil		   ,
			descripcion			   ,
			password			   ,
			e_mail				   ,
			fecha_final			   ,
			status				   ,
			fecha_status		   ,
			fecha_cambio		   ,
			code_idioma			   ,
			codigo_menu			   ,
			nivel				   ,
			crear_cliente		   ,
			aut_endoso			   ,
			windows_user		   ,
			supervisor_ren		   ,
			fvac_out			   ,
			sac_user			   ,
			cia_depto			   ,
			tel_directo			   ,
			tel_extenci			   ,
			fgl_ver_web			   ,
			com_ejecutivo		   ,
			codigo_compania		   ,
			codigo_agencia		   ,
			ubicacion			   ,
			observ				   ,
			cod_carnet			   ,
			tipo_equipo			   ,
			llamada_celular		   ,
			llamada_ldn			   ,
			llamada_ldi			   ,
			control_acceso		   ,
			acd_agente			   ,
			acd_supervisor		   ,
			claimssearch		   ,
			transito			   ,
			cot_web				   ,
			clave_correo		   ,
			buzon_print			   ,
			cod_telefono		   ,
			cod_equipo			   ,
			buzon_clave			   ,
			cod_motivo			   ,
			cargo				   ,
			cod_perfil_wf_auto	   ,
			emite_wf_auto		   ,
			aprueba_wf_auto		   ,
			es_medico			   ,
			buzon_print2		   ,
			buzon_clave2		   ,
			workflow			   ,
			internet			   ,
			business_obj	
	  into	_h_usuario			   ,
			_h_fecha_inicio		   ,
			_h_dias_password	   ,	
			_h_hora_inicio		   ,
			_h_hora_final		   ,
			_h_ultimo_login		   ,
			_h_no_login_permitido  ,
			_h_ult_cbio_password   ,	
			_h_codigo_perfil	   ,	
			_h_descripcion		   ,
			_h_password			   ,
			_h_e_mail			   ,
			_h_fecha_final		   ,
			_h_status			   ,
			_h_fecha_status		   ,
			_h_fecha_cambio		   ,
			_h_code_idioma		   ,
			_h_codigo_menu		   ,
			_h_nivel			   ,	
			_h_crear_cliente	   ,	
			_h_aut_endoso		   ,
			_h_windows_user		   ,
			_h_supervisor_ren	   ,
			_h_fvac_out			   ,
			_h_sac_user			   ,
			_h_cia_depto		   ,	
			_h_tel_directo		   ,
			_h_tel_extenci		   ,
			_h_fgl_ver_web		   ,
			_h_com_ejecutivo	   ,	
			_h_codigo_compania	   ,
			_h_codigo_agencia	   ,
			_h_ubicacion		   ,	
			_h_observ			   ,
			_h_cod_carnet		   ,
			_h_tipo_equipo		   ,
			_h_llamada_celular	   ,
			_h_llamada_ldn		   ,
			_h_llamada_ldi		   ,
			_h_control_acceso	   ,
			_h_acd_agente		   ,
			_h_acd_supervisor	   ,
			_h_claimssearch		   ,
			_h_transito			   ,
			_h_cot_web			   ,
			_h_clave_correo		   ,
			_h_buzon_print		   ,
			_h_cod_telefono		   ,
			_h_cod_equipo		   ,
			_h_buzon_clave		   ,
			_h_cod_motivo		   ,
			_h_cargo			   ,	
			_h_cod_perfil_wf_auto  ,
			_h_emite_wf_auto	   ,	
			_h_aprueba_wf_auto	   ,
			_h_es_medico		   ,	
			_h_buzon_print2		   ,
			_h_buzon_clave2		   ,
			_h_workflow			   ,
			_h_internet			   ,
			_h_business_obj		
	  from segv05:insuser
	 WHERE usuario = a_usuario;

			if _codigo_agencia <> _h_codigo_agencia  then
			   -- Borrar el anterior y adicionar el nuevo
				CALL sp_seg006(a_usuario,"A",_fecha_proceso) RETURNING	_agt_error, _agt_mensaje;
				if _agt_error <> 0 then
				   RETURN _agt_error, _agt_mensaje WITH RESUME;
				end if
			end if

	insert into hisuser( 
			 usuario			   ,
			 fecha_inicio		   ,
			 dias_password	   ,
			 hora_inicio		   ,
			 hora_final		   ,
			 ultimo_login		   ,
			 no_login_permitido  ,
			 ult_cbio_password   ,
			 codigo_perfil	   ,
			 descripcion		   ,
			 password			   ,
			 e_mail			   ,
			 fecha_final		   ,
			 status			   ,
			 fecha_status		   ,
			 fecha_cambio		   ,
			 code_idioma		   ,
			 codigo_menu		   ,
			 nivel			   ,
			 crear_cliente	   ,
			 aut_endoso		   ,
			 windows_user		   ,
			 supervisor_ren	   ,
			 fvac_out			   ,
			 sac_user			   ,
			 cia_depto		   ,
			 tel_directo		   ,
			 tel_extenci		   ,
			 fgl_ver_web		   ,
			 com_ejecutivo	   ,
			 codigo_compania	   ,
			 codigo_agencia	   ,
			 ubicacion		   ,
			 observ			   ,
			 cod_carnet		   ,
			 tipo_equipo		   ,
			 llamada_celular	   ,
			 llamada_ldn		   ,
			 llamada_ldi		   ,
			 control_acceso	   ,
			 acd_agente		   ,
			 acd_supervisor	   ,
			 claimssearch		   ,
			 transito			   ,
			 cot_web			   ,
			 clave_correo		   ,
			 buzon_print		   ,
			 cod_telefono		   ,
			 cod_equipo		   ,
			 buzon_clave		   ,
			 cod_motivo		   ,
			 cargo			   ,
			 cod_perfil_wf_auto  ,
			 emite_wf_auto	   ,
			 aprueba_wf_auto	   ,
			 es_medico		   ,
			 buzon_print2		   ,
			 buzon_clave2		   ,
			 workflow			   ,
			 internet			   ,
			 business_obj		   ,
			 f_cambio              ,
			 u_cambio		   ,
			 r_cambio	
    )
	values(				 
			 _h_usuario			   ,
			 _h_fecha_inicio		   ,
			 _h_dias_password	   ,
			 _h_hora_inicio		   ,
			 _h_hora_final		   ,
			 _h_ultimo_login		   ,
			 _h_no_login_permitido  ,
			 _h_ult_cbio_password   ,
			 _h_codigo_perfil	   ,
			 _h_descripcion		   ,
			 _h_password			   ,
			 _h_e_mail			   ,
			 _h_fecha_final		   ,
			 _h_status			   ,
			 _h_fecha_status		   ,
			 _h_fecha_cambio		   ,
			 _h_code_idioma		   ,
			 _h_codigo_menu		   ,
			 _h_nivel			   ,
			 _h_crear_cliente	   ,
			 _h_aut_endoso		   ,
			 _h_windows_user		   ,
			 _h_supervisor_ren	   ,
			 _h_fvac_out			   ,
			 _h_sac_user			   ,
			 _h_cia_depto		   ,
			 _h_tel_directo		   ,
			 _h_tel_extenci		   ,
			 _h_fgl_ver_web		   ,
			 _h_com_ejecutivo	   ,
			 _h_codigo_compania	   ,
			 _h_codigo_agencia	   ,
			 _h_ubicacion		   ,
			 _h_observ			   ,
			 _h_cod_carnet		   ,
			 _h_tipo_equipo		   ,
			 _h_llamada_celular	   ,
			 _h_llamada_ldn		   ,
			 _h_llamada_ldi		   ,
			 _h_control_acceso	   ,
			 _h_acd_agente		   ,
			 _h_acd_supervisor	   ,
			 _h_claimssearch		   ,
			 _h_transito			   ,
			 _h_cot_web			   ,
			 _h_clave_correo		   ,
			 _h_buzon_print		   ,
			 _h_cod_telefono		   ,
			 _h_cod_equipo		   ,
			 _h_buzon_clave		   ,
			 _h_cod_motivo		   ,
			 _h_cargo			   ,
			 _h_cod_perfil_wf_auto  ,
			 _h_emite_wf_auto	   ,
			 _h_aprueba_wf_auto	   ,
			 _h_es_medico		   ,
			 _h_buzon_print2	   ,
			 _h_buzon_clave2		   ,
			 _h_workflow			   ,
			 _h_internet			   ,
			 _h_business_obj		   ,
			 _fecha_proceso			   ,
			 a_chg_user				   ,
			 a_registro
	);

	update segv05:insuser
	   set cargo			 = 	_cargo				,
		   codigo_compania	 =	_codigo_compania	,
		   cia_depto		 =	_cia_depto			,
		   codigo_agencia	 =	_codigo_agencia	    ,
		   ubicacion		 =	_ubicacion			,
		   observ			 =	_observ			    ,
		   tipo_equipo		 =	_tipo_equipo		,
		   llamada_celular	 =	_llamada_celular	,
		   llamada_ldn		 =	_llamada_ldn		,
		   llamada_ldi		 =	_llamada_ldi		,
		   control_acceso	 =	_control_acceso	    ,
		   fgl_ver_web		 =	_fgl_ver_web		,
		   crear_cliente	 =	_crear_cliente		,
		   claimssearch		 =	_claimssearch		,
		   cot_web			 =	_cot_web			,
		   transito			 =	_transito			,
		   workflow			 =	_workflow			,
		   internet			 =	_internet			,
		   business_obj		 =	_business_obj		,
		   cod_perfil_wf_auto=	_cod_perfil_wf_auto ,
		   emite_wf_auto	 =	_emite_wf_auto		,
		   aprueba_wf_auto	 =	_aprueba_wf_auto	,
		   status  		     = "A"                  ,
	       fecha_status      = _fecha_proceso       ,
		   codigo_perfil	 = s_codigo_perfil		,
		   tel_directo  	 = s_tel_directo 		,
		   tel_extenci  	 = s_tel_extenci		,
		   e_mail 		 	 = s_e_mail 			,
		   clave_correo 	 = s_clave_correo 		,
		   cod_equipo	 	 = s_cod_equipo 		,
		   buzon_print  	 = s_buzon_print 		,
		   buzon_clave  	 = s_buzon_clave 		,
		   buzon_print2 	 = s_buzon_print2 		,
		   buzon_clave2 	 = s_buzon_clave2		,
		   descripcion		 = s_descripcion		, 
		   acd_agente	   	 = s_acd_agente	   		, 
		   acd_supervisor	 = s_acd_supervisor		
	 where usuario = a_usuario;

	update segv05:cambio_user
	   set status  		     = "R",	     -- REALIZADO
	       fecha_status      = _fecha_proceso   
	 where usuario = a_usuario
	   and registro = a_registro
       and status = "C";  
Else
			

	update segv05:insuser
	   set cargo			 = 	_cargo				,
		   codigo_compania	 =	_codigo_compania	,
		   cia_depto		 =	_cia_depto			,
		   codigo_agencia	 =	_codigo_agencia	    ,
		   ubicacion		 =	_ubicacion			,
		   observ			 =	_observ			    ,
		   tipo_equipo		 =	_tipo_equipo		,
		   llamada_celular	 =	_llamada_celular	,
		   llamada_ldn		 =	_llamada_ldn		,
		   llamada_ldi		 =	_llamada_ldi		,
		   control_acceso	 =	_control_acceso	    ,
		   fgl_ver_web		 =	_fgl_ver_web		,
		   crear_cliente	 =	_crear_cliente		,
		   claimssearch		 =	_claimssearch		,
		   cot_web			 =	_cot_web			,
		   transito			 =	_transito			,
		   workflow			 =	_workflow			,
		   internet			 =	_internet			,
		   business_obj		 =	_business_obj		,
		   cod_perfil_wf_auto=	_cod_perfil_wf_auto ,
		   emite_wf_auto	 =	_emite_wf_auto		,
		   aprueba_wf_auto	 =	_aprueba_wf_auto	,
		   status  		     = "A"                  ,
	       fecha_status      = _fecha_proceso       ,
		   codigo_perfil	 = s_codigo_perfil		,
		   tel_directo  	 = s_tel_directo 		,
		   tel_extenci  	 = s_tel_extenci		,
		   e_mail 		 	 = s_e_mail 			,
		   clave_correo 	 = s_clave_correo 		,
		   cod_equipo	 	 = s_cod_equipo 		,
		   buzon_print  	 = s_buzon_print 		,
		   buzon_clave  	 = s_buzon_clave 		,
		   buzon_print2 	 = s_buzon_print2 		,
		   buzon_clave2 	 = s_buzon_clave2		,
		   descripcion		 = s_descripcion		, 
		   acd_agente	   	 = s_acd_agente	   		, 
		   acd_supervisor	 = s_acd_supervisor		
	 where usuario = a_usuario;

End If

RETURN r_error, r_descripcion  WITH RESUME;

END

end procedure;	

