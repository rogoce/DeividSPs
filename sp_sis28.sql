--- Actualiza estados a las polizas vencidas
--- Victor Molinar
--- 26/07/2001

drop procedure sp_sis28;
create procedure sp_sis28()
returning smallint, char(30);

define _windows_user	varchar(20);
define r_descripcion  	char(30);
define _usuario			char(8);
define _cod_agencia		char(3);
define _agencia         char(3);
define _status			char(1);
define r_error_isam   	smallint;
define r_error        	smallint;
define _cant          	integer;
define _fecha_status    date;
define _hoy             date;
define _fecha datetime year to fraction(5);
  
begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let _fecha = current;
let _hoy = today;
--SET DEBUG FILE TO "sp_sis28.trc"; 
--TRACE ON;

-- Actualizacion de la Informacion de las Polizas

update emipomae 
   set estatus_poliza	= 3
 where estatus_poliza	= 1
   and vigencia_final	< today
   and vigencia_final	is not null
   and actualizado		= 1;

update emipomae 
   set estatus_poliza	= 1
 where estatus_poliza	= 3
   and vigencia_final	>= today
   and vigencia_final	is not null
   and actualizado		= 1;

-- Actualizacion de las Notas a Polizas para polizas vencidas y canceladas
call sp_sis177() returning r_error, r_descripcion;

-- Actualizacion de la Informacion de los Corredores
update agtagent
   set estatus_licencia = "A",
       suspendido_desde = null,
	   suspendido_hasta = null
 where estatus_licencia = "T"
   and suspendido_hasta	 < today;

 if _hoy = '14-09-2019' then
	SET DEBUG FILE TO "sp_sis28.trc"; 
	TRACE ON;
 end if

-- Actualizacion de la Informacion de los Usuarios

foreach
	select usuario,
		   windows_user
	  into _usuario,
		   _windows_user
	  from segv05:insuser
	 where status	= "A"
	   and fvac_out	<= today
	   and fvac_out	is not null

	let _agencia = "";

	select codigo_agencia 
	  into _agencia
	  from segv05:insuser 
	 where usuario	= _usuario; 

	update segv05:insuser
	   set status		= "I",
	       fecha_status	= today
	 where usuario		= _usuario;

	update segv05:insusco 
	   set status			= "I",
	       fecha_status		= today
	 where usuario			= _usuario
	   and status			= "A"
	   and codigo_agencia	= _agencia ;
		
	if _windows_user is null then
		let _windows_user = _usuario;
	end if

	insert into insactivo(usuario,status,fecha_added)		
	values (_windows_user,'I',_fecha);
end foreach

foreach
	select usuario,
		   windows_user
	  into _usuario,
		   _windows_user
	  from segv05:insuser
	 where status        = "I"
	   and fvac_duein	 < today

	let _agencia = "";

	select codigo_agencia 
	  into _agencia
	  from segv05:insuser 
	 where usuario = _usuario; 
			 	
	update segv05:insuser
	   set status        = "A",
	       fecha_status  = today,
	 	   fvac_out      = null,
		   fvac_duein    = null,
		   cod_motivo    = null
  	 where usuario = _usuario;

  	update segv05:insusco 
  	   set status		= "A",
  	       fecha_status	= today
     where usuario			= _usuario
       and status			= "I" 
       and codigo_agencia	= _agencia ;

  	if _windows_user is null then
  		let _windows_user = _usuario;
  	end if

	insert into insactivo(usuario,status,fecha_added)
	values (_windows_user,'A',_fecha);
end foreach

foreach
	select usuario,
		   status,
		   fecha_status
	  into _usuario,
	  	   _status,
	  	   _fecha_status
	  from segv05:insuser
	 where usuario <> 'CRAMIREZ'

	 if _fecha_status is null then
		let _fecha_status = current;
	 end if

	let _agencia = "";

	select codigo_agencia 
	  into _agencia
	  from segv05:insuser 
	 where usuario = _usuario; 

	if _status = "A" then

		update wf_firmas
		   set activo  = 1
		 where usuario = _usuario;

		update cobcobra
		   set activo		= 1
		 where usuario		= _usuario
		   and cod_sucursal	= _agencia
		   and activo not in(2);
		   --and cod_cobrador not in ('159','314');
        
		update recajust
		   set activo	= 1
		 where usuario	= _usuario;

		update segv05:insusco
		   set status			= "A",
		       fecha_status		= _fecha_status
		 where usuario			= _usuario 
		   and codigo_agencia	= _agencia;
		   
		IF _usuario = 'SCASTILL' then	--Esto es temporal, hasta que se inactive el usuario de Sabish por renuncia.
			update wf_firmas
			   set activo  = 0
			 where usuario = _usuario;
		END IF
	elif _status = "I" then
		
		update wf_firmas
		   set activo	= 0
		 where usuario	= _usuario;

		-- No Desactivar los tipos de cobradores
		-- que son tipo zona
		-- Demetrio Hurtado (24/02/2011)
		--No desactivar los ruteros, Armando Moreno 04/09/2012

		update cobcobra
		   set activo	= 0
		 where usuario	= _usuario
		   and tipo_cobrador not in(13,3);	 

		update recajust
		   set activo	= 0
		 where usuario	= _usuario;

		update segv05:insusco
		   set status			= "I",
		       fecha_status		= _fecha_status
		 where usuario			= _usuario 
		   and codigo_agencia	= _agencia;
	end if
end foreach

return r_error,
	   r_descripcion  with resume;
end
end procedure;
