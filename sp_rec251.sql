-- Procedimiento que actualiza las prioridades de las asignaciones para los pagos de salud.

-- Creado:	28/07/2015
drop procedure sp_rec251;
create procedure sp_rec251()
returning integer,
          char(100);

define _prioridad_final	smallint;
define _cod_asignacion	char(10);
define _error           integer;

begin
on exception set _error
	return _error, "Error al Actualizar las Prioridades";
end exception
set isolation to dirty read;

let _prioridad_final = 0;

FOREACH
	select cod_asignacion
	  into _cod_asignacion
	  from atcdocde
	 where completado = 0
	   and cod_asignacion is not null

	let _prioridad_final = sp_rec204(_cod_asignacion);
	update atcdocde
	   set prioridad = _prioridad_final
	 where cod_asignacion = _cod_asignacion; 
	   
END FOREACH 
end
RETURN 0, "Actualizacion Exitosa";

end procedure
