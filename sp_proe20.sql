-- Procedimiento Verificar que no hay Valores con orden igual a cero en Coberturas
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe20;
CREATE PROCEDURE "informix".sp_proe20(a_poliza CHAR(10), a_endoso INTEGER)
			RETURNING   SMALLINT,			 -- _error
						CHAR(10)			 -- ls_unidad

DEFINE ls_unidad   	CHAR(10);
DEFINE _error		INTEGER;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     
LET ls_unidad = NULL;
IF a_endoso IS NULL THEN
	FOREACH	
		SELECT no_unidad
		  INTO ls_unidad
		  FROM emipocob
		 WHERE no_poliza = a_poliza
		   AND orden  = 0
		GROUP BY no_unidad
		ORDER BY no_unidad

		IF ls_unidad IS NOT NULL THEN
			RETURN 1, ls_unidad;
		END IF
	END FOREACH
ELSE
	FOREACH	
		SELECT no_unidad
		  INTO ls_unidad
		  FROM endedcob
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso
		   AND orden  = 0
		GROUP BY no_unidad
		ORDER BY no_unidad

		IF ls_unidad IS NOT NULL THEN
			RETURN 1, ls_unidad;
		END IF
	END FOREACH
END IF
RETURN 0, ls_unidad;
END
END PROCEDURE;