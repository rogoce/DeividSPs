-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_wfh03;

create procedure "informix".sp_wfh03(a_no_caso char(10)) 
returning integer;

define _error	integer;
define _fecha_inicio datetime year to minute;
define _user_solucion	char(8);

begin
on exception set _error
	return _error;
end exception

select fecha_inicio,
       user_solucion
  into _fecha_inicio,
	   _user_solucion
  from helpdesk2
 where no_caso = a_no_caso
   and fecha_solucion is null;

update helpdesk
   set fecha_solucion = current,
       fecha_inicio   = _fecha_inicio,
	   user_solucion  = _user_solucion
 where no_caso        = a_no_caso;

update helpdesk2
   set fecha_solucion = current,
       atendiendo     = 0
 where no_caso        = a_no_caso
   and fecha_solucion is null;
end

return 0;

end procedure
