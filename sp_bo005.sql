-- Pasar la Morosidad

-- Creado    : 23/07/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo005; 

create procedure sp_bo005()
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
 
	call sp_cob134(_periodo_ant) returning _error, _descripcion;

else

	let _error = 0;
	let _descripcion = "Actualizacion No Es Necesaria";

end if

return _error, _descripcion;

end procedure