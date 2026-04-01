-- Reaseguro polizas nuevas
-- Genera Reaseguro para pólizas de colectivo ya que son demasiadas unidades para hacerlo manual, se tomará la información de emigloco y no de rearucon 
-- Creado    : 26/04/2021 - Autor: Amado Perez
 

DROP PROCEDURE ap_reaseguro;
CREATE PROCEDURE ap_reaseguro() 
RETURNING  integer;		   
  
DEFINE _no_poliza 		CHAR(10);
DEFINE _no_unidad 		CHAR(5);
DEFINE _suma_asegurada 	DEC(16,2);
DEFINE _error   		INTEGER;

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;
let _error = 0;

FOREACH
	SELECT no_poliza, 
	       no_unidad,
		   suma_asegurada
      INTO _no_poliza,
	       _no_unidad,
		   _suma_asegurada
	  FROM emipouni
	 WHERE no_poliza = '0003290281'
	 
	CALL sp_proe04(_no_poliza, _no_unidad, _suma_asegurada, '001') returning _error;

	--CALL ap_proe04(_no_poliza, _no_unidad, _suma_asegurada, '001') returning _error;
	
	if _error <> 0 then
		exit foreach;
	end if	      
END FOREACH

return 0; 
END PROCEDURE	  