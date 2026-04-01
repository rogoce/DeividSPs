-- Polizas y Unidades Vigentes a una Fecha para pasar a Business Object

-- Creado    : 11/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo002;

create procedure sp_bo002()
returning integer,
          char(50);

define _periodo_ant	char(7);
define _cerrado	   	integer;

define _error	   	integer;
define _descripcion	char(50);

let _error = 0;
let _descripcion = "Actualizacion Exitosa";

set isolation to dirty read;

call sp_bo001(_periodo_ant) returning _error, _descripcion;

return _error, _descripcion;

end procedure