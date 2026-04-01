-- Procedimiento para buscar los acreedores
--
-- Creado    : 25/05/2001 - Autor: Amado Perez M.
-- Modificado: 25/05/2001 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44c;
CREATE PROCEDURE "informix".sp_pro44c(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5))
			RETURNING   CHAR(50),			 -- _nom_acreedor
						DEC(16,2);			 -- _limite

DEFINE _cod_acreedor     CHAR(5);	

DEFINE _nom_acreedor     CHAR(50);
DEFINE _limite		     DEC(16,2);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;         
--CREATE TABLE tmp_table
LET _cod_acreedor = null;
                                                            
foreach
 SELECT X.cod_acreedor, X.limite
   INTO	_cod_acreedor, _limite
   FROM endedacr X
  WHERE X.no_poliza = a_poliza
    AND X.no_endoso = a_endoso
	AND X.no_unidad = a_unidad

 IF  _cod_acreedor IS NULL OR _cod_acreedor = "" THEN
   FOREACH
	 SELECT X.cod_acreedor, X.limite
	   INTO	_cod_acreedor, _limite
	   FROM emipoacr X
	  WHERE X.no_poliza = a_poliza
		AND X.no_unidad = a_unidad

	 SELECT nombre 
	   INTO _nom_acreedor
	   FROM emiacre
	  WHERE cod_acreedor = _cod_acreedor;

		RETURN _nom_acreedor, 
			   _limite
			   WITH RESUME; 
					
   END FOREACH
 END IF

 SELECT nombre 
   INTO _nom_acreedor
   FROM emiacre
  WHERE cod_acreedor = _cod_acreedor;

	RETURN _nom_acreedor, 
		   _limite
		   WITH RESUME; 
end foreach

 IF  _cod_acreedor IS NULL OR _cod_acreedor = "" THEN
   FOREACH
	 SELECT X.cod_acreedor, X.limite
	   INTO	_cod_acreedor, _limite
	   FROM emipoacr X
	  WHERE X.no_poliza = a_poliza
		AND X.no_unidad = a_unidad

	 SELECT nombre 
	   INTO _nom_acreedor
	   FROM emiacre
	  WHERE cod_acreedor = _cod_acreedor;

		RETURN _nom_acreedor, 
			   _limite
			   WITH RESUME; 
					
   END FOREACH
 END IF


END
END PROCEDURE;