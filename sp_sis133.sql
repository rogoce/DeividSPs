--- Actualiza estados de los usuarios
--- Amado Perez M
--- 25/08/2010

drop procedure sp_sis133;

create procedure "informix".sp_sis133(a_usuario CHAR(8), a_status CHAR(1), a_fecha_status date)
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);

DEFINE _fecha_status    DATE;
define _usuario			char(8);
define _status			char(1);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_sis28.trc"; 
--TRACE ON;
-- Actualizacion de la Informacion de los Usuarios

if a_status = "A" then

	update wf_firmas
	   set activo  = 1
	 where usuario = a_usuario;

	update cobcobra
	   set activo  = 1
	 where usuario = a_usuario;
    
	update recajust
	   set activo  = 1
	 where usuario = a_usuario;

	update segv05:insusco
	   set status  = "A",
	       fecha_status = a_fecha_status
	 where usuario = a_usuario;

elif a_status = "I" then

	update wf_firmas
	   set activo  = 0
	 where usuario = a_usuario;

	update cobcobra
	   set activo  = 0
	 where usuario = a_usuario;

	update recajust
	   set activo  = 0
	 where usuario = a_usuario;

	update segv05:insusco
	   set status  = "I",
	       fecha_status = a_fecha_status
	 where usuario = a_usuario;

	update segv05:insuser
	   set fecha_final = a_fecha_status
	 where usuario = a_usuario;

end if


RETURN r_error, r_descripcion  WITH RESUME;

END

end procedure;
				  