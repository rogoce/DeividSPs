
  
drop procedure sp_sisestafeta;

create procedure sp_sisestafeta()
returning	int,
			char(50);

define _error_desc		char(50);
define _nombre			char(50);
define _ubicacion    	char(50);
define _codigo			char(4);
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


foreach
	select nombre,
		   ubicacion,
		   cod_estafeta
	  into _nombre,
		   _ubicacion,
		   _codigo
	  from cobestafeta
	 
	   let _nombre    = trim(upper(_nombre));
	   let _ubicacion = trim(upper(_ubicacion));   

	update cobestafeta
	   set nombre = _nombre,
		   ubicacion = _ubicacion
	 where cod_estafeta = _codigo;
 end foreach
 end

return 0,'Actualización Exitosa';
end procedure;