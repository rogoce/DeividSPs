-- Verificacion de Facturas Duplicadas

--DROP PROCEDURE sp_par18;

CREATE PROCEDURE "informix".sp_par18(a_periodo CHAR(7))
RETURNING CHAR(10);
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par18.trc";      
--TRACE ON;                                                                     

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 

	LET _no_factura = _error;
	RETURN _no_poliza;

END EXCEPTION           

FOREACH
 SELECT	no_factura,
        COUNT(*)
   INTO	_no_factura,
        _cantidad
   FROM	endedmae
  WHERE	actualizado = 1
    AND periodo     = 
  GROUP BY no_factura
 HAVING COUNT(*) > 1
  ORDER BY no_factura



END 

END PROCEDURE;

