-- Prueba de truncate

drop procedure prueba_trncate;

create procedure "informix".prueba_trncate()
returning integer,
		  char(100);

define _producto		char(5);
define _categoria  	    char(5);  
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

------------------------------------------------------------------------------
--                          Prueba
------------------------------------------------------------------------------

--set debug file to "sp_par296.trc";
--trace on;

truncate table a;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach 
select cod_producto, categoria
into _producto, _categoria
from a

end foreach

end 

return 0, "no hay datos";

end procedure
