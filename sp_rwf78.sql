-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf78;

create procedure "informix".sp_rwf78()
returning     integer;

define _error	 integer;
DEFINE _fecha	 DATE;
define _incident integer;

SET DEBUG FILE TO "sp_rwf78.trc";
TRACE ON ;

set isolation to dirty read;

let _fecha = CURRENT;
let _fecha = '25/01/2010';


begin
on exception set _error
	return _error;
end exception

 
FOREACH
	SELECT incident
 	  INTO _incident   
	  FROM wf_opago
	 WHERE fecha_pago <=	_fecha
	   AND (no_requis Is Null
	    OR trim(no_requis) = "") 

return _incident WITH RESUME;

END FOREACH
end


end procedure
