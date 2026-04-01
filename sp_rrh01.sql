-- Informaci¢n: para Panam  Presentar los datos en el Grid
-- Creado     : 06/10/2010 - Autor: Armando Moreno M.
-- Modificado : 06/10/2010 - Por  : Armando Moreno M.

--DROP PROCEDURE sp_rrh01;

create procedure "informix".sp_rrh01()
returning CHAR(8),   -- 1. usuario 
		  CHAR(30),  -- 2. Nombre del Usuario 
	      CHAR(30),	 --	3. correo 
		  char(1),	 -- 4. estado del Usuario 
		  CHAR(20),	 -- 5. usuario de Windows 
	   	  DATE,	     -- 6. fecha inicial de vacaciones 
		  DATE,      -- 7. fecha de regreso de vacaciones
		  CHAR(30),  -- 8. Nombre del Perfil 
		  CHAR(100), --	9. Nombre del departamento
		  CHAR(10),	 --10. Telefono directo
		  CHAR(10),	 --11. Telefono extencion
		  CHAR(1),	 --12. Flag - Ver Web
		  CHAR(1);   --13. Flag - Si Pertenece al comite Ejecutivo

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
DEFINE _tel_extenci	  char(10);
DEFINE _ver_web 	  char(1);
DEFINE _depto_name    char(100);
DEFINE _com_ejec      char(1);
let    _nom_perfile   = "";

SET ISOLATION TO DIRTY READ;


-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
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
			com_ejecutivo
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
       		_com_ejec
	   from insuser
   order by status, usuario

	select  nombre
	  into  _depto_name
	  from  insdepto 
	  where cod_depto = _cia_depto;

	select descripcion
	  into _nom_perfile          
	  from inspefi
	 where codigo_perfil = _codigo_perfil;        	

	 return _usuario,	   		-- 1. Usuario 
	 		_descripcion,	   	-- 2. Nombre completo del usuario
			_e_mail,     		-- 3. Correo del usuario 
			_status,	   	    -- 4. Estado del usuario 
			_windows_user,		-- 5. Usuario de windows
			_fvac_out,			-- 6. Fecha inicial de vacaciones 
			_fvac_duein,	    -- 7. Fecha de regreso de Vacaciones 
			_nom_perfile,		-- 8. Nombre del Perfil 
			_depto_name,	    -- 9. Nombre del departamento 
			_tel_directo,		--10. Telefono directo
			_tel_extenci,		--11. Telefono Extenci¢n
			_ver_web,			--12. ver en el Web
			_com_ejec           --13. ver comite ejecutivo
	   with resume;
		   
end foreach;
end procedure;
