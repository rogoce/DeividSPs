-- Actualizando la Transaccion si es aprobado
-- 
-- Creado    : 02/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf23;
--CREATE PROCEDURE "informix".sp_cwf1()
CREATE PROCEDURE "informix".sp_rwf23(a_no_tranrec char(10))
returning integer, 
          char(50);

define _error			integer;
define _actualizado     smallint; 

set isolation to dirty read;

if a_no_tranrec = '2125816' then
set debug file to "sp_rwf23.trc";
trace on;
end if

begin
on exception set _error
	return _error, "Error al Generar la Transaccion Inicial";	
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
   set wf_aprobado = 1
 where no_tranrec = a_no_tranrec;

end


return 0, "Actualizacion Exitosa ... ";	

end procedure