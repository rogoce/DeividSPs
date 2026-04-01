-- Procedure que actualiza la requisiciones cuando hay excepcion

-- AmadoPerez 10/01/2017


drop procedure sp_rec311;

create procedure sp_rec311(a_requis char(10), a_finiquito smallint default 0, a_autorizado smallint default 0)
RETURNING integer, varchar(100);

define _error_cod		integer;
define _error_isam		integer;
define _error_desc		varchar(100);

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

begin
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception
update chqchmae 
	set finiquito_firmado = a_finiquito,
	    autorizado = a_autorizado
 where no_requis = a_requis;

				  
RETURN 0, "Actualizacion Exitosa";

end
end procedure