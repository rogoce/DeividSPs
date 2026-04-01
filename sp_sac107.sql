-- Procedimiento que Reversa la Mayorizacion de un notrx de produccion
-- 
-- Creado    : 25/11/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac107;		

create procedure "informix".sp_sac107(a_notrx integer) 
returning integer,
          char(50),
          char(10),
          char(5);

define _no_poliza	char(10);
define _no_endoso	char(5);

define _error		integer;
define _error_desc	char(50);

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endasien
  where sac_notrx = a_notrx
  group by no_poliza, no_endoso

	call sp_sac72(_no_poliza, _no_endoso) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc, _no_poliza, _no_endoso;
	end if

end foreach

return 0, "Actualizacion Exitosa", "", "";

end procedure