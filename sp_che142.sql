-- Insertando 	  
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_che142;

create procedure sp_che142(a_requis char(10))
returning integer, char(50);

define _error           integer;
define _error_isam		integer;
define _error_desc		char(50);
define _incidente    	integer;


begin

on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_pro348.trc"; 
--trace on; 

Select max(incidente)
  Into _incidente
  From chqchmae;

let _incidente = _incidente + 1;

UPDATE chqchmae 
   SET incidente = _incidente 
 where no_requis = a_requis;

return 0, "Actualizacion Exitosa";


end

end procedure