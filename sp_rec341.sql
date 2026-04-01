
-- Detalle de las unidades

-- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 23/05/2001 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - d_cheq_sp_rec34_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec341;

CREATE PROCEDURE sp_rec341(a_nopoliza CHAR(10),a_nounidad CHAR(5), fecha DATE)
RETURNING CHAR(5);	-- no_endoso

DEFINE v_noendoso  				CHAR(5);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec34.trc";
--TRACE ON;

-- UNIDADES ELIMINADAS DE ENDEDUNI

FOREACH

	 SELECT	y.no_endoso
	   INTO	v_noendoso
	   FROM	endedmae x, endeduni y 
	  WHERE x.no_poliza = a_nopoliza
	    AND y.no_poliza = x.no_poliza
		AND y.no_endoso = x.no_endoso
		AND y.no_unidad = a_nounidad
	    AND x.cod_endomov = '005'
	 	AND (x.vigencia_inic > fecha
		 OR (x.vigencia_inic <= fecha AND x.fecha_emision > fecha))

	RETURN v_noendoso
    	   WITH RESUME;

END FOREACH


END PROCEDURE;


