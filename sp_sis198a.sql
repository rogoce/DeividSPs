-- Procedimiento para convertir polizas de AUTOMOVIL a AUTOMOVIL FLOTA --
-- 
-- Creado    : 18/08/2014 - Autor: Amado Perez Mendoza.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis198a;

create procedure "informix".sp_sis198a()
returning integer, 
          char(100),
          char(30);
		  	

define _no_poliza   	char(10);

define _error_cod		integer;
define _error_isam		integer;
define _error_desc		varchar(100);
define _error_desc2		varchar(100);

define _no_motor    	varchar(30);
define _cnt         	integer;
define _no_cambio   	smallint;
define _no_documento   	CHAR(20); 
define _estatus_poliza  smallint;

set isolation to dirty read;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc, _error_desc;
end exception

--SET DEBUG FILE TO "sp_sis198a.trc"; 
--trace on;

foreach	with hold
	select no_documento
	  into _no_documento
	  from tmp_autoflota2
	 where procesado = 0

    let _no_poliza = sp_sis21(_no_documento);

    select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

    if _estatus_poliza = 1 then
	    call sp_sis198(_no_documento) returning _error_cod, _error_desc, _error_desc2;
		if _error_cod = 0 then
		    update tmp_autoflota2
			   set procesado = 1 
			 where no_documento = _no_documento;
		else
		    update tmp_autoflota2
			   set error = trim(_error_desc) || trim(_error_desc2),
			       procesado = 3 
			 where no_documento = _no_documento;
		end if
	else
	    update tmp_autoflota2
		   set error = "Poliza no vigente" 
		 where no_documento = _no_documento;
	end if
   

end foreach  	  	
end

--COMMIT WORK;


let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc,"";

end procedure;
