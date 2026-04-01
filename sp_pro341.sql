-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 09/03/2010 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_pro341;

create procedure "informix".sp_pro341()
returning integer,
          char(50);

define _no_poliza	char(10);
define _no_endoso	char(5);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and periodo >= "2010-01"

	call sp_pro340(_no_poliza, _no_endoso) returning _error, _error_desc;
	
	if _error <> 0 then
		return _error, _error_desc; 
	end if	

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure
