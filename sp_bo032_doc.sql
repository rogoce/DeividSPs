-- Actualizacion de los registros de morosidad y cobros para BO

-- Creado    : 28/08/2006 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_bo032_doc; 

create procedure "informix".sp_bo032_doc(
a_no_documento	char(20),
a_periodo 			char(7))
returning integer,
          char(50);

define _error	   		integer;
define _error_isam	integer;
define _error_desc	char(50);
define _descripcion	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

-- Eliminar Cobmoros
delete from deivid_cob:cobmoros
 where no_documento	= a_no_documento
   and periodo      	= a_periodo;

-- Calcular la Morosidad
call sp_cob134_doc(a_no_documento, a_periodo) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion;
end if		

-- Calcular los Cobros
call sp_bo003_doc(a_no_documento, a_periodo) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion;
end if		

-- Fecha Ultimo Pago
call sp_bo021_doc(a_no_documento, a_periodo) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion;
end if	

return 0, "Actualizacion Exitosa";

end

end procedure