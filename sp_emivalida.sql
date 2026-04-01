-- Procedimiento que valida la emision de las póliza
-- 
-- Creado     : 08/01/2014 - Autor: Federico Cornado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emivalida;

create procedure sp_emivalida() returning integer, char(50);

define _error			integer;
define _error_isam		integer;
define _cantidad_emi	integer;
define _cantidad_end	integer;
define _error_desc		char(50);
define _descripcion		char(50);
define _no_documento    varchar(20); 
define _no_factura      varchar(20);  


--set debug file to "sp_cob253.trc";

set isolation to dirty read;

	foreach
		select no_documento, no_factura
		  into _no_documento, _no_factura
		  from emivalida

		SELECT COUNT(*) 
		  INTO _cantidad_emi 
		  FROM emipomae 
		 WHERE no_documento = _no_documento
		   and no_factura   = _no_factura;

		SELECT COUNT(*) 
		  INTO _cantidad_end 
		  FROM endedmae 
		 WHERE no_documento = _no_documento
		   and no_factura   = _no_factura;

		   if _cantidad_emi > 0 or _cantidad_end > 0 then
				update emivalida
				   set realizada = 1
				 WHERE no_documento = _no_documento
				   and no_factura   = _no_factura;
		   end if
	   
	end foreach

RETURN 0, "Exito";

end procedure