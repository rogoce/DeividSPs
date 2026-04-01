
drop procedure sp_actcomp;

create procedure sp_actcomp()
returning integer,
            char(100);

define _trx1_notrx	    integer;
define _mayor_error		integer;
define _mayor_desc		char(150);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


-- Mayorizacion

foreach
select trx1_notrx
into _trx1_notrx
from cgltrx1
where trx1_comprobante like('PRO%')

	call sp_sac64("001", _trx1_notrx, 'informix') returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		if _mayor_desc is null then
			let _mayor_desc = "Error en sp_sac64";
		end if

		return _mayor_error, _mayor_desc;

	end if

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure