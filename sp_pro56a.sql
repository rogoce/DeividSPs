-- Procedimiento para buscar los coaseguros
--
-- Creado    : 05/01/2001 - Autor: Amado Perez Mendoza 
-- Modificado: 05/01/2001 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro56a;

CREATE PROCEDURE "informix".sp_pro56a(a_poliza CHAR(10))
			RETURNING   CHAR(50),			 --	v_nombre_coas
						DEC(7,4);			 --	v_porc_coas
	
DEFINE v_nombre_coas CHAR(50);
DEFINE v_porc_coas   DEC(7,4); 
DEFINE _no_cambio    CHAR(3);

FOREACH
SELECT y.nombre, x.porc_partic_coas
  INTO v_nombre_coas, v_porc_coas
  FROM emicoama x, emicoase y
 WHERE y.cod_coasegur = x.cod_coasegur
   AND x.no_poliza = a_poliza
ORDER BY x.porc_partic_coas DESC

 RETURN  v_nombre_coas,
         v_porc_coas WITH RESUME;
END FOREACH

END PROCEDURE;
