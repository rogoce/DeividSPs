-- Procedimiento que crea los valores del auxiliar de comisiones por pagar
-- 
-- Creado     : 02/03/2006 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac46;		

create procedure "informix".sp_sac46()
returning integer,
          char(50);

define _cod_agente	char(5);
define _cantidad	smallint;

define _error		integer;
define _error_desc	char(50);

let _cantidad = 0;

foreach
 select cod_agente
   into _cod_agente
   from agtagent

	let _cantidad = _cantidad + 1;

	call sp_sac45(_cod_agente) returning _error, _error_desc;
	
	if _error <> 0 then
		return 1, "Error al actualizar el Agente " || _cod_agente;
	end if

end foreach

return _cantidad, " Registros Actualizados con Exito";

end procedure
