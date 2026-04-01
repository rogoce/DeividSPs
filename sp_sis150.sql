--- Usuarios con cambio de status por dia
--- Roman Gordon
--- 25/04/2011

drop procedure sp_sis150;

create procedure "informix".sp_sis150()
returning char(8),char(1),char(50);

define _cant          	integer;

define r_error        	smallint;
define r_error_isam   	smallint;
define r_descripcion  	char(30);

define _fecha_status    date;
define _usuario			char(8);
define _status			char(1);
define _org_unit		char(50);
  
set isolation to dirty read;


foreach
	select usuario, status, unidad_org
	  into _usuario, _status, _fecha_status,_org_unit
	  from segv05:insuser
	 where fecha_status = today

		return _usuario, _status, _org_unit with resume;
end foreach
end procedure 

