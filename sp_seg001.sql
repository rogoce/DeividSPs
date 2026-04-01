-- Preliminar info del usuario nuevo

-- Creado     : 18/10/2010 - Autor: Armando Moreno M.
-- Modificado : 18/10/2010 - Por  : Armando Moreno M.

DROP PROCEDURE sp_seg001;

create procedure "informix".sp_seg001(a_user char(8))
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
		  integer,	 --_buzon_clave
		  integer;	 --_cod_carnet
					 

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
DEFINE _buzon_clave	  integer;
DEFINE _cod_carnet	  integer;
DEFINE _registro	  integer;

let    _nom_perfile   = "";

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud

	 select usuario,
	        descripcion,
	        e_mail,
	        status,
		    windows_user,
			fvac_out,
			fvac_duein,
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
			cod_carnet
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
			_cod_carnet
	   from insuser
	  where usuario = a_user;
     

	select  nombre
	  into  _depto_name
	  from  insdepto 
	  where cod_depto = _cia_depto;

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
			_cod_carnet
	   with resume;
		   
end procedure;
