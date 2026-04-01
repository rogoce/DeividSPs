-- Procedimiento para el resumen de Coberturas para Flota
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web56;
CREATE PROCEDURE "informix".sp_web56(a_poliza CHAR(10))
			RETURNING   CHAR(5),			 -- v_cod_producto
						SMALLINT,			 -- _orden
						CHAR(50),			 -- _nom_cobertura
						CHAR(100),			 -- _desc_limite1
						DEC(16,2);			 -- _prima

DEFINE v_cod_cobertura   CHAR(5);	

DEFINE _orden	         INT;
DEFINE _nom_cobertura    CHAR(50);
DEFINE _desc_limite		 CHAR(100);
--DEFINE _desc_limite2	 CHAR(50);
DEFINE _prima		     DEC(16,2);
DEFINE v_desc_limite1	 CHAR(50);
DEFINE v_desc_limite2	 CHAR(50);
DEFINE v_cod_producto    CHAR(5);


BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

SELECT X.cod_cobertura, SUM(X.prima) prima
  FROM emipocob X
  INNER JOIN emipouni A on A.no_poliza = X.no_poliza
 WHERE X.no_poliza = a_poliza
 AND A.no_unidad = X.no_unidad
 AND A.activo = 1
GROUP BY X.cod_cobertura
INTO TEMP tmp1;

FOREACH	
	SELECT cod_producto INTO v_cod_producto
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	GROUP BY cod_producto
	ORDER BY cod_producto

	FOREACH	
	    SELECT tmp1.cod_cobertura, tmp1.prima, prdcobpd.desc_limite1, prdcobpd.desc_limite2
	      INTO v_cod_cobertura, _prima, v_desc_limite1, v_desc_limite2
	      FROM tmp1, prdcobpd
		 WHERE prdcobpd.cod_producto  = v_cod_producto
		   AND prdcobpd.cod_cobertura = tmp1.cod_cobertura
		   order by orden

		SELECT MIN(X.orden)
		  INTO _orden
		  FROM tmp1 Z, emipocob X
		 WHERE Z.cod_cobertura = X.cod_cobertura
		   AND X.cod_cobertura = v_cod_cobertura
	       AND X.no_poliza = a_poliza;

		IF v_desc_limite1 IS NULL THEN
		   LET v_desc_limite1 = ' ';
		END IF

		IF v_desc_limite2 IS NULL THEN
		   LET v_desc_limite2 = ' ';
		END IF

	   	LET _desc_limite = TRIM(v_desc_limite1) || ' ' || TRIM(v_desc_limite2);

	    SELECT nombre INTO _nom_cobertura
		  FROM prdcober
		 WHERE cod_cobertura = v_cod_cobertura;

		if v_cod_cobertura = '01238' then --Cobertura de uso interno, No debe salir en la factura.
			continue foreach;
		end if

		RETURN v_cod_producto,
			   _orden,
			   _nom_cobertura,
			   _desc_limite,
			   _prima
			   WITH RESUME; 
	END FOREACH
END FOREACH
DROP TABLE tmp1;
END
END PROCEDURE;