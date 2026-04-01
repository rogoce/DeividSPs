-- Numero Interno de Poliza de la ultima Vigencia dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis21a;

CREATE PROCEDURE "informix".sp_sis21a(a_no_documento CHAR(20), a_no_poliza char(10)) RETURNING CHAR(10);

DEFINE _no_poliza      CHAR(10);
DEFINE _vigencia_final DATE;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;

FOREACH
 SELECT	no_poliza,
	    vigencia_final
   INTO	_no_poliza,
	    _vigencia_final
   FROM	emipomae
  WHERE no_documento       = a_no_documento
	AND actualizado        = 1
	and no_poliza <> a_no_poliza
  ORDER BY vigencia_final DESC
	EXIT FOREACH;
END FOREACH

RETURN _no_poliza;

END PROCEDURE;