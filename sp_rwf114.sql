-- Procedimiento que retorna si es la firma automatica confirmada

-- Creado    : 01/02/2013 - Autor: Amado Perez M 

drop procedure sp_rwf114;

create procedure sp_rwf114(a_no_requis char(10), a_firma1 char(20), a_opcion smallint)
returning integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _cod_banco       char(3);
define _cod_chequera    char(3);

set isolation to dirty read;

begin

on exception set _error, _error_isam, _error_desc
   return _error;
end exception

select cod_banco,   
	   cod_chequera
  into _cod_banco,   
	   _cod_chequera
  from chqchmae
 where no_requis = a_no_requis;

set lock mode to wait;

if a_opcion = 1 then
	update chqchmae
		set firma1 = a_firma1,
		    firma2 = null
	 where no_requis = a_no_requis;
else
	if _cod_banco = "001" and _cod_chequera = "006" then
		update chqchmae
			set firma1 = null,
				firma2 = null,
				fecha_paso_firma = null,
				en_firma = 0
		 where no_requis = a_no_requis;
	else
		update chqchmae
			set firma1 = null,
				firma2 = null,
				fecha_paso_firma = null,
				en_firma = 4
		 where no_requis = a_no_requis;
	end if
end if

set isolation to dirty read;

return 0;

end

end procedure