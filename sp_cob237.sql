-- Creacion de la Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob237;

create procedure sp_cob237() 
returning integer,
          char(100);

define _cod_chequera	char(3);
define _fecha 		 	date;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

delete from cobcieca2;
delete from cobcieca;

foreach
 select cod_chequera, 
		fecha
   into _cod_chequera, 
		_fecha
   from cobremae
  where periodo    >= "2010-01"
    and actualizado = 1
	and tipo_remesa in ("A", "M")
  order by fecha, cod_chequera

	call sp_cob229(_cod_chequera , _fecha) returning _error, _error_desc;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
