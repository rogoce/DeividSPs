--Modificado Armando Moreno	21/02/2005

--Procedimiento para borrar las tablas de programa de opciones de renovacion.

drop procedure sp_sis61d;

create procedure "informix".sp_sis61d(a_no_poliza char(10))
returning integer;

DEFINE _error   SMALLINT;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

DELETE FROM emirerea where no_poliza = a_no_poliza;
DELETE FROM emireglo where no_poliza = a_no_poliza;
DELETE FROM emirefac where no_poliza = a_no_poliza;
DELETE FROM emirefag where no_poliza = a_no_poliza;
DELETE FROM emiporen where no_poliza = a_no_poliza;
DELETE FROM emiagtre where no_poliza = a_no_poliza;
DELETE FROM emireacr where no_poliza = a_no_poliza;
DELETE FROM emirecum where no_poliza = a_no_poliza;
DELETE FROM emicomar where no_poliza = a_no_poliza;
DELETE FROM emicomir where no_poliza = a_no_poliza;
DELETE FROM emiciare where no_poliza = a_no_poliza;
DELETE FROM emirenco where no_poliza = a_no_poliza;
DELETE FROM emirede0 where no_poliza = a_no_poliza;
DELETE FROM emirede1 where no_poliza = a_no_poliza;
DELETE FROM emirede2 where no_poliza = a_no_poliza;
DELETE FROM emiredes where no_poliza = a_no_poliza;
DELETE FROM emireau1 where no_poliza = a_no_poliza;
DELETE FROM emireau2 where no_poliza = a_no_poliza;
DELETE FROM emiautor where no_poliza = a_no_poliza;
DELETE FROM emireaut where no_poliza = a_no_poliza;
--DELETE FROM emideren where no_poliza = a_no_poliza;
--DELETE FROM emirepo where no_poliza  = a_no_poliza;

end
return 0;
end procedure