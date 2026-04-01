--drop procedure sp_sac102;

create procedure sp_sac102()
returning integer,
		  char(50),
		  char(10);
			
define _no_poliza		char(10);
define _no_endoso		char(5);
define _centro_costo	char(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

foreach
 select	no_poliza,
        no_endoso
   into	_no_poliza,
        _no_endoso
   from	endedmae
  where actualizado   = 1
    and sac_asientos <> 2

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then

		if _error_desc is null then
			let _error_desc = "Error en sp_sac93";
		end if

		return _error, _error_desc, _no_poliza;

	end if

end foreach

return 0, "Actualizacion Exitosa", "00000";

end procedure