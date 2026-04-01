-- Numero Interno de Poliza de la ultima Vigencia anterior a la renovada
-- dado el Numero de Documento

-- Creado    : 17/04/2012 - Autor: HENRY GIRON
-- Modificado: 17/04/2012 - Autor: HENRY GIRON

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis398;
CREATE PROCEDURE "informix".sp_sis398(a_no_documento CHAR(20)) RETURNING CHAR(10);

DEFINE _no_poliza      CHAR(10);
DEFINE _vigencia_final DATE;
define _anterior       int;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
LET _anterior  = 0;

FOREACH
 SELECT	no_poliza,
	    vigencia_final
   INTO	_no_poliza,
	    _vigencia_final
   FROM	emipomae
  WHERE no_documento       = a_no_documento
	AND actualizado        = 1
  ORDER BY vigencia_final DESC
	if _anterior <> 0 then
		EXIT FOREACH;
	ELSE
		LET _anterior  = 1;
	END IF
END FOREACH

RETURN _no_poliza;

END PROCEDURE;