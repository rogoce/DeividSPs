-- Procedimiento para actualizar descripcion de limites de emipocob
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_limcob;
CREATE PROCEDURE "informix".sp_limcob(a_poliza CHAR(10), a_unidad CHAR(5))
			RETURNING   INTEGER;			 -- _error

DEFINE _error  						INTEGER;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

IF ls_unidad IS NULL THEN
   LET ls_unidad = '*';
END IF

FOREACH
  SELECT emipouni.no_unidad, emipouni.cod_producto
    INTO ls_unidad, ls_producto
    FROM emipouni  
   WHERE emipouni.no_poliza = a_poliza
     AND emipouni.no_unidad MATCHES a_unidad 
  ORDER BY emipouni.no_unidad

  SELECT prdcobpd.desc_limite1, prdcobpd.desc_limite2
    INTO ls_des1, ls_des2
	FROM emipocob, prdcobpd
   WHERE emipocob.no_poliza = a_poliza
     AND emipocob.no_unidad = ls_unidad
	 AND prdcobpd.cod_producto = ls_producto
	 AND prdcobpd.cod_cobertura = emipocob.cod_cobertura;

  UPDATE emipocob
     SET desc_limite1 = ls_des1,
	     desc_limite2 = ls_des2
   WHERE emipocob.no_poliza = a_poliza
     AND emipocob.no_unidad = ls_unidad;

END FOREACH

RETURN 0;
END
END PROCEDURE;