-- No cheque y  remesa para el Informe de Estatus del Reclamo
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Modificado: 13/14/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_re40e;

CREATE PROCEDURE "informix".sp_re40e(
a_compania     CHAR(3),
a_sucursal     CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(10);
		  	  		         
DEFINE _no_remesa           CHAR(10);

FOREACH
  SELECT no_remesa
  	INTO _no_remesa
	FROM cobredet
   WHERE actualizado = 1
     AND doc_remesa = a_numrecla
group by no_remesa
order by no_remesa
 
   RETURN _no_remesa WITH RESUME;
   
END FOREACH;
END PROCEDURE;