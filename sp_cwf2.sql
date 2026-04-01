-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cwf2;
--CREATE PROCEDURE "informix".sp_cwf1()
CREATE PROCEDURE "informix".sp_cwf2(a_no_requis char(10), a_autoriza smallint, a_autoriza_n char(20))
returning integer, 
          char(26);

define _error			integer;
define _fecha           date;
define _usuario         char(8);

LET _fecha = current;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al actualizar quien autoriza chqchmae";	
end exception

if a_autoriza_n is null or trim(a_autoriza_n) = "" then
	let a_autoriza_n = 'EDEFRANCO';
	let a_autoriza = 1;
end if 

select usuario
  into _usuario 
  from insuser
 where windows_user = a_autoriza_n;

set lock mode to wait 60;

update chqchmae
   set aut_workflow       = a_autoriza,
       aut_workflow_user  = trim(_usuario),
	   aut_workflow_fecha = _fecha,
	   aut_workflow_hora  = current
 where no_requis = a_no_requis;

end


return 0, "Actualizacion Exitosa ... ";	

end procedure