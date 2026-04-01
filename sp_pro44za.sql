-- Procedimiento para el resumen de Coberturas para Flota
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44za;
CREATE PROCEDURE "informix".sp_pro44za(a_poliza CHAR(10), a_endoso CHAR(5), a_descuento CHAR(16) DEFAULT "0.00", a_recargo CHAR(16) DEFAULT "0.00", a_impuesto CHAR(16) DEFAULT "0.00", a_prima_bruta CHAR(16) DEFAULT "0.00")
			RETURNING   SMALLINT,			 -- _orden
						CHAR(50),			 -- _nom_cobertura
						DEC(16,2),			 -- _prima
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2);			 

DEFINE v_cod_cobertura   CHAR(5);	

DEFINE _orden	         INT;
DEFINE _nom_cobertura    CHAR(50);
DEFINE _prima		     DEC(16,2);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

 SELECT X.cod_cobertura, SUM(X.prima) prima
   FROM endedcob X
  WHERE X.no_poliza = a_poliza
    AND X.no_endoso = a_endoso
 GROUP BY X.cod_cobertura
 INTO TEMP tmp1;

FOREACH	
    SELECT cod_cobertura, prima INTO v_cod_cobertura, _prima
      FROM tmp1


	SELECT MIN(X.orden)
	  INTO _orden
	  FROM tmp1 Z, endedcob X
	 WHERE Z.cod_cobertura = X.cod_cobertura
	   AND X.cod_cobertura = v_cod_cobertura
       AND X.no_poliza = a_poliza
       AND X.no_endoso = a_endoso;

    SELECT nombre INTO _nom_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN _orden,
		   _nom_cobertura, 
		   _prima,
		   a_descuento,
		   a_recargo,
		   a_impuesto,
		   a_prima_bruta
		   WITH RESUME; 
END FOREACH
DROP TABLE tmp1;
END
END PROCEDURE;