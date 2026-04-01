create procedure "informix".pd_uniemifacon(old_no_poliza char(10),
old_no_unidad char(5))
RETURNING INTEGER;
define errno integer;
define errmsg char(255);
define numrows integer;
DEFINE _error  SMALLINT;

BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error;         
	END EXCEPTION

-- Delete all children in "emifacon"
delete from emifacon
 where no_poliza = old_no_poliza
   and no_unidad = old_no_unidad;

END
RETURN 0;
end procedure        