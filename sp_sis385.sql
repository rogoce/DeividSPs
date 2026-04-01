-- Actualizando la Transaccion si es rechazado
-- 
-- Creado    : 02/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sis385;
--CREATE PROCEDURE "informix".sp_cwf1()
CREATE PROCEDURE "informix".sp_sis385(a_fecha1 DATE, a_fecha2 DATE, a_opcion SMALLINT DEFAULT 0)
returning integer, 
          char(26);

define _error			integer;
DEFINE _cod_asignacion	CHAR(10);

SET ISOLATION TO DIRTY READ;

begin
on exception set _error
	SET ISOLATION TO DIRTY READ;
	return _error, "Error al actualizar la tabla";	
end exception


SET LOCK MODE TO WAIT;

if a_opcion = 1 then
	update chqpagco
	   set generado    = 1,
	       fecha_ini   = current
	 where fecha_desde = a_fecha1
	   and fecha_hasta = a_fecha2;
elif a_opcion = 0 then
	update chqpagco
	   set generado = 0
	 where fecha_desde = a_fecha1
	   and fecha_hasta = a_fecha2;
end if

SET ISOLATION TO DIRTY READ;

end


return 0, "Actualizacion Exitosa ... ";	

end procedure