-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf62;

create procedure "informix".sp_rwf62(
a_no_caso 	    char(10),
a_user_sol	  	char(20),
a_cod_tipo	    char(3),
a_correo_user	char(50),
a_user_caso		char(8),
a_observacion	char(255),
a_incidente     integer) 
returning integer;

define _error	integer;

--SET DEBUG FILE TO "sp_rwf62.trc";
--TRACE ON ;

LET a_no_caso 	  =	a_no_caso; 	 
LET a_user_sol	  =	a_user_sol;	 
LET a_cod_tipo	  =	a_cod_tipo;	 
LET a_correo_user =	a_correo_user;
LET a_user_caso	  =	a_user_caso;	 
LET a_observacion =	a_observacion;
LET a_incidente   =	a_incidente;  

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

update helpdesk
   set user_solucion  = a_user_sol,
	   cod_tipo		  = a_cod_tipo,
	   correo_user    = a_correo_user,
	   observacion    = a_observacion,
	   incidente      = a_incidente 
 where no_caso        = a_no_caso;

update insuser
   set e_mail  = a_correo_user
 where usuario = a_user_caso;

end

return 0;

end procedure
