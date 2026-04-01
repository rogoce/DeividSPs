-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf132;
CREATE PROCEDURE "informix".sp_rwf132(a_reclamo CHAR(10), a_poliza CHAR(10), a_unidad CHAR(5))
returning char(5),
		  varchar(50),
		  varchar(50);

define v_no_orden	   	char(5);
define v_desc_orden	   	varchar(50);
define v_deducible	   	varchar(50);
define _cant            SMALLINT;
define _no_endoso	   	char(5);

set isolation to dirty read;
--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;


SELECT COUNT(*) 
  INTO _cant
  FROM emipouni
 WHERE no_poliza = a_poliza
   AND no_unidad = a_unidad;

IF _cant > 0 THEN
	FOREACH
		SELECT cod_cobertura, deducible
		  INTO v_no_orden, v_deducible
		  FROM emipocob
		 WHERE no_poliza = a_poliza
		   AND no_unidad = a_unidad
		   AND cod_cobertura not in (select cod_cobertura from recrccob where no_reclamo = a_reclamo)
	  ORDER BY cod_cobertura

		SELECT nombre
		  INTO v_desc_orden
		  FROM prdcober
		 WHERE cod_cobertura = v_no_orden; 
		
			  
			RETURN v_no_orden,
				   v_desc_orden,
				   v_deducible with resume;
	END FOREACH
ELSE  --> Si no existe en emipouni es porque fue eliminada a traves de un endoso
	FOREACH
		SELECT no_endoso
		  INTO _no_endoso
		  FROM endeduni
		 WHERE no_poliza = a_poliza
		   AND no_unidad = a_unidad
	  ORDER	BY 1 DESC
	  EXIT FOREACH;
	END FOREACH

	FOREACH
		SELECT cod_cobertura, deducible
		  INTO v_no_orden, v_deducible
		  FROM endedcob
		 WHERE no_poliza = a_poliza
		   AND no_unidad = a_unidad
		   AND no_endoso = _no_endoso
		   AND cod_cobertura not in (select cod_cobertura from recrccob where no_reclamo = a_reclamo)
	  ORDER BY cod_cobertura

		SELECT nombre
		  INTO v_desc_orden
		  FROM prdcober
		 WHERE cod_cobertura = v_no_orden; 
		
			  
			RETURN v_no_orden,
				   v_desc_orden,
				   v_deducible with resume;
	END FOREACH

END IF
end procedure