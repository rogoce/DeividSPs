-- Procedimiento para los calcular los descuentos de la poliza
--
-- Creado    : 15/12/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 15/12/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro54a;

CREATE PROCEDURE "informix".sp_pro54a(a_poliza CHAR(10), a_unidad CHAR(5),a_general INT, a_endoso CHAR(5))
			RETURNING   CHAR(50),			 --	v_nombre
						DEC(16,2);			 --	v_descuento
	
DEFINE v_nombre  	   CHAR(50);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_porcentaje    DEC(16,4);
DEFINE v_prima         DEC(16,2);
DEFINE v_prima_uni     DEC(16,2);
DEFINE v_orden         int;

DEFINE _contador       INT;
DEFINE _cod_producto   CHAR(5);
DEFINE _descuento_cob  DEC(16,2);
DEFINE _descuent_temp  DEC(16,2);
DEFINE _prima          DEC(16,2);  

SET ISOLATION TO DIRTY READ;

LET v_nombre = '';
LET _contador = 1;
LET v_descuento = 0;
LET _descuento_cob = 0;

--SET DEBUG FILE TO "sp_pro54.trc"; 
--trace on;


IF a_general = 1 THEN
	SELECT SUM(prima) 
	  INTO v_prima
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

	FOREACH	

		SELECT y.orden,y.nombre, x.porc_descuento, sum(z.prima)
		  INTO v_orden,v_nombre, v_porcentaje, v_prima_uni
		  FROM endunide x, emidescu y, endeduni z
		 WHERE y.cod_descuen = x.cod_descuen
		   AND z.no_poliza = x.no_poliza
		   AND z.no_endoso = x.no_endoso
		   AND z.no_unidad = x.no_unidad
		   AND x.no_poliza = a_poliza
		   AND x.no_endoso = a_endoso
		 GROUP BY y.orden
		 ORDER BY y.orden
		LET v_descuento = (v_prima_uni * v_porcentaje / 100) + v_descuento;
		
	END FOREACH
	LET v_prima = v_prima - v_descuento;
	LET v_descuento = v_descuento * -1; 
	RETURN
	    v_nombre,
		v_descuento	WITH RESUME;

ELSE
	SELECT SUM(prima) 
	  INTO v_prima
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad;

	SELECT cod_producto 
	  INTO _cod_producto
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad;

	FOREACH	

		SELECT y.orden,y.nombre, x.porc_descuento
		  INTO v_orden,v_nombre, v_porcentaje
		  FROM endunide x, emidescu y
		 WHERE y.cod_descuen = x.cod_descuen
		   AND x.no_poliza = a_poliza
		   AND x.no_unidad = a_unidad
		   AND x.no_endoso = a_endoso
		 ORDER BY y.orden

		FOREACH		
		  SELECT y.prima
		    INTO _prima
		    FROM endedcob y, prdcobpd z
		   WHERE y.no_poliza = a_poliza
		     AND y.no_unidad = a_unidad
		     AND y.no_endoso = a_endoso
		     AND z.cod_producto = _cod_producto  
		     AND z.cod_cobertura = y.cod_cobertura
			 AND z.acepta_desc = 1

  		  LET _descuento_cob = (ROUND(_prima,2) * v_porcentaje / 100);
		  LET v_descuento = v_descuento + _descuento_cob;

		END FOREACH;

--		LET v_descuento = v_prima * v_porcentaje / 100;
		LET v_prima = v_prima - v_descuento;
		LET v_descuento = v_descuento * -1; 
		RETURN 
		    v_nombre,
			v_descuento WITH RESUME;

		
	END FOREACH;
END IF

END PROCEDURE
