-- Procedimiento para los calcular los descuentos de la poliza
--
-- Creado    : 15/12/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 15/12/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro54;

CREATE PROCEDURE "informix".sp_pro54(a_poliza CHAR(10), a_unidad CHAR(5),a_general INT, a_endoso CHAR(5))
			RETURNING   CHAR(50),			 --	v_nombre
						DEC(16,2);			 --	v_descuento
	
DEFINE v_nombre  	   CHAR(50);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_porcentaje    DEC(16,4);
DEFINE v_prima         DEC(16,2);
DEFINE v_orden         int;

DEFINE _contador       INT;
DEFINE _cod_producto   CHAR(5);
DEFINE _cod_cobertura  CHAR(5);
DEFINE _acepta_desc    SMALLINT; 
DEFINE _descuento      DEC(16,2);
DEFINE _prima          DEC(16,2); 

SET ISOLATION TO DIRTY READ;

LET _contador = 1;
LET v_descuento = 0;

CREATE TEMP TABLE tmpcober(
        cod_cobertura CHAR(5),
	    prima         DEC(16,2)
	    ) WITH NO LOG;

FOREACH	   
	SELECT cod_cobertura,
	       prima
	  INTO _cod_cobertura,
	       _prima
	  FROM endedcob
	 WHERE no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad

	 INSERT INTO tmpcober(
	 cod_cobertura,
	 prima
	 )
	 VALUES(
	 _cod_cobertura,
	 _prima
	 );
END FOREACH


IF a_general = 1 THEN
	SELECT SUM(prima) 
	  INTO v_prima
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

	FOREACH	

		SELECT y.orden,y.nombre, x.porc_descuento
		  INTO v_orden,v_nombre, v_porcentaje
		  FROM endeddes x, emidescu y
		 WHERE y.cod_descuen = x.cod_descuen
		   AND x.no_poliza = a_poliza
		   AND x.no_endoso = a_endoso
		 ORDER BY y.orden

		LET v_descuento = v_prima * v_porcentaje / 100;
		LET v_prima = v_prima - v_descuento;
		LET v_descuento = v_descuento * -1; 
		RETURN
		    v_nombre,
			v_descuento WITH RESUME;

		
	END FOREACH;

ELSE
 	SELECT cod_producto,
	       prima
	  INTO _cod_producto,
	       v_prima
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

		 LET v_descuento = 0;
		 FOREACH
		 	SELECT cod_cobertura
		 	  INTO _cod_cobertura
		 	  FROM endedcob
			 WHERE no_poliza = a_poliza
			   and no_endoso = a_endoso
			   and no_unidad = a_unidad

            SELECT acepta_desc
              INTO _acepta_desc
			  FROM prdcobpd
             WHERE cod_producto = _cod_producto
               AND cod_cobertura = _cod_cobertura;

            SELECT prima
			  INTO _prima
			  FROM tmpcober
			 WHERE cod_cobertura = _cod_cobertura;
            
            IF _acepta_desc = 1 THEN
			   LET _descuento = _prima * v_porcentaje / 100;
			   LET _prima = _prima - _descuento;
			   UPDATE tmpcober SET prima = _prima WHERE cod_cobertura = _cod_cobertura;
			ELSE
			   LET _descuento = 0;
			END IF   

			LET v_descuento = v_descuento + _descuento;


         END FOREACH;

--		LET v_descuento = v_prima * v_porcentaje / 100;
--		LET v_prima = v_prima - v_descuento;
		LET v_descuento = v_descuento * -1; 

		RETURN 
		    v_nombre,
			v_descuento WITH RESUME;
		
	END FOREACH;
END IF

DROP TABLE tmpcober;

END PROCEDURE
