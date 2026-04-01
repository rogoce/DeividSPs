-- Actualizacion de la tabla de Transaccion desde Ultimus Workflow
-- 
-- Creado    : 02/08/2004 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf22;
CREATE PROCEDURE "informix".sp_rwf22(a_no_tranrec char(10), a_incidente integer)
returning integer, 
          char(26);

define _error			integer;
define _actualizado     smallint;

--set debug file to "sp_cwf1.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Actualizar Transaccion";	
end exception

select actualizado
  into _actualizado
  from rectrmae
 where no_tranrec =  a_no_tranrec;

if _actualizado = 1 then
	return 0, "Ya estaba actualizado";
end if

set lock mode to wait 60;

update rectrmae
   set wf_incidente = a_incidente,
       wf_aprobado = 3 
 where no_tranrec = a_no_tranrec;

end

return 0, "Actualizacion Exitosa ... ";	

end procedure