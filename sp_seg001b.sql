-- Preliminar info de modificacion de Perfil de usuario 

-- Creado     : 18/10/2010 - Autor: Armando Moreno M.
-- Modificado : 18/10/2010 - Por  : Armando Moreno M.
-- Modificado : 17/11/2010 - Por  : Henry Giron
-- Modificado : 27/11/2013 - Pof  : Angel Tello

drop procedure sp_seg001b;

create procedure "informix".sp_seg001b(a_user char(8),a_registro integer)
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
		  char(30),	 -- nuevo_perfil
		  char(100),  --nombre y _ubicacion_print1
		  char(100),  --nombre y _ubicacion_print2
		  char(30),  --_e_mail2,
		  char(20),	 -- _v_cot_web
		  char(20);  -- _v_workflow	
		  
define _usuario       			char(8);  -- 1
define _descripcion   			char(30); -- 2
define _e_mail        			char(30); -- 3 
define _status        			char(1);  -- 4
define _windows_user  			char(20); -- 5
define _fvac_out      			date;	    -- 6
define _fvac_duein    			date;	    -- 7
define _codigo_perfil 			char(3);	-- 8
define _nom_perfile   			char(30);	-- 9 
define _cia_depto     			char(5);
define _tel_directo	  			char(10);
define _ver_web 	  			char(1);
define _depto_name    			char(100);
define _com_ejec      			char(1);
define _cod_motivo    			char(3);
define _clave_correo  			char(30);
define _clave_tel     			char(10);
define _tel_extenci	  			char(10);
define _cod_equipo 	  			char(8);
define _buzon_print   			integer;
define _buzon_clave	  			char(10);
define _cod_carnet	  			integer;
define _control_acceso			integer;
define _buzon_print2    		integer;
define _buzon_clave2    		char(10);
define _codigo_agencia  		char(3);
define _n_acceso				char(10);
define _n_cargo         		char(50);
define _n_agencia       		char(30);
define _ubicacion				char(50) ;	
define _fecha_status    		date;
define _nom_perfile2    		char(30); 
define _ubicacion_print1    	char(3);		  
define _ubicacion_print2 		char(3);		  
define _nom_ubicacion_print1 	char(50);		  
define _nom_ubicacion_print2 	char(50);		  
define _eqp_print1           	char(30);		  
define _eqp_print2           	char(30);		
define _nom_print1           	char(100);		  
define _nom_print2           	char(100);	
define _registro				integer;
define _cod_cargo				char(50);
define _e_mail2					char(30); 
define _cot_web 				char(20);	 
define _workflow				char(20);  
define _v_cot_web				integer; -- variables de comparacion cotizador web 
define _v_workflow				integer; -- variables de comparacion workflow
		  


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
let    _eqp_print1 = 	"";
let    _eqp_print2 = 	"";
let    _nom_print1 = 	"";
let    _nom_print2 = 	"";
let	   _clave_correo = 	'';
let    _cot_web =    	"No tiene";
let    _workflow =   	"No tiene";


set isolation to dirty read;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud

	
select windows_user,
	   fvac_out,
	   status,
	   com_ejecutivo,
	   cod_telefono,
	   cod_carnet
  into _windows_user,
	   _fvac_out,
	   _status,
	   _com_ejec,
	   _clave_tel,
	   _cod_carnet
  from insuser
 where usuario = a_user;	

select usuario,
	   descripcion,
	   e_mail, --fvac_duein,
	   codigo_perfil,
	   cia_depto,
	   tel_directo,
	   tel_extenci,
	   fgl_ver_web,
	   tel_directo,
	   tel_extenci,
	   cod_equipo,
	   buzon_print,
	   buzon_clave,
	   buzon_print2,
	   buzon_clave2,
	   control_acceso,
	   codigo_agencia,
	   cargo,
	   fecha_status,
	   fecha_cambio,
	   cot_web,
	   workflow,
	   e_mail2,
	   ubicacion,
	   ubicacion_print1,
	   ubicacion_print2,
	   cod_telefono
  into _usuario,
	   _descripcion,
	   _e_mail,
	   _codigo_perfil,
	   _cia_depto,
	   _tel_directo,
	   _tel_extenci,
	   _ver_web,
	   _tel_directo,
	   _tel_extenci,
	   _cod_equipo,
	   _buzon_print,
	   _buzon_clave,
	   _buzon_print2,
	   _buzon_clave2,
	   _control_acceso,
	   _codigo_agencia,
	   _cod_cargo,
	   _fecha_status,
	   _fvac_duein,
	   _v_cot_web,
	   _v_workflow,
	   _e_mail2,
	   _ubicacion,
	   _ubicacion_print1,
	   _ubicacion_print2,
	   _clave_tel
  from cambio_user
 where usuario = a_user
   and registro = a_registro;     

{select fecha_status
into _fecha_status
from cambio_user
where usuario = a_user
and registro = a_registro;	}

let _cod_cargo = trim(_cod_cargo);

select nombre
  into _n_cargo
  from inscargo
 where cod_depto = _cia_depto
   and cod_cargo = _cod_cargo;

if _n_cargo = '' or _n_cargo is null then
	let _n_cargo = _cod_cargo;
end if

select nombre
  into _depto_name
  from insdepto 
 where cod_depto = _cia_depto;

select descripcion
  into _n_agencia
  from insagen
 where codigo_agencia = _codigo_agencia;

let	_n_acceso = "Grupo "||_control_acceso;

select descripcion
  into _nom_perfile          
  from inspefi
 where codigo_perfil = _codigo_perfil;        	

select descripcion
  into _nom_perfile2          
  from inspefi
 where codigo_perfil = _codigo_perfil;   

select trim(ubicacion),
	   trim(descripcion)
  into _nom_ubicacion_print1,
	   _eqp_print1
  from insprin
 where code_printer = _ubicacion_print1;   

select trim(ubicacion),
	   trim(descripcion)
  into _nom_ubicacion_print2,
	   _eqp_print2
  from insprin
 where code_printer = _ubicacion_print2;   

let _nom_print1 = trim(_eqp_print1)||"  "||trim(_nom_ubicacion_print1);
let _nom_print2 = trim(_eqp_print2)||"  "||trim(_nom_ubicacion_print2);

if _v_cot_web = 1 then
	let _cot_web = _windows_user;
end if

if _v_workflow = 1 then
	let _workflow = _windows_user;
end if


return	_usuario,		 --1_usuario,
		_descripcion,	 --2_descripcion,
		_e_mail,		 --3_e_mail,
		_windows_user,	 --4_windows_user,
		_fvac_out,		 --5_fvac_out,
		_fvac_duein,	 --6_fvac_duein,
		_clave_correo,	 --7_clave_correo,   
		_clave_tel,		 --8_clave_tel,					
		_tel_directo,	 --9_tel_directo,				
		_tel_extenci,	 --10_tel_extenci,				
		_cod_equipo,	 --11_cod_equipo,					
		_buzon_print, 	 --12_buzon_print, 				
		_buzon_clave,	 --13_buzon_clave,
		_cod_carnet,	 --14_cod_carnet,
		_buzon_print2,	 --15_buzon_print2, 				
		_buzon_clave2,	 --16_buzon_clave2,
		_n_acceso,		 --17_n_acceso,	
		_n_cargo,		 --18_n_cargo,					
		_depto_name,	 --19_depto_name,					
		_n_agencia,		 --20_n_agencia					
		_ubicacion,		 --21_ubicacion
		_nom_perfile2,	 --22 nuevo_perfil
		_nom_print1 ,	 --23nombre y _ubicacion_print1
		_nom_print2, 	 --24nombre y _ubicacion_print2
		_cot_web,		 --25_e_mail2,
		_workflow,		 --26_v_cot_web
		_e_mail2		 --27 _v_workflow	
with resume;
   
end procedure;