-- Deducible

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf101;

--CREATE PROCEDURE sp_rwf10(a_cod_cliente CHAR(10))
CREATE PROCEDURE sp_rwf101(a_no_reclamo CHAR(10))
RETURNING CHAR(5), DEC(16,2);

DEFINE _cant           SMALLINT;
DEFINE v_cod_cobertura CHAR(5);
DEFINE v_deducible     DEC(16,2);

--set debug file to "sp_rwf02.trc";

LET v_deducible = 0.00;

SET ISOLATION TO DIRTY READ;

SELECT COUNT(*)
  INTO _cant
  FROM recrccob
 WHERE no_reclamo = a_no_reclamo
   AND deducible > 0.00;

IF _cant > 0 THEN
	FOREACH   
	    SELECT a.cod_cobertura,
			   a.deducible
		  INTO v_cod_cobertura,
			   v_deducible
		  FROM recrccob a, prdcober b
		 WHERE a.cod_cobertura = b.cod_cobertura
		   AND a.no_reclamo = a_no_reclamo
		   AND a.deducible > 0.00
		   AND b.nombre not like '%AJENA%'
		EXIT FOREACH;
	END FOREACH
ELSE
	FOREACH   
	    SELECT cod_cobertura,
			   deducible
		  INTO v_cod_cobertura,
			   v_deducible
		  FROM recrccob
		 WHERE no_reclamo = a_no_reclamo
		EXIT FOREACH;
	END FOREACH
END IF

IF v_deducible IS NULL THEN
	LET v_deducible = 0.00;
END IF

RETURN v_cod_cobertura, v_deducible;


--drop table tmp_polizas;

END PROCEDURE;