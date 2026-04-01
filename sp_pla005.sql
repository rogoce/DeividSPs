-- Actualizacion de la vacacion en insuser
-- Armando Moreno 08/10/2010
drop procedure sp_pla005;
create procedure sp_pla005(a_usuario char(10), a_user char(10), a_fecha_ini date, a_fecha_fin date,a_cod_motivo char(3))
RETURNING SMALLINT, CHAR(30);

define _fecha datetime year to fraction(5);
DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _agencia         CHAR(3);
define _usuario_windows	varchar(20);

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET _agencia = "";
--SET DEBUG FILE TO "sp_pla005.trc"; 
--TRACE ON;

let _fecha = current;

select codigo_agencia 
  into _agencia
  from insuser 
 where usuario = a_usuario; 

if	a_fecha_fin <= _fecha then

		update insuser
		   set status        = "A",
		       fecha_status  = today,
			   fvac_out      = null,
			   fvac_duein    = null,
			   cod_motivo    = null
	     where usuario = a_usuario;	

		update wf_firmas
		   set activo  = 1
		 where usuario = a_usuario;

		update insusco 
		   set status        = "A",
		       fecha_status  = today
	     where usuario = a_usuario
	       and status        = "I" 
	       and codigo_agencia = _agencia ;

		update cobcobra 
		   set activo        = 1
	     where usuario = a_usuario
	       and tipo_cobrador <> 13;
		
		update recajust
		   set activo  = 1
		 where usuario = a_usuario;	
		
		select windows_user
		  into _usuario_windows
		  from insuser
		 where usuario = a_usuario;

		if _usuario_windows is null then
			let _usuario_windows = a_usuario;
		end if
		 
		insert into insactivo(usuario,status,fecha_added)
		values (trim(_usuario_windows),'A',_fecha);		
else

	if a_fecha_ini <= _fecha then

		update insuser
		   set status  = "I"
	     where usuario = a_usuario;

		update insusco 
		   set status        = "I",
		       fecha_status  = today
	     where usuario = a_usuario
	       and status        = "A" and codigo_agencia = _agencia ;	

		update cobcobra 
		   set activo  = 0
	     where usuario = a_usuario
	       and tipo_cobrador <> 13;
	       
		update wf_firmas	       
	       set activo  = 0   
		 where usuario = a_usuario;

		update recajust		
		   set activo  = 0
		 where usuario = a_usuario;

		select windows_user
		  into _usuario_windows
		  from insuser
		 where usuario = a_usuario;

		if _usuario_windows is null then
			let _usuario_windows = a_usuario;
		end if
		 
		insert into insactivo(usuario,status,fecha_added)
		values (trim(_usuario_windows),'I',_fecha);

	end if

	update insuser
	   set fvac_out	  =	a_fecha_ini,
		   fvac_duein = a_fecha_fin,
		   cod_motivo = a_cod_motivo
	 where usuario    = a_usuario;
end if

insert into rrhvachi(
usuario,
date_added,
user_added,
fec_vac_ini,
fec_vac_fin,
cod_motivo)
values(
a_usuario,
_fecha,
a_user,
a_fecha_ini,
a_fecha_fin,
a_cod_motivo);


RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure