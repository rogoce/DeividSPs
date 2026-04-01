-- Numero Interno de Poliza de la ultima Vigencia
-- dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro572c;

CREATE PROCEDURE "informix".sp_pro572c(a_no_documento CHAR(20)) RETURNING CHAR(10);

DEFINE _no_poliza		CHAR(10);
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;

FOREACH
	select no_poliza,
		   vigencia_inic
	  into _no_poliza,
		   _vigencia_inic
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	   and vigencia_inic <= date(current)
	   and vigencia_final >= date(current)
	 order by vigencia_final desc

	exit foreach;
END FOREACH

RETURN _no_poliza;

END PROCEDURE;