-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cob140;

create procedure sp_cob140()
returning integer,
          char(50);

define _periodo_ant	char(7);
define _cerrado	   	integer;

define _error	   	integer;
define _descripcion	char(50);

let _error = 0;
let _descripcion = "Actualizacion Exitosa";

set isolation to dirty read;

call sp_par189() returning _cerrado, _periodo_ant;

if _cerrado = 1 then
 
	call sp_bo003(_periodo_ant) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	call sp_bo021(_periodo_ant) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

else

	let _error = 0;
	let _descripcion = "Actualizacion No Es Necesaria";

end if

return _error, _descripcion;

end procedure