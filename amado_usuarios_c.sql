-- Actualizando la firma en chqchmae

-- Creado    : 16/06/2006 - Autor: Amado Perez M.
-- Modificado: 16/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE amado_usuarios_c;

CREATE PROCEDURE amado_usuarios_c()
RETURNING char(8),							   
          char(30),							   
          char(3),							   
		  char(30),							   
		  char(1),							   
		  char(1),							   
		  char(1),							   
		  char(1),							   
		  char(1),							   
		  char(3),							   
		  char(30),							   
		  char(2),							   
		  char(30),							   
		  char(5),							   
		  varchar(100),						   
		  char(1),							   
		  date,								   
		  smallint,							   
		  datetime hour to fraction(5),		   
		  datetime hour to fraction(5),		   
		  date,								   
		  smallint,							   
		  date,								   
		  char(10),							   
		  char(30),							   
		  date,								   
		  date,								   
		  date,								   
		  char(2),							   
		  char(40),							   
		  char(2),							   
		  smallint,							   
		  smallint,							   
		  char(20),							   
		  smallint,							   
		  date,								   
		  date,								   
		  smallint,							   
		  char(10),							   
		  char(10),							   
		  char(1),							   
		  char(1),							   
		  char(3),							   
		  char(3),							   
		  char(50),							   
		  char(50),							   
		  integer,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  char(30),							   
		  smallint,							   
		  char(10),							   
		  char(8),							   
		  char(10),							   
		  char(3),							   
		  char(50),							   
		  char(3),							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  char(10),							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  smallint,							   
		  char(50),							   
		  char(3),							   
		  char(3),							   
		  char(3),							   
		  smallint,							   
		  char(3),		   				   
		  char(3),		   			   
		  char(3),		   			   
		  varchar(50,0),   		   
		  smallint,		   		   
		  char(1) ,		   				   
		  char(3) ,		   				   
		  char(25),		   		   
		  smallint,		   				   
		  smallint,		   					   
		  smallint,		   				   
		  integer ,		   		   
		  char(3),		   			   
		  char(3),		   			   
		  char(3),		   			   
		  char(5),		   			   
		  varchar(50,0),   			   
		  smallint,		   			   
		  smallint,		   				   
		  date,			   				   
		  char(10),		   
		  char(8),		   				   
		  date,			   				   
		  char(3),		   				   
		  date,			   				   
		  smallint,		   				   
		  char(3),		   				   
		  char(3),		   
		  char(10);


define _error               integer;
define _usuario             char(8);

define _descripcion			char(30);
define _codigo_perfil		char(3);
define _desc_perfil			char(30);
define _autoriza_total		char(1);
define _adicion				char(1);
define _modificar			char(1);
define _eliminar			char(1);
define _status				char(1);
define _aplicacion			char(3);
define _desc_aplicacion		char(30);
define _tipo_autorizacion	char(2);
define _desc_tipoautoriza	char(30);
define _cantidad      		smallint;
define _cia_depto           varchar(5);
define _depto_desc          varchar(100);
define _cia                 char(3);
define _suc                 char(3);
define _status_u            CHAR(1);

define _fecha_inicio         date;
define _dias_password        smallint;
define _hora_inicio          datetime hour to fraction(5);
define _hora_final           datetime hour to fraction(5);
define _ultimo_login         date;
define _no_login_permitido   smallint;
define _ult_cbio_password    date;
define _password             char(10);
define _e_mail               char(30);
define _fecha_final          date;
define _fecha_status         date;
define _fecha_cambio         date;
define _code_idioma          char(2);
define _codigo_menu          char(40);
define _nivel                char(2);
define _crear_cliente        smallint;
define _aut_endoso           smallint;
define _windows_user         char(20);
define _supervisor_ren       smallint;
define _fvac_out             date;
define _fvac_duein           date;
define _sac_user             smallint;
define _tel_directo          char(10);
define _tel_extenci          char(10);
define _fgl_ver_web          char(1);
define _com_ejecutivo        char(1);
define _codigo_compania      char(3);
define _codigo_agencia       char(3);
define _ubicacion            char(50);
define _observ               char(50);
define _cod_carnet           integer;
define _tipo_equipo          smallint;
define _llamada_celular      smallint;
define _llamada_ldn          smallint;
define _llamada_ldi          smallint;
define _control_acceso       smallint;
define _acd_agente           smallint;
define _acd_supervisor       smallint;
define _claimssearch         smallint;
define _transito             smallint;
define _cot_web              smallint;
define _clave_correo         char(30);
define _buzon_print          smallint;
define _cod_telefono         char(10);
define _cod_equipo           char(8);
define _buzon_clave          char(10);
define _cod_motivo           char(3);
define _cargo                char(50);
define _cod_perfil_wf_auto   char(3);
define _emite_wf_auto        smallint;
define _aprueba_wf_auto      smallint;
define _es_medico            smallint;
define _buzon_print2         smallint;
define _buzon_clave2         char(10);
define _workflow             smallint;
define _internet             smallint;
define _business_obj         smallint;
define _correo_evaluacion    smallint;
define _unidad_org           char(50);
define _cod_perfil_wf_emis   char(3)	;
define _ubicacion_print1     char(3)	;
define _ubicacion_print2     char(3)	;
define _emis_firma_aut       smallint;

define aj_cod_ajustador        char(3);
define aj_cod_compania         char(3);
define aj_cod_sucursal         char(3);
define aj_nombre               varchar(50,0);
define aj_activo               smallint;
define aj_tipo_ajustador       char(1) ;
define aj_usuario              char(8) ;
define aj_cod_aprobacion       char(3) ;
define aj_grupo                char(25);
define aj_analista_salud       smallint;
define aj_inserta_asignacion   smallint;
define aj_dist_equitativa      smallint;
define aj_orden                integer ;

define co_cod_cobrador         char(3);
define co_cod_compania         char(3);
define co_cod_sucursal         char(3);
define co_cod_libreta          char(5);
define co_nombre               varchar(50,0);
define co_activo               smallint	 ;
define co_tipo_cobrador        smallint	 ;
define co_fecha_aviso          date		 ;
define co_telefono             char(10)	 ;
define co_user_added           char(8)		 ;
define co_date_added           date		 ;
define co_usuario              char(10)	 ;
define co_cod_supervisor       char(3)		 ;
define co_fecha_ult_pro        date		 ;
define co_labora               smallint	 ;
define co_cod_banco            char(3)		 ;
define co_cod_chequera         char(3)		 ;
define co_cod_campana          char(10)	 ;

define _cant_aj				   smallint;
define _cant_co				   smallint;

--set debug file to "a_u_c.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 
  --	RETURN _error, "", "", "", "", "", "", "", "", "", "","", "", "", "", "";
END EXCEPTION     
      
foreach	
	SELECT a.usuario, a.codigo_perfil, a.descripcion, a.cia_depto, b.codigo_compania, b.codigo_agencia, a.status,
		   a.fecha_inicio      	 , 
		   a.dias_password     	 , 
		   a.hora_inicio       	 , 
		   a.hora_final        	 , 
		   a.ultimo_login      	 , 
		   a.no_login_permitido	 , 
		   a.ult_cbio_password 	 , 
		   a.password          	 , 
		   a.e_mail            	 , 
		   a.fecha_final       	 , 
		   a.fecha_status      	 , 
		   a.fecha_cambio      	 , 
		   a.code_idioma       	 , 
		   a.codigo_menu       	 , 
		   a.nivel             	 , 
		   a.crear_cliente     	 , 
		   a.aut_endoso        	 , 
		   a.windows_user      	 , 
		   a.supervisor_ren    	 , 
		   a.fvac_out          	 , 
		   a.fvac_duein        	 , 
		   a.sac_user          	 , 
		   a.tel_directo       	 , 
		   a.tel_extenci       	 , 
		   a.fgl_ver_web       	 , 
		   a.com_ejecutivo     	 , 
		   a.codigo_compania   	 , 
		   a.codigo_agencia    	 , 
		   a.ubicacion         	 , 
		   a.observ            	 , 
		   a.cod_carnet        	 , 
		   a.tipo_equipo       	 , 
		   a.llamada_celular   	 , 
		   a.llamada_ldn       	 , 
		   a.llamada_ldi       	 , 
		   a.control_acceso    	 , 
		   a.acd_agente        	 , 
		   a.acd_supervisor    	 , 
		   a.claimssearch      	 , 
		   a.transito          	 , 
		   a.cot_web           	 , 
		   a.clave_correo      	 , 
		   a.buzon_print       	 , 
		   a.cod_telefono      	 , 
		   a.cod_equipo        	 , 
		   a.buzon_clave       	 , 
		   a.cod_motivo        	 , 
		   a.cargo             	 , 
		   a.cod_perfil_wf_auto	 , 
		   a.emite_wf_auto     	 , 
		   a.aprueba_wf_auto   	 , 
		   a.es_medico         	 , 
		   a.buzon_print2      	 , 
		   a.buzon_clave2      	 , 
		   a.workflow          	 , 
		   a.internet          	 , 
		   a.business_obj      	 , 
		   a.correo_evaluacion 	 , 
		   a.unidad_org        	 , 
		   a.cod_perfil_wf_emis	 , 
		   a.ubicacion_print1  	 , 
		   a.ubicacion_print2  	 , 
		   a.emis_firma_aut    	  
	  INTO _usuario, _codigo_perfil, _descripcion, _cia_depto, _cia, _suc, _status_u,
		   _fecha_inicio      	 , 
		   _dias_password     	 , 
		   _hora_inicio       	 , 
		   _hora_final        	 , 
		   _ultimo_login      	 , 
		   _no_login_permitido	 , 
		   _ult_cbio_password 	 , 
		   _password          	 , 
		   _e_mail            	 , 
		   _fecha_final       	 , 
		   _fecha_status      	 , 
		   _fecha_cambio      	 , 
		   _code_idioma       	 , 
		   _codigo_menu       	 , 
		   _nivel             	 , 
		   _crear_cliente     	 , 
		   _aut_endoso        	 , 
		   _windows_user      	 , 
		   _supervisor_ren    	 , 
		   _fvac_out          	 , 
		   _fvac_duein        	 , 
		   _sac_user          	 , 
		   _tel_directo       	 , 
		   _tel_extenci       	 , 
		   _fgl_ver_web       	 , 
		   _com_ejecutivo     	 , 
		   _codigo_compania   	 , 
		   _codigo_agencia    	 , 
		   _ubicacion         	 , 
		   _observ            	 , 
		   _cod_carnet        	 , 
		   _tipo_equipo       	 , 
		   _llamada_celular   	 , 
		   _llamada_ldn       	 , 
		   _llamada_ldi       	 , 
		   _control_acceso    	 , 
		   _acd_agente        	 , 
		   _acd_supervisor    	 , 
		   _claimssearch      	 , 
		   _transito          	 , 
		   _cot_web           	 , 
		   _clave_correo      	 , 
		   _buzon_print       	 , 
		   _cod_telefono      	 , 
		   _cod_equipo        	 , 
		   _buzon_clave       	 , 
		   _cod_motivo        	 , 
		   _cargo             	 , 
		   _cod_perfil_wf_auto	 , 
		   _emite_wf_auto     	 , 
		   _aprueba_wf_auto   	 , 
		   _es_medico         	 , 
		   _buzon_print2      	 , 
		   _buzon_clave2      	 , 
		   _workflow          	 , 
		   _internet          	 , 
		   _business_obj      	 , 
		   _correo_evaluacion 	 , 
		   _unidad_org        	 , 
		   _cod_perfil_wf_emis	 , 
		   _ubicacion_print1  	 , 
		   _ubicacion_print2  	 , 
		   _emis_firma_aut    
	  FROM insuser a, insusco b
	 WHERE a.usuario = b.usuario
	   AND (b.status  = "A"
	   AND a.status = "A"
	    OR  (a.status  = "I" AND fvac_out is not null AND fvac_duein is not null))

    SELECT descripcion
	  INTO _desc_perfil
	  FROM inspefi
	 WHERE codigo_perfil = _codigo_perfil;

    SELECT nombre
	  INTO _depto_desc
	  FROM insdepto
	 WHERE cod_depto = trim(_cia_depto);

   { SELECT COUNT(*)
	  INTO _cant_aj
	  FROM recajust
	 WHERE usuario = _usuario
	   AND activo = 1;

    SELECT COUNT(*)
	  INTO _cant_co
	  FROM cobcobra
     WHERE usuario = _usuario
	   AND activo = 1;}

	let aj_cod_ajustador	  = null;
	let aj_cod_compania		  = null;
	let aj_cod_sucursal		  = null;
	let aj_nombre			  = null;
	let aj_activo			  = null;
	let aj_tipo_ajustador	  = null;
	let aj_cod_aprobacion	  = null;
	let aj_grupo			  = null;
	let aj_analista_salud	  = null;
	let aj_inserta_asignacion = null;
	let aj_dist_equitativa	  = null;
	let aj_orden			  = null;
	let co_cod_cobrador		  = null;
	let co_cod_compania		  = null;
	let co_cod_sucursal		  = null;
	let co_cod_libreta 		  = null;
	let co_nombre	  		  = null;
	let co_activo	  		  = null;
	let co_tipo_cobrador	  = null;
	let co_fecha_aviso  	  = null;
	let co_telefono	   		  = null;
	let co_user_added   	  = null;
	let co_date_added   	  = null;
	let co_cod_supervisor	  = null;
	let co_fecha_ult_pro	  = null;
	let co_labora			  = null;
	let co_cod_banco		  = null;
	let co_cod_chequera		  = null;
	let co_cod_campana		  = null;

	SELECT cod_ajustador,
		   cod_compania,
		   cod_sucursal,
		   nombre,
		   activo,
		   tipo_ajustador,
		   cod_aprobacion,
		   grupo,
		   analista_salud,
		   inserta_asignacion,
		   dist_equitativa,
		   orden
	  INTO aj_cod_ajustador,
		   aj_cod_compania,
		   aj_cod_sucursal,
		   aj_nombre,
		   aj_activo,
		   aj_tipo_ajustador,
		   aj_cod_aprobacion,
		   aj_grupo,
		   aj_analista_salud,
		   aj_inserta_asignacion,
		   aj_dist_equitativa,
		   aj_orden
	  FROM recajust
	 WHERE usuario = _usuario AND cod_compania = _cia AND aj_cod_sucursal = _suc
	   AND activo = 1;

   SELECT cod_cobrador,
		  cod_compania,
		  cod_sucursal,
		  cod_libreta ,
		  nombre	  ,
		  activo	  ,
		  tipo_cobrador,
		  fecha_aviso  ,
		  telefono	   ,
		  user_added   ,
		  date_added   ,
		  cod_supervisor,
		  fecha_ult_pro	,
		  labora		,
		  cod_banco		,
		  cod_chequera	,
		  cod_campana
	 INTO co_cod_cobrador,
		  co_cod_compania,
		  co_cod_sucursal,
		  co_cod_libreta ,
		  co_nombre	  ,
		  co_activo	  ,
		  co_tipo_cobrador,
		  co_fecha_aviso  ,
		  co_telefono	   ,
		  co_user_added   ,
		  co_date_added   ,
		  co_cod_supervisor,
		  co_fecha_ult_pro	,
		  co_labora		,
		  co_cod_banco		,
		  co_cod_chequera	,
		  co_cod_campana
	 FROM cobcobra
    WHERE usuario = _usuario AND cod_compania = _cia AND aj_cod_sucursal = _suc
	 AND activo = 1;
   


   FOREACH
	SELECT autoriza_total,
		   adicion,
		   modificar,
		   eliminar,
		   status,
		   aplicacion
	  INTO _autoriza_total,
		   _adicion,
		   _modificar,
		   _eliminar,
		   _status,
		   _aplicacion
	  FROM inspapl
	 WHERE codigo_perfil = _codigo_perfil
	   AND status = 'A'

    SELECT descripcion
	  INTO _desc_aplicacion
	  FROM insapli
	 WHERE aplicacion = _aplicacion;

    SELECT count(*) INTO _cantidad
	  FROM insauca
	 WHERE usuario = _usuario
	   AND aplicacion = _aplicacion
	   AND status = 'A'
	   AND codigo_compania = _cia
	   AND codigo_agencia  = _suc;

    IF _cantidad = 0 THEN
		   RETURN _usuario,
				  _descripcion,
		          _codigo_perfil,
				  _desc_perfil,
				  _autoriza_total,
				  _adicion,
				  _modificar,
				  _eliminar,
				  _status,
				  _aplicacion,
				  _desc_aplicacion,
				  null,
				  null,
				  _cia_depto,
				  trim(_depto_desc),
				  _status_u,
				  _fecha_inicio      	 ,
				  _dias_password     	 ,
				  _hora_inicio       	 ,
				  _hora_final        	 ,
				  _ultimo_login      	 ,
				  _no_login_permitido	 ,
				  _ult_cbio_password 	 ,
				  _password          	 ,
				  _e_mail            	 ,
				  _fecha_final       	 ,
				  _fecha_status      	 ,
				  _fecha_cambio      	 ,
				  _code_idioma       	 ,
				  _codigo_menu       	 ,
				  _nivel             	 ,
				  _crear_cliente     	 ,
				  _aut_endoso        	 ,
				  _windows_user      	 ,
				  _supervisor_ren    	 ,
				  _fvac_out          	 ,
				  _fvac_duein        	 ,
				  _sac_user          	 ,
				  _tel_directo       	 ,
				  _tel_extenci       	 ,
				  _fgl_ver_web       	 ,
				  _com_ejecutivo     	 ,
				  _codigo_compania   	 ,
				  _codigo_agencia    	 ,
				  _ubicacion         	 ,
				  _observ            	 ,
				  _cod_carnet        	 ,
				  _tipo_equipo       	 ,
				  _llamada_celular   	 ,
				  _llamada_ldn       	 ,
				  _llamada_ldi       	 ,
				  _control_acceso    	 ,
				  _acd_agente        	 ,
				  _acd_supervisor    	 ,
				  _claimssearch      	 ,
				  _transito          	 ,
				  _cot_web           	 ,
				  _clave_correo      	 ,
				  _buzon_print       	 ,
				  _cod_telefono      	 ,
				  _cod_equipo        	 ,
				  _buzon_clave       	 ,
				  _cod_motivo        	 ,
				  _cargo             	 ,
				  _cod_perfil_wf_auto	 ,
				  _emite_wf_auto     	 ,
				  _aprueba_wf_auto   	 ,
				  _es_medico         	 ,
				  _buzon_print2      	 ,
				  _buzon_clave2      	 ,
				  _workflow          	 ,
				  _internet          	 ,
				  _business_obj      	 ,
				  _correo_evaluacion 	 ,
				  _unidad_org        	 ,
				  _cod_perfil_wf_emis	 ,
				  _ubicacion_print1  	 ,
				  _ubicacion_print2  	 ,
				  _emis_firma_aut    	 ,
				  aj_cod_ajustador,
				  aj_cod_compania,
				  aj_cod_sucursal,
				  aj_nombre,
				  aj_activo,
				  aj_tipo_ajustador,
				  aj_cod_aprobacion,
				  aj_grupo,
				  aj_analista_salud,
				  aj_inserta_asignacion,
				  aj_dist_equitativa,
				  aj_orden,
				  co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
				  with resume;

   {	   IF _cant_aj > 0 THEN
		FOREACH
			SELECT cod_ajustador,
				   cod_compania,
				   cod_sucursal,
				   nombre,
				   activo,
				   tipo_ajustador,
				   cod_aprobacion,
				   grupo,
				   analista_salud,
				   inserta_asignacion,
				   dist_equitativa,
				   orden
			  INTO aj_cod_ajustador,
				   aj_cod_compania,
				   aj_cod_sucursal,
				   aj_nombre,
				   aj_activo,
				   aj_tipo_ajustador,
				   aj_cod_aprobacion,
				   aj_grupo,
				   aj_analista_salud,
				   aj_inserta_asignacion,
				   aj_dist_equitativa,
				   aj_orden
			  FROM recajust
			 WHERE usuario = _usuario
			   AND activo = 1

		   RETURN _usuario,
				  _descripcion,
		          _codigo_perfil,
				  _desc_perfil,
				  _autoriza_total,
				  _adicion,
				  _modificar,
				  _eliminar,
				  _status,
				  _aplicacion,
				  _desc_aplicacion,
				  null,
				  null,
				  _cia_depto,
				  trim(_depto_desc),
				  _status_u,
				  _fecha_inicio      	 ,
				  _dias_password     	 ,
				  _hora_inicio       	 ,
				  _hora_final        	 ,
				  _ultimo_login      	 ,
				  _no_login_permitido	 ,
				  _ult_cbio_password 	 ,
				  _password          	 ,
				  _e_mail            	 ,
				  _fecha_final       	 ,
				  _fecha_status      	 ,
				  _fecha_cambio      	 ,
				  _code_idioma       	 ,
				  _codigo_menu       	 ,
				  _nivel             	 ,
				  _crear_cliente     	 ,
				  _aut_endoso        	 ,
				  _windows_user      	 ,
				  _supervisor_ren    	 ,
				  _fvac_out          	 ,
				  _fvac_duein        	 ,
				  _sac_user          	 ,
				  _tel_directo       	 ,
				  _tel_extenci       	 ,
				  _fgl_ver_web       	 ,
				  _com_ejecutivo     	 ,
				  _codigo_compania   	 ,
				  _codigo_agencia    	 ,
				  _ubicacion         	 ,
				  _observ            	 ,
				  _cod_carnet        	 ,
				  _tipo_equipo       	 ,
				  _llamada_celular   	 ,
				  _llamada_ldn       	 ,
				  _llamada_ldi       	 ,
				  _control_acceso    	 ,
				  _acd_agente        	 ,
				  _acd_supervisor    	 ,
				  _claimssearch      	 ,
				  _transito          	 ,
				  _cot_web           	 ,
				  _clave_correo      	 ,
				  _buzon_print       	 ,
				  _cod_telefono      	 ,
				  _cod_equipo        	 ,
				  _buzon_clave       	 ,
				  _cod_motivo        	 ,
				  _cargo             	 ,
				  _cod_perfil_wf_auto	 ,
				  _emite_wf_auto     	 ,
				  _aprueba_wf_auto   	 ,
				  _es_medico         	 ,
				  _buzon_print2      	 ,
				  _buzon_clave2      	 ,
				  _workflow          	 ,
				  _internet          	 ,
				  _business_obj      	 ,
				  _correo_evaluacion 	 ,
				  _unidad_org        	 ,
				  _cod_perfil_wf_emis	 ,
				  _ubicacion_print1  	 ,
				  _ubicacion_print2  	 ,
				  _emis_firma_aut    	 ,
				  aj_cod_ajustador,
				  aj_cod_compania,
				  aj_cod_sucursal,
				  aj_nombre,
				  aj_activo,
				  aj_tipo_ajustador,
				  aj_cod_aprobacion,
				  aj_grupo,
				  aj_analista_salud,
				  aj_inserta_asignacion,
				  aj_dist_equitativa,
				  aj_orden,
				  co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
				  with resume;
	   		END FOREACH
		END IF
	   IF _cant_co > 0 THEN
		FOREACH
		   SELECT cod_cobrador,
				  cod_compania,
				  cod_sucursal,
				  cod_libreta ,
				  nombre	  ,
				  activo	  ,
				  tipo_cobrador,
				  fecha_aviso  ,
				  telefono	   ,
				  user_added   ,
				  date_added   ,
				  cod_supervisor,
				  fecha_ult_pro	,
				  labora		,
				  cod_banco		,
				  cod_chequera	,
				  cod_campana
			 INTO co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
			FROM  cobcobra
		   WHERE  usuario = _usuario
			 AND activo = 1

		   RETURN _usuario,
				  _descripcion,
		          _codigo_perfil,
				  _desc_perfil,
				  _autoriza_total,
				  _adicion,
				  _modificar,
				  _eliminar,
				  _status,
				  _aplicacion,
				  _desc_aplicacion,
				  null,
				  null,
				  _cia_depto,
				  trim(_depto_desc),
				  _status_u,
				  _fecha_inicio      	 ,
				  _dias_password     	 ,
				  _hora_inicio       	 ,}
		{		  _hora_final        	 ,
				  _ultimo_login      	 ,
				  _no_login_permitido	 ,
				  _ult_cbio_password 	 ,
				  _password          	 ,
				  _e_mail            	 ,
				  _fecha_final       	 ,
				  _fecha_status      	 ,
				  _fecha_cambio      	 ,
				  _code_idioma       	 ,
				  _codigo_menu       	 ,
				  _nivel             	 ,
				  _crear_cliente     	 ,
				  _aut_endoso        	 ,
				  _windows_user      	 ,
				  _supervisor_ren    	 ,
				  _fvac_out          	 ,
				  _fvac_duein        	 ,
				  _sac_user          	 ,
				  _tel_directo       	 ,
				  _tel_extenci       	 ,
				  _fgl_ver_web       	 ,
				  _com_ejecutivo     	 ,
				  _codigo_compania   	 ,
				  _codigo_agencia    	 ,
				  _ubicacion         	 ,
				  _observ            	 ,
				  _cod_carnet        	 ,
				  _tipo_equipo       	 ,
				  _llamada_celular   	 ,
				  _llamada_ldn       	 ,
				  _llamada_ldi       	 ,
				  _control_acceso    	 ,
				  _acd_agente        	 ,
				  _acd_supervisor    	 ,
				  _claimssearch      	 ,
				  _transito          	 ,
				  _cot_web           	 ,
				  _clave_correo      	 ,
				  _buzon_print       	 ,
				  _cod_telefono      	 ,
				  _cod_equipo        	 ,
				  _buzon_clave       	 ,
				  _cod_motivo        	 ,
				  _cargo             	 ,
				  _cod_perfil_wf_auto	 ,
				  _emite_wf_auto     	 ,
				  _aprueba_wf_auto   	 ,
				  _es_medico         	 ,
				  _buzon_print2      	 ,
				  _buzon_clave2      	 ,
				  _workflow          	 ,
				  _internet          	 ,
				  _business_obj      	 ,
				  _correo_evaluacion 	 ,
				  _unidad_org        	 ,
				  _cod_perfil_wf_emis	 ,
				  _ubicacion_print1  	 ,
				  _ubicacion_print2  	 ,
				  _emis_firma_aut    	 ,
				  aj_cod_ajustador,
				  aj_cod_compania,
				  aj_cod_sucursal,
				  aj_nombre,
				  aj_activo,
				  aj_tipo_ajustador,
				  aj_cod_aprobacion,
				  aj_grupo,
				  aj_analista_salud,
				  aj_inserta_asignacion,
				  aj_dist_equitativa,
				  aj_orden,
				  co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
				  with resume;
	   		END FOREACH
		END IF}
	ELSE
	   foreach
		   SELECT tipo_autorizacion
		     INTO _tipo_autorizacion
			 FROM insauca
			WHERE usuario = _usuario
			  AND aplicacion = _aplicacion
	          AND status = 'A'
			  AND codigo_compania = _cia
			  AND codigo_agencia  = _suc

       SELECT descripcion
	     INTO _desc_tipoautoriza
		 FROM insauto
		WHERE tipo_autoriza = _tipo_autorizacion
		  AND aplicacion = _aplicacion;

	   RETURN _usuario,
			  _descripcion,
	          _codigo_perfil,
			  _desc_perfil,
			  _autoriza_total,
			  _adicion,
			  _modificar,
			  _eliminar,
			  _status,
			  _aplicacion,
			  _desc_aplicacion,
			  _tipo_autorizacion,
			  _desc_tipoautoriza,
			  _cia_depto,
			  trim(_depto_desc),
			  _status_u,
			  _fecha_inicio      	 ,
			  _dias_password     	 ,
			  _hora_inicio       	 ,
			  _hora_final        	 ,
			  _ultimo_login      	 ,
			  _no_login_permitido	 ,
			  _ult_cbio_password 	 ,
			  _password          	 ,
			  _e_mail            	 ,
			  _fecha_final       	 ,
			  _fecha_status      	 ,
			  _fecha_cambio      	 ,
			  _code_idioma       	 ,
			  _codigo_menu       	 ,
			  _nivel             	 ,
			  _crear_cliente     	 ,
			  _aut_endoso        	 ,
			  _windows_user      	 ,
			  _supervisor_ren    	 ,
			  _fvac_out          	 ,
			  _fvac_duein        	 ,
			  _sac_user          	 ,
			  _tel_directo       	 ,
			  _tel_extenci       	 ,
			  _fgl_ver_web       	 ,
			  _com_ejecutivo     	 ,
			  _codigo_compania   	 ,
			  _codigo_agencia    	 ,
			  _ubicacion         	 ,
			  _observ            	 ,
			  _cod_carnet        	 ,
			  _tipo_equipo       	 ,
			  _llamada_celular   	 ,
			  _llamada_ldn       	 ,
			  _llamada_ldi       	 ,
			  _control_acceso    	 ,
			  _acd_agente        	 ,
			  _acd_supervisor    	 ,
			  _claimssearch      	 ,
			  _transito          	 ,
			  _cot_web           	 ,
			  _clave_correo      	 ,
			  _buzon_print       	 ,
			  _cod_telefono      	 ,
			  _cod_equipo        	 ,
			  _buzon_clave       	 ,
			  _cod_motivo        	 ,
			  _cargo             	 ,
			  _cod_perfil_wf_auto	 ,
			  _emite_wf_auto     	 ,
			  _aprueba_wf_auto   	 ,
			  _es_medico         	 ,
			  _buzon_print2      	 ,
			  _buzon_clave2      	 ,
			  _workflow          	 ,
			  _internet          	 ,
			  _business_obj      	 ,
			  _correo_evaluacion 	 ,
			  _unidad_org        	 ,
			  _cod_perfil_wf_emis	 ,
			  _ubicacion_print1  	 ,
			  _ubicacion_print2  	 ,
			  _emis_firma_aut    	 ,
			  aj_cod_ajustador,
			  aj_cod_compania,
			  aj_cod_sucursal,
			  aj_nombre,
			  aj_activo,
			  aj_tipo_ajustador,
			  aj_cod_aprobacion,
			  aj_grupo,
			  aj_analista_salud,
			  aj_inserta_asignacion,
			  aj_dist_equitativa,
			  aj_orden,
			  co_cod_cobrador,
			  co_cod_compania,
			  co_cod_sucursal,
			  co_cod_libreta ,
			  co_nombre	  ,
			  co_activo	  ,
			  co_tipo_cobrador,
			  co_fecha_aviso  ,
			  co_telefono	   ,
			  co_user_added   ,
			  co_date_added   ,
			  co_cod_supervisor,
			  co_fecha_ult_pro	,
			  co_labora		,
			  co_cod_banco		,
			  co_cod_chequera	,
			  co_cod_campana
			  with resume;

	   {IF _cant_aj > 0 THEN
		FOREACH
			SELECT cod_ajustador,
				   cod_compania,
				   cod_sucursal,
				   nombre,
				   activo,
				   tipo_ajustador,
				   cod_aprobacion,
				   grupo,
				   analista_salud,
				   inserta_asignacion,
				   dist_equitativa,
				   orden
			  INTO aj_cod_ajustador,
				   aj_cod_compania,
				   aj_cod_sucursal,
				   aj_nombre,
				   aj_activo,
				   aj_tipo_ajustador,
				   aj_cod_aprobacion,
				   aj_grupo,
				   aj_analista_salud,
				   aj_inserta_asignacion,
				   aj_dist_equitativa,
				   aj_orden
			  FROM recajust
			 WHERE usuario = _usuario
			   AND activo = 1

		   RETURN _usuario,
				  _descripcion,
		          _codigo_perfil,
				  _desc_perfil,
				  _autoriza_total,
				  _adicion,
				  _modificar,
				  _eliminar,
				  _status,
				  _aplicacion,
				  _desc_aplicacion,
				  null,
				  null,
				  _cia_depto,
				  trim(_depto_desc),
				  _status_u,
				  _fecha_inicio      	 ,
				  _dias_password     	 ,
				  _hora_inicio       	 ,
				  _hora_final        	 ,
				  _ultimo_login      	 ,
				  _no_login_permitido	 ,
				  _ult_cbio_password 	 ,
				  _password          	 ,
				  _e_mail            	 ,
				  _fecha_final       	 ,
				  _fecha_status      	 ,
				  _fecha_cambio      	 ,
				  _code_idioma       	 ,
				  _codigo_menu       	 ,
				  _nivel             	 ,
				  _crear_cliente     	 ,
				  _aut_endoso        	 ,
				  _windows_user      	 ,
				  _supervisor_ren    	 ,
				  _fvac_out          	 ,
				  _fvac_duein        	 ,
				  _sac_user          	 ,
				  _tel_directo       	 ,
				  _tel_extenci       	 ,
				  _fgl_ver_web       	 ,
				  _com_ejecutivo     	 ,
				  _codigo_compania   	 ,
				  _codigo_agencia    	 ,
				  _ubicacion         	 ,
				  _observ            	 ,
				  _cod_carnet        	 ,
				  _tipo_equipo       	 ,
				  _llamada_celular   	 ,
				  _llamada_ldn       	 ,
				  _llamada_ldi       	 ,
				  _control_acceso    	 ,
				  _acd_agente        	 ,
				  _acd_supervisor    	 ,
				  _claimssearch      	 ,
				  _transito          	 ,
				  _cot_web           	 ,
				  _clave_correo      	 ,
				  _buzon_print       	 ,
				  _cod_telefono      	 ,
				  _cod_equipo        	 ,
				  _buzon_clave       	 ,
				  _cod_motivo        	 ,
				  _cargo             	 ,
				  _cod_perfil_wf_auto	 ,
				  _emite_wf_auto     	 ,
				  _aprueba_wf_auto   	 ,
				  _es_medico         	 ,
				  _buzon_print2      	 ,
				  _buzon_clave2      	 ,
				  _workflow          	 ,
				  _internet          	 ,
				  _business_obj      	 ,
				  _correo_evaluacion 	 ,
				  _unidad_org        	 ,
				  _cod_perfil_wf_emis	 ,
				  _ubicacion_print1  	 ,
				  _ubicacion_print2  	 ,
				  _emis_firma_aut    	 ,
				  aj_cod_ajustador,
				  aj_cod_compania,
				  aj_cod_sucursal,
				  aj_nombre,
				  aj_activo,
				  aj_tipo_ajustador,
				  aj_cod_aprobacion,
				  aj_grupo,
				  aj_analista_salud,
				  aj_inserta_asignacion,
				  aj_dist_equitativa,
				  aj_orden,
				  co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
				  with resume;
	   		END FOREACH
		END IF
	   IF _cant_co > 0 THEN
		FOREACH
		   SELECT cod_cobrador,
				  cod_compania,
				  cod_sucursal,
				  cod_libreta ,
				  nombre	  ,
				  activo	  ,
				  tipo_cobrador,
				  fecha_aviso  ,
				  telefono	   ,
				  user_added   ,
				  date_added   ,
				  cod_supervisor,
				  fecha_ult_pro	,
				  labora		,
				  cod_banco		,
				  cod_chequera	,
				  cod_campana
			 INTO co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
			FROM  cobcobra
		   WHERE  usuario = _usuario
			 AND activo = 1

		   RETURN _usuario,
				  _descripcion,
		          _codigo_perfil,
				  _desc_perfil,
				  _autoriza_total,
				  _adicion,
				  _modificar,
				  _eliminar,
				  _status,
				  _aplicacion,
				  _desc_aplicacion,
				  null,
				  null,
				  _cia_depto,
				  trim(_depto_desc),
				  _status_u,
				  _fecha_inicio      	 ,
				  _dias_password     	 ,
				  _hora_inicio       	 ,}
				  {_hora_final        	 ,
				  _ultimo_login      	 ,
				  _no_login_permitido	 ,
				  _ult_cbio_password 	 ,
				  _password          	 ,
				  _e_mail            	 ,
				  _fecha_final       	 ,
				  _fecha_status      	 ,
				  _fecha_cambio      	 ,
				  _code_idioma       	 ,
				  _codigo_menu       	 ,
				  _nivel             	 ,
				  _crear_cliente     	 ,
				  _aut_endoso        	 ,
				  _windows_user      	 ,
				  _supervisor_ren    	 ,
				  _fvac_out          	 ,
				  _fvac_duein        	 ,
				  _sac_user          	 ,
				  _tel_directo       	 ,
				  _tel_extenci       	 ,
				  _fgl_ver_web       	 ,
				  _com_ejecutivo     	 ,
				  _codigo_compania   	 ,
				  _codigo_agencia    	 ,
				  _ubicacion         	 ,
				  _observ            	 ,
				  _cod_carnet        	 ,
				  _tipo_equipo       	 ,
				  _llamada_celular   	 ,
				  _llamada_ldn       	 ,
				  _llamada_ldi       	 ,
				  _control_acceso    	 ,
				  _acd_agente        	 ,
				  _acd_supervisor    	 ,
				  _claimssearch      	 ,
				  _transito          	 ,
				  _cot_web           	 ,
				  _clave_correo      	 ,
				  _buzon_print       	 ,
				  _cod_telefono      	 ,
				  _cod_equipo        	 ,
				  _buzon_clave       	 ,
				  _cod_motivo        	 ,
				  _cargo             	 ,
				  _cod_perfil_wf_auto	 ,
				  _emite_wf_auto     	 ,
				  _aprueba_wf_auto   	 ,
				  _es_medico         	 ,
				  _buzon_print2      	 ,
				  _buzon_clave2      	 ,
				  _workflow          	 ,
				  _internet          	 ,
				  _business_obj      	 ,
				  _correo_evaluacion 	 ,
				  _unidad_org        	 ,
				  _cod_perfil_wf_emis	 ,
				  _ubicacion_print1  	 ,
				  _ubicacion_print2  	 ,
				  _emis_firma_aut    	 ,
				  aj_cod_ajustador,
				  aj_cod_compania,
				  aj_cod_sucursal,
				  aj_nombre,
				  aj_activo,
				  aj_tipo_ajustador,
				  aj_cod_aprobacion,
				  aj_grupo,
				  aj_analista_salud,
				  aj_inserta_asignacion,
				  aj_dist_equitativa,
				  aj_orden,
				  co_cod_cobrador,
				  co_cod_compania,
				  co_cod_sucursal,
				  co_cod_libreta ,
				  co_nombre	  ,
				  co_activo	  ,
				  co_tipo_cobrador,
				  co_fecha_aviso  ,
				  co_telefono	   ,
				  co_user_added   ,
				  co_date_added   ,
				  co_cod_supervisor,
				  co_fecha_ult_pro	,
				  co_labora		,
				  co_cod_banco		,
				  co_cod_chequera	,
				  co_cod_campana
				  with resume;
	   		END FOREACH
		END IF }
	   end foreach

	 END IF
	END FOREACH

   END FOREACH
    
END

END PROCEDURE;