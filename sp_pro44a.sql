-- Procedimiento para el resumen de Coberturas para Flota
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--  Modificado: 05/01/2014 - Autor: Enocjahaziel C.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44a;
CREATE PROCEDURE "informix".sp_pro44a(a_poliza CHAR(10), a_endoso CHAR(5))
			RETURNING   SMALLINT,			 -- _orden
						CHAR(50),			 -- _nom_cobertura
						DEC(16,2);			 -- _prima

DEFINE v_cod_cobertura   CHAR(5);	

DEFINE _orden	         INT;
DEFINE _nom_cobertura    CHAR(50);
DEFINE _prima		     DEC(16,2);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

 SELECT x.no_unidad,X.orden, X.cod_cobertura, SUM(X.prima) prima
   FROM endedcob X
  WHERE X.no_poliza = a_poliza
    AND X.no_endoso = a_endoso
 GROUP BY x.no_unidad,X.cod_cobertura, X.orden  order by x.no_unidad,X.cod_cobertura, X.orden
 INTO TEMP tmp1;

FOREACH	
    SELECT cod_cobertura, prima , orden  INTO v_cod_cobertura, _prima, _orden 
      FROM tmp1 order by no_unidad,cod_cobertura,orden

	/*SELECT MIN(X.orden)
	  INTO _orden
	  FROM tmp1 Z, endedcob X 
	 WHERE Z.cod_cobertura = X.cod_cobertura
	   AND X.cod_cobertura = v_cod_cobertura
       AND X.no_poliza = a_poliza
       AND X.no_endoso = a_endoso ;*/

    SELECT nombre INTO _nom_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN _orden,
		   _nom_cobertura, 
		   _prima
		   WITH RESUME; 
END FOREACH
DROP TABLE tmp1;
END
END PROCEDURE;