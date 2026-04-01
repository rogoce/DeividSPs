-- Procedure que carga los registros de imagenes respaldadas

drop procedure sp_bo101;

create procedure sp_bo101()
returning integer,
          char(50);

{returning integer,
          char(50),
          integer,
          char(20),
          char(7);}
define _error_desc		char(50);
define _no_documento	char(20);
define _periodo			char(7);
define _cantidad		smallint;
define _cant_reg		integer;
define _cant_pro		integer;
define _cant_tot		integer;
define _error			integer;
define _error_isam		integer;

begin
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc;
--	return _error, _error_desc, _error_isam, _no_documento, _periodo;
end exception


truncate table cobmoros4;


end 

return 0, "Actualizacion Exitosa ";
--return 0, "Actualizacion Exitosa ", _cant_tot, _no_documento, _periodo;
 
end procedure