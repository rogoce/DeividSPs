-- Borrando Cobmoros

-- Creado    : 23/07/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo030; 

create procedure sp_bo030()
returning integer,
          char(50);

define _periodo_ant		char(7);
define _cerrado	   		integer;

define _error	   		integer;
define _error_isam		integer;
define _error_desc		char(50);
define _error_desc2		char(50);
define _no_documento	char(20);

begin 
on exception set _error, _error_isam, _error_desc 
	return _error_isam, _error_desc2;
end exception

let _error       = 0;
let _error_desc2 = "Actualizacion Exitosa";

set isolation to dirty read;

call sp_par189() returning _cerrado, _periodo_ant;

if _cerrado = 1 then

	let _error_desc2 = "Borrando cobmoros";

	foreach
	 select no_documento
	   into _no_documento
	   from deivid_cob:cobmoros
	  where periodo = _periodo_ant

		delete from deivid_cob:cobmoros
		 where no_documento = _no_documento
		   and periodo      = _periodo_ant;

	end foreach

else

	let _error = 0;
	let _error_desc2 = "Actualizacion No Es Necesaria";

end if

end

return _error, _error_desc2;

end procedure