-- Procedimiento para el resumen de Coberturas para Flota
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web17;
CREATE PROCEDURE "informix".sp_web17(a_poliza CHAR(10))
			RETURNING   CHAR(5),			 -- v_cod_producto
						CHAR(5),             -- v_cod_cobertura
						SMALLINT,			 -- _orden
						CHAR(50),			 -- _nom_cobertura
						CHAR(100),			 -- _desc_limite1
						CHAR(100),			 -- _desc_limite2
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

drop table if exists tmp_cober_web;
drop table if exists tmp1;

CREATE TEMP TABLE tmp_cober_web
           (cod_producto        CHAR(5),
		    cod_cobertura       CHAR(5),
			orden               smallint,
			nom_cobertura       CHAR(50),
			desc_limite1        CHAR(100),  
			desc_limite2        CHAR(100), 			
			prima               DEC(16,2),
        PRIMARY KEY(cod_producto, cod_cobertura,orden)) WITH NO LOG;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;   
                                                                  
let v_cod_producto = "";

SELECT X.cod_cobertura, SUM(X.prima) prima
  FROM emipocob X
  INNER JOIN emipouni A on A.no_poliza = X.no_poliza
 WHERE X.no_poliza = a_poliza
 AND A.no_unidad = X.no_unidad
 AND A.activo = 1
GROUP BY X.cod_cobertura
INTO TEMP tmp1;

{
SELECT X.cod_cobertura, SUM(X.prima) prima
  FROM emipocob X
 WHERE X.no_poliza = a_poliza
GROUP BY X.cod_cobertura
INTO TEMP tmp1;
}

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

	   --	LET _desc_limite = TRIM(v_desc_limite1) || ' ' || TRIM(v_desc_limite2);

	    SELECT nombre INTO _nom_cobertura
		  FROM prdcober
		 WHERE cod_cobertura = v_cod_cobertura;

		 
		INSERT INTO tmp_cober_web (cod_producto, cod_cobertura, orden,	nom_cobertura, desc_limite1, desc_limite2, prima)
		VALUES (v_cod_producto,	v_cod_cobertura, _orden, _nom_cobertura, v_desc_limite1, v_desc_limite2, _prima); 
		
	END FOREACH
END FOREACH

FOREACH	
	    SELECT cod_producto, cod_cobertura, orden,	nom_cobertura, desc_limite1, desc_limite2, prima
	      INTO v_cod_producto,	v_cod_cobertura, _orden, _nom_cobertura, v_desc_limite1, v_desc_limite2, _prima
	      FROM tmp_cober_web
		  group by 1,2,3,4,5,6,7
		  
		RETURN v_cod_producto,
				v_cod_cobertura,
			   _orden,
			   _nom_cobertura,
			   v_desc_limite1,
			   v_desc_limite2,
			   _prima
			   WITH RESUME; 
end foreach

DROP TABLE tmp1;
DROP TABLE tmp_cober_web;
END
END PROCEDURE 