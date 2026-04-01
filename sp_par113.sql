-- Procedure que verifica que existan todos los registros en endedmae

drop procedure sp_par113;

create procedure "informix".sp_par113()

define _no_poliza	char(10);
define _no_endoso	char(5);
define _cantidad	integer;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
  
	CALL sp_sis70(_no_poliza, _no_endoso);

end foreach      	

end procedure