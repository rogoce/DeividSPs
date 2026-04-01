-- Preliminar Info del Usuario Nuevo
-- Creado     : 18/10/2010 - Autor: Armando Moreno M.
-- Modificado : 18/10/2010 - Por  : Armando Moreno M.
-- Modificado : 17/11/2010 - Por  : Henry Giron
-- Modificado : 27/11/2013 - Pof  : Angel Tello

drop procedure sp_seg001d;
create procedure "informix".sp_seg001d(a_user char(8))
returning char(8),   --_usuario,
		  char(30),  --_descripcion,
	      char(30),	 --_e_mail,
		  char(20),	 --_windows_user,
	   	  date,	     --_fvac_out,
		  date,      --_fvac_duein,
		  char(30),  --_clave_correo,   
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
		  char(50),  --_ubicacion
		  char(100), --nombre y _ubicacion_print1
		  char(100), --nombre y _ubicacion_print2
		  char(30),  --_e_mail2,
		  char(20),	 -- _v_cot_web
		  char(20);  -- _v_workflow	


define _nom_print1				char(100);		  
define _nom_print2				char(100);		
define _depto_name				char(100);
define _nom_ubicacion_print1	char(50);		  
define _nom_ubicacion_print2	char(50);
define _ubicacion				char(50);
define _cod_cargo				char(50);		  
define _n_cargo					char(50);
define _clave_correo			char(30);
define _descripcion				char(30); -- 2
define _nom_perfile				char(30);	-- 9 
define _eqp_print1				char(30);
define _eqp_print2				char(30);		
define _n_agencia				char(30);
define _e_mail					char(30); -- 3
define _windows_user			char(20); -- 5
define _buzon_clave2			char(10);
define _buzon_clave				char(10);
define _tel_extenci				char(10);
define _tel_directo				char(10);
define _clave_tel				char(10);
define _n_acceso				char(10);
define _cod_equipo				char(8);
define _usuario					char(8);  -- 1
define _cia_depto				char(5);
define _ubicacion_print1		char(3);
define _ubicacion_print2		char(3);
define _codigo_agencia			char(3);
define _codigo_perfil			char(3);	-- 8
define _cod_motivo				char(3);
define _com_ejec				char(1);
define _ver_web					char(1);
define _status					char(1);  -- 4
define _buzon_print				integer;
define _cod_carnet				integer;
define _control_acceso			integer;
define _buzon_print2			integer;
define _fvac_duein				date;	    -- 7
define _fvac_out				date;	    -- 6
define _e_mail2					char(30);   -- 3
define _cot_web					integer;  --captura el valor en la tabla
define _v_cot_web				char(20); --devvuelve el valor al reporte
define _workflow				integer;  --captura el valor en la tabla	 
define _v_workflow				char(20); --devvuelve el valor al reporte



let    _nom_ubicacion_print1	= "";
let    _nom_ubicacion_print2	= "";
let    _ubicacion_print1		= "";
let    _ubicacion_print2		= "";
let    _nom_perfile				= "";
let    _eqp_print1				= "";
let    _eqp_print2				= "";
let    _nom_print1				= "";
let    _nom_print2				= "";
let    _n_agencia				= "";
let    _ubicacion				= "";
let    _n_acceso				= "";
let    _n_cargo					= "";
let    _e_mail2					= "***";
let    _v_cot_web				= "No tiene";
let    _v_workflow				= "No tiene";

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;

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
			cargo,
			ubicacion,
			ubicacion_print1,
			ubicacion_print2,
			e_mail2,
			cot_web,
			workflow
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
			_cod_cargo,
			_ubicacion,
			_ubicacion_print1,
			_ubicacion_print2,
			_e_mail2,
			_cot_web,
			_workflow		
	   from insuser
	  where usuario = a_user;     

	let _cod_cargo = trim(_cod_cargo);
	
	select nombre
	  into _n_cargo
	  from inscargo
	 where cod_depto = _cia_depto
	   and cod_cargo = _cod_cargo;

	if _n_cargo = '' or _n_cargo is null then
		let _n_cargo = _cod_cargo;
	end if

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
		
		--validacion si se utiliza el cotizador web
	   if _cot_web = 1  then
			let	_v_cot_web = _windows_user;
		end if
	   
	   if _workflow = 1  then
			let	_v_workflow = _windows_user;
		end if

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
			_nom_print1 ,
			_nom_print2,
			_e_mail2,
			_v_cot_web,
			_v_workflow
	   with resume;
		   
end procedure;

		