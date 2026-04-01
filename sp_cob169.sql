-- Procedimiento que asigna un numero de Remesa para los Pagos Externos

-- Creado    : 09/09/2004 - Autor: Armando Moreno
-- Modificado: 30/09/2004 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob169;

CREATE PROCEDURE "informix".sp_cob169(a_compania char(3)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      	INTEGER;
DEFINE _null            	CHAR(1);
DEFINE a_no_remesa      	CHAR(10);
DEFINE _fecha				DATE;

--SET DEBUG FILE TO "sp_cob169.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Pagos Externos', '';
END EXCEPTION

LET _null       = NULL;
LET a_no_remesa = '1';  

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');
let a_no_remesa = trim(a_no_remesa);

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF


RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa;

END 					 

END PROCEDURE;