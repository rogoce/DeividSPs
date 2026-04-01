-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf78;

create procedure "informix".sp_rwf78(a_incident	integer)
returning     integer;

define _error	integer;
define _descripcion references text ;
define _desc1   lvarchar(2000);					  
define _desc    CHAR(100);
define _vol     integer;

SET DEBUG FILE TO "sp_rwf78.trc";
TRACE ON ;

set lock mode to wait 60;

begin
on exception set _error
	return _error;
end exception

 
select descripcion::lvarchar  into _desc1
  from wf_opago
 where incident =  a_incident;

--let _vol = length(_descripcion);

--let _desc1 = _descripcion::char; 

--let _desc = getString(_descripcion[1, 20]);


end

return 0;

end procedure
