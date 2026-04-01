-- Informacion para SEMM

-- Creado    : 1O/07/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par228;

create procedure "informix".sp_par228()
returning char(30),
          char(100),
          char(20),
          char(1);

define _cedula			char(30);
define _nombre			char(100);
define _no_documento	char(20);
define _estatus			char(1);

define _error			integer;
define _error_desc		char(50);

set isolation to dirty read;

call sp_par227() returning _error, _error_desc;

foreach
 select cedula,
        nombre,
 		no_documento,
 		estatus
   into _cedula,
        _nombre,
 		_no_documento,
 		_estatus
   from tmp_semm

	return _cedula,
           _nombre,
 		   _no_documento,
 		   _estatus
		   with resume;

end foreach

drop table tmp_semm;

end procedure							
