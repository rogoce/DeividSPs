-- Busca proxima libreta disponible

-- Creado    : 14/08/2003 - Autor: Amado Perez 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob123;

CREATE PROCEDURE "informix".sp_cob123(a_automatico SMALLINT) RETURNING CHAR(3), CHAR(50);

DEFINE _cod_cobrador  CHAR(3); 
DEFINE _nombre        CHAR(50);

SET ISOLATION TO DIRTY READ;

IF a_automatico = 0 THEN
	FOREACH	WITH HOLD
	 SELECT	cod_cobrador,
	        nombre
	   INTO	_cod_cobrador,
	        _nombre
	   FROM	cobcobra
	  WHERE activo = 1
	  ORDER BY cod_cobrador ASC

	 RETURN _cod_cobrador,
	        _nombre
	   WITH RESUME;

	END FOREACH
ELSE
	FOREACH	WITH HOLD
	 SELECT	cod_cobrador,
	        nombre
	   INTO	_cod_cobrador,
	        _nombre
	   FROM	cobcobra
	  WHERE activo         = 1
		AND tipo_cobrador  in (2,3)
   ORDER BY cod_cobrador ASC

	 RETURN _cod_cobrador,
	        _nombre
	   WITH RESUME;

	END FOREACH
END IF
END PROCEDURE;
