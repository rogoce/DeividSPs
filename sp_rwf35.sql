-- Actualizando la Transaccion si es rechazado
-- 
-- Creado    : 02/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_rwf23;
--CREATE PROCEDURE "informix".sp_cwf1()
CREATE PROCEDURE "informix".sp_rwf35(a_no_tranrec char(10))
returning integer, 
          char(26);

define _error			integer;
DEFINE _cod_asignacion	CHAR(10);
define _actualizado     smallint;

SET ISOLATION TO DIRTY READ;

begin
on exception set _error
	SET ISOLATION TO DIRTY READ;
	return _error, "Error al Generar la Transaccion Inicial";	
end exception


 SELECT cod_asignacion, actualizado
   INTO _cod_asignacion, _actualizado
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

if _actualizado = 1 then
	return 0, "Ya estaba actualizado";
end if


SET LOCK MODE TO WAIT 60;

update rectrmae
   set wf_aprobado = 0
 where no_tranrec = a_no_tranrec;

if _cod_asignacion <> ""  then

    update atcdocde
	   set suspenso = 0
	 where cod_asignacion = _cod_asignacion
	   and completado = 0;

end if

SET ISOLATION TO DIRTY READ;

end


return 0, "Actualizacion Exitosa ... ";	

end procedure