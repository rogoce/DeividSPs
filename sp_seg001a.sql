-- Preliminar info del usuario nuevo

-- Creado     : 18/10/2010 - Autor: Armando Moreno M.
-- Modificado : 18/10/2010 - Por  : Armando Moreno M.
-- Modificado : 17/11/2010 - Por  : Henry Giron

DROP PROCEDURE sp_seg001a;

create procedure "informix".sp_seg001a(a_user char(8))
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
		  char(30);	 --_n_agencia					 

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
DEFINE _control_acceso	  integer;
DEFINE _buzon_print2  integer;
DEFINE _buzon_clave2  char(10);
DEFINE _codigo_agencia  char(3);
DEFINE _n_acceso		char(10);
DEFINE _n_cargo         char(50);
DEFINE _n_agencia       char(30);

let    _nom_perfile   = "";
let    _n_agencia     = "";
let    _n_cargo       = "";
let    _n_acceso      = "";

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud

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
			cargo
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
			_n_cargo
	   from insuser
	  where usuario = a_user;     

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
			_n_agencia	
	   with resume;
		   
end procedure;
				 