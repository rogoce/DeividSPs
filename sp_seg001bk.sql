-- Preliminar info de modificacion de Perfil de usuario 

-- Creado     : 18/10/2010 - Autor: Armando Moreno M.
-- Modificado : 18/10/2010 - Por  : Armando Moreno M.
-- Modificado : 17/11/2010 - Por  : Henry Giron

DROP PROCEDURE sp_seg001b;

create procedure "informix".sp_seg001b(a_user char(8),a_registro integer)
returning CHAR(8),   --_usuario,
		  CHAR(30),  --_descripcion,
	      CHAR(30),	 --_e_mail,
		  CHAR(20),	 --_windows_user,
	   	  DATE,	     --_fvac_out,
		  DATE,      --_fvac_duein,
		  CHAR(30),  --_clave_correo,   
		  char(10),	 --_clave_tel,											   
		  char(10),	 --_tel_directo,												   
		  char(10),	 --_tel_extenci,											   
		  char(8),	 --_cod_equipo,											   
		  integer,	 --_buzon_print, 											    
		  char(10),	 --_buzon_clave,
		  integer,	 --_cod_carnet,
		  integer,	 --_buzon_print2, 											    
		  char(10),	 --_buzon_clave2,
		  char(10),	 --_n_acceso,	
		  char(50),	 --_n_cargo,											   
		  char(100), --_depto_name,												   
		  char(30),	 --_n_agencia					 
		  CHAR(50),  --_ubicacion
		  CHAR(30),	 -- nuevo_perfil
		  CHAR(100),  --nombre y _ubicacion_print1
		  CHAR(100);  --nombre y _ubicacion_print2


DEFINE _usuario       char(8);  -- 1
DEFINE _descripcion   char(30); -- 2
DEFINE _e_mail        char(30); -- 3 
DEFINE _status        char(1);  -- 4
DEFINE _windows_user  char(20); -- 5
DEFINE _fvac_out      date;	    -- 6
DEFINE _fvac_duein    date;	    -- 7
DEFINE _codigo_perfil char(3);	-- 8
DEFINE _nom_perfile   char(30);	-- 9 
DEFINE _cia_depto     char(5);
DEFINE _tel_directo	  char(10);
DEFINE _ver_web 	  char(1);
DEFINE _depto_name    char(100);
DEFINE _com_ejec      char(1);
DEFINE _cod_motivo    char(3);
DEFINE _clave_correo  char(30);
DEFINE _clave_tel     char(10);
DEFINE _tel_extenci	  char(10);
DEFINE _cod_equipo 	  char(8);
DEFINE _buzon_print   integer;
DEFINE _buzon_clave	  char(10);
DEFINE _cod_carnet	  integer;
DEFINE _control_acceso	integer;
DEFINE _buzon_print2    integer;
DEFINE _buzon_clave2    char(10);
DEFINE _codigo_agencia  char(3);
DEFINE _n_acceso		char(10);
DEFINE _n_cargo         char(50);
DEFINE _n_agencia       char(30);
DEFINE _ubicacion		CHAR(50) ;	
DEFINE _fecha_status    date;
DEFINE _cargo			CHAR(50) ;										
DEFINE _nom_perfile2    char(30); 
DEFINE _codigo_perfil2  char(3);
	  
DEFINE _ubicacion_print1 CHAR(3);		  
DEFINE _ubicacion_print2 CHAR(3);		  
DEFINE _nom_ubicacion_print1 CHAR(50);		  
DEFINE _nom_ubicacion_print2 CHAR(50);		  
DEFINE _eqp_print1           CHAR(30);		  
DEFINE _eqp_print2           CHAR(30);		
DEFINE _nom_print1           CHAR(100);		  
DEFINE _nom_print2           CHAR(100);	
DEFINE _registro			integer;


let    _nom_perfile   = "";
let    _nom_perfile2  = "";
let    _n_agencia     = "";
let    _n_cargo       = "";
let    _n_acceso      = "";
let    _ubicacion     = "";
let    _ubicacion_print1 = "";
let    _ubicacion_print2 = "";
let    _nom_ubicacion_print1 = "";
let    _nom_ubicacion_print2 = "";
let    _eqp_print1 = "";
let    _eqp_print2 = "";
let    _nom_print1 = "";
let    _nom_print2 = "";

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud

	
	 select max(registro)
	   into _registro
	   from cambio_user
	  where usuario = a_user;	

	 select usuario,
	        descripcion,
	        e_mail,
	        status,
		    windows_user,
			fvac_out,
			fecha_inicio, --fvac_duein,
			codigo_perfil,
			cia_depto,
			tel_directo,
			tel_extenci,
			fgl_ver_web,
			com_ejecutivo,
			clave_correo,
			cod_telefono,
			tel_directo,
			tel_extenci,
			cod_equipo,
			buzon_print,
			buzon_clave,
			cod_carnet,
			buzon_print2,
			buzon_clave2,
			control_acceso,
			codigo_agencia,
			cargo,
			fecha_status
	   into _usuario,
	        _descripcion,
		    _e_mail,
		    _status,
		    _windows_user,
			_fvac_out,
			_fvac_duein,
			_codigo_perfil,
			_cia_depto,
			_tel_directo,
			_tel_extenci,
			_ver_web,
       		_com_ejec,
			_clave_correo,
			_clave_tel,
			_tel_directo,
			_tel_extenci,
			_cod_equipo,
			_buzon_print,
			_buzon_clave,
			_cod_carnet,
			_buzon_print2,
			_buzon_clave2,
			_control_acceso,
			_codigo_agencia,
			_n_cargo,
			_fecha_status
	   from insuser
	  where usuario = a_user;     

	select fecha_status
	  into _fecha_status
	  from cambio_user
	 where usuario = a_user
	   and registro = a_registro;

	select  nombre
	  into  _depto_name
	  from  insdepto 
	  where cod_depto = _cia_depto;

	select  descripcion
	  into  _n_agencia
	  from  insagen
	  where codigo_agencia = _codigo_agencia;

		LET	_n_acceso = "Grupo "||_control_acceso;

	select descripcion
	  into _nom_perfile          
	  from inspefi
	 where codigo_perfil = _codigo_perfil;        	

	select cargo				,
		   ubicacion			,
		   codigo_perfil	 	,
		   fecha_cambio			,
		   ubicacion_print1     ,
		   ubicacion_print2
	  into _cargo				,
		   _ubicacion			,
		   _codigo_perfil2		,
		   _fvac_duein			,
		   _ubicacion_print1    ,
		   _ubicacion_print2
	  from cambio_user  
	 where usuario = a_user
	   and registro =  a_registro          --  and status = "R"
	   and fecha_status = _fecha_status ;     

	select descripcion
	  into _nom_perfile2          
	  from inspefi
	 where codigo_perfil = _codigo_perfil2;   

	select trim(ubicacion),trim(descripcion)
	  into _nom_ubicacion_print1,_eqp_print1
	  from insprin
	 where code_printer = _ubicacion_print1;   

	select trim(ubicacion),trim(descripcion)
	  into _nom_ubicacion_print2,_eqp_print2
	  from insprin
	 where code_printer = _ubicacion_print2;   

	   LET _nom_print1 = trim(_eqp_print1)||"  "||trim(_nom_ubicacion_print1);
	   LET _nom_print2 = trim(_eqp_print2)||"  "||trim(_nom_ubicacion_print2);

	 return _usuario,
			_descripcion,
			_e_mail,
			_windows_user,
			_fvac_out,
			_fvac_duein,
	 		_clave_correo,
			_clave_tel,
			_tel_directo,
			_tel_extenci,
			_cod_equipo,
			_buzon_print, 
			_buzon_clave,
			_cod_carnet,
			_buzon_print2,	
			_buzon_clave2,	
			_n_acceso,	
			_n_cargo,	
			_depto_name,
			_n_agencia,
			_ubicacion,
			_nom_perfile2,
			_nom_print1 ,
			_nom_print2 
	   with resume;
		   
end procedure;
				 


