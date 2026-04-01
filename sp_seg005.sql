-- Lista de Historico de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron
--Modificado : 14/05/2012 - Autor: Armando Moreno agergar campos que no se veian en el dw. sol por Marquelda
-- SIS v.2.0 - DEIVID, S.A.  
 drop procedure sp_seg005;

create procedure sp_seg005(a_user CHAR(8)) 
returning CHAR(8),CHAR(30),DATE,CHAR(100),CHAR(30),CHAR(50),CHAR(50),CHAR(50),CHAR(30),DATE,CHAR(8),INTEGER,SMALLINT,SMALLINT,SMALLINT,SMALLINT,SMALLINT,SMALLINT,SMALLINT,
          CHAR(10),CHAR(10),CHAR(10),integer,smallint,char(30),char(8),
          SMALLINT,
          SMALLINT,
          SMALLINT,
          CHAR(3) ,
		  char(50),
          SMALLINT,
          SMALLINT,
          SMALLINT,
          SMALLINT,
          SMALLINT,
          CHAR(3),
		  char(50),
          SMALLINT,
          char(10),
          CHAR(3),
		  char(50),
          SMALLINT,
          char(10);
																					 
define _usuario   		CHAR(8)  ;	
define _descripcion     CHAR(30) ;	
define _fecha_cambio    DATE	 ;	
define _fecha_inicio    DATE	 ;	
define _cia_depto   	CHAR(5)  ;	
define _codigo_agencia	CHAR(3)  ;	
define _ubicacion   	CHAR(50) ;	
define _observ   		CHAR(255);	
define _equipo   		SMALLINT ;	
define _tipo_equipo  	SMALLINT ;	
define _codigo_compania	CHAR(3)  ;
define _desc_depto    	CHAR(100);	
define _desc_agencia    CHAR(30) ;	
define _codigo_perfil  	CHAR(3)  ;
define _cargo           CHAR(50) ;
define _user_cambio		CHAR(8)  ;
define _nom_perfil      CHAR(30) ;
define _registro        INTEGER  ;
define _crear_cliente	SMALLINT ;
define _transito		SMALLINT ;
define _claimssearch	SMALLINT ;
define _cot_web			SMALLINT ;
define _workflow		SMALLINT ;
define _business_obj	SMALLINT ;
define _internet  		SMALLINT ;
define _tel_directo     char(10) ;
define _tel_extenci     char(10) ;
define _cod_telefono    char(10) ;
define _cod_carnet		integer  ;
define _control_acceso	smallint ;
define _e_mail          char(30) ;
define _cod_equipo      char(8)  ;
define _llamada_celular	SMALLINT ;
define _llamada_ldn		SMALLINT ;
define _llamada_ldi		SMALLINT ;
define _cod_perfil_wf_auto CHAR(3)  ;
define _emite_wf_auto	   SMALLINT ;
define _aprueba_wf_auto	   SMALLINT ;
define _supervisor_ren	   SMALLINT ;
define _es_medico		   SMALLINT ;
define _recl_firma_perdida SMALLINT ;
define _ubicacion_print1   CHAR(3)  ;
define _buzon_print		   SMALLINT ;
define _buzon_clave		   char(10)	;
define _ubicacion_print2   CHAR(3)  ;
define _buzon_print2	   SMALLINT ;
define _buzon_clave2	   char(10)	;
define _desc_perf_wf       char(50) ;
define _ubicacion1		   char(50) ;
define _ubicacion2		   char(50) ;
								   	
set isolation to dirty read;
let _codigo_compania = '001';
let _ubicacion_print1 = null;
let _ubicacion_print2 = null;
let _ubicacion1       = null;
let _ubicacion2       = null;

foreach
  select usuario,   
         descripcion,   
         fecha_inicio,   
         cia_depto,   
         codigo_agencia,   
         ubicacion,   
         observ,      
         codigo_perfil,
         cargo,
         f_cambio,
         u_cambio,
         r_cambio,
         crear_cliente,
         transito,
         claimssearch,
         cot_web,
         workflow,
         business_obj,
         internet,
         tel_directo,
         tel_extenci,
         cod_telefono,
		 cod_carnet,
		 control_acceso,
		 e_mail,
		 cod_equipo,
		 llamada_celular,
 		 llamada_ldn,
 		 llamada_ldi,
		 cod_perfil_wf_auto,
		 emite_wf_auto,
         aprueba_wf_auto,
		 supervisor_ren,
		 es_medico,
		 recl_firma_perdida,
		 buzon_print,
		 buzon_clave,
		 buzon_print2,
		 buzon_clave2,
		 ubicacion_print1,
		 ubicacion_print2
    into _usuario,   
         _descripcion,   
         _fecha_inicio,   
         _cia_depto,   
         _codigo_agencia,   
         _ubicacion,   
         _observ,    
         _codigo_perfil,
		 _cargo,
		 _fecha_cambio,
		 _user_cambio,
		 _registro,
		 _crear_cliente,
		 _transito,
		 _claimssearch,
		 _cot_web,
		 _workflow,
		 _business_obj,
		 _internet,
		 _tel_directo,
		 _tel_extenci,
		 _cod_telefono,
		 _cod_carnet,
		 _control_acceso,
		 _e_mail,
		 _cod_equipo,  
		 _llamada_celular,
 		 _llamada_ldn,
 		 _llamada_ldi,
		 _cod_perfil_wf_auto,
		 _emite_wf_auto,
         _aprueba_wf_auto,
		 _supervisor_ren,
		 _es_medico,
		 _recl_firma_perdida,
		 _buzon_print,
		 _buzon_clave,
		 _buzon_print2,
		 _buzon_clave2,
		 _ubicacion_print1,
		 _ubicacion_print2
    from hisuser  
   where usuario = a_user


{ foreach 
  select ubicacion_print1,
		 ubicacion_print2
	into _ubicacion_print1,
		 _ubicacion_print2
	from cambio_user
   where usuario      = _usuario
     and fecha_cambio = _fecha_cambio
  exit foreach;
 end foreach}


  select descripcion  
    into _desc_agencia
    from insagen  
   where codigo_agencia = _codigo_agencia;

  select nombre
    into _desc_depto  
    from insdepto   
   where cod_depto = _cia_depto;

  select descripcion
    into _nom_perfil          
    from inspefi
   where codigo_perfil = _codigo_perfil;
   
  select nombre
    into _desc_perf_wf
    from wf_perfil
   where cod_perfil = _cod_perfil_wf_auto;   
   
 if _ubicacion_print1 is null or _ubicacion_print1 = "" then
 else
  select ubicacion
    into _ubicacion1
    from insprin
   where code_printer = _ubicacion_print1;
 end if
   
 if _ubicacion_print2 is null or _ubicacion_print2 = "" then
 else
  select ubicacion
    into _ubicacion2
    from insprin
   where code_printer = _ubicacion_print2;
 end if

	return _user_cambio,   
		   _descripcion,   
		   _fecha_inicio,  
		   _desc_depto,
		   _desc_agencia,
		   _ubicacion,   
		   _observ,   
		   _cargo,   
		   _nom_perfil,
		   _fecha_cambio,
		   _usuario,
		   _registro,
		   _crear_cliente,
		   _transito,		
		   _claimssearch,	
		   _cot_web,			
		   _workflow,		
		   _business_obj,	
		   _internet,
		   _tel_directo,
		   _tel_extenci,
		   _cod_telefono,
		   _cod_carnet,
		   _control_acceso,
		   _e_mail,
		   _cod_equipo,
		   _llamada_celular,
		   _llamada_ldn,
		   _llamada_ldi,
		   _cod_perfil_wf_auto,
		   _desc_perf_wf,
		   _emite_wf_auto,
		   _aprueba_wf_auto,
		   _supervisor_ren,
		   _es_medico,
		   _recl_firma_perdida,
		   _ubicacion_print1,
		   _ubicacion1,
		   _buzon_print,
		   _buzon_clave,
		   _ubicacion_print2,
		   _ubicacion2,
		   _buzon_print2,
		   _buzon_clave2
		   with resume;

end foreach
end procedure

