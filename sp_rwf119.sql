-- Procedimiento para generacion una nota del reclamo
-- 
-- creado: 18/02/2011 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf119;
CREATE PROCEDURE "informix".sp_rwf119(a_no_poliza CHAR(10), a_no_endoso CHAR(10))
                  RETURNING integer;  

DEFINE _error               integer;

DEFINE _cant1               integer;
DEFINE _cant2               integer;

--SET DEBUG FILE TO "sp_rwf104.trc";
--TRACE ON;


BEGIN
ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION 

SET ISOLATION TO DIRTY READ;

let _cant1 = 0;
let _cant2 = 0;

select count(*) 
  into _cant1
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and cod_endomov = "003";		  --Endoso de rehabilitacion

select count(*)
  into _cant2
  from coboutleg
 where no_poliza = a_no_poliza;

if _cant1 > 0 and _cant2 > 0 then
	return 1;
else
	return 0;
end if
END


END PROCEDURE
