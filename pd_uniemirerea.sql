-- Delete procedure "pd_emipouni" for table "emifacon"

drop procedure pd_uniemirerea;
create procedure pd_uniemirerea(old_no_poliza char(10),old_no_unidad char(5))
RETURNING INTEGER;
define errno integer;
define errmsg char(255);
define numrows integer;
DEFINE _error  SMALLINT;

BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error;         
	END EXCEPTION

-- Delete all children in "emirerea"

delete from emirerea where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirefac where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirede0 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirede1 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirede2 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emireacr where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emiredes where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirede1 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirede2 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emireau1 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emireau2 where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emirenco where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emiautor where no_poliza = old_no_poliza and no_unidad = old_no_unidad;
delete from emireaut where no_poliza = old_no_poliza and no_unidad = old_no_unidad;

END
RETURN 0;
end procedure;
