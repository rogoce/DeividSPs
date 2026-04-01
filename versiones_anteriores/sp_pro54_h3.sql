-- Procedimiento para los calcular los descuentos de la poliza
--
-- Creado    : 15/12/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 15/12/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE hg_pro54;

CREATE PROCEDURE "informix".hg_pro54(a_poliza CHAR(10), a_unidad CHAR(5),a_general INT, a_endoso CHAR(5))
			RETURNING   CHAR(50),			 --	v_nombre
						DEC(16,2);			 --	v_descuento
	
DEFINE v_nombre  	   CHAR(50);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_descuen_sal   DEC(16,2);
DEFINE v_tmp           DEC(16,2);
DEFINE v_porcentaje    DEC(16,4);
DEFINE v_prima         DEC(16,2);
DEFINE v_prima_uni     DEC(16,2);
DEFINE v_orden         int;

DEFINE _contador       INT;
DEFINE _cod_producto   CHAR(5);
DEFINE _descuento_cob  DEC(16,2);
DEFINE _descuent_temp  DEC(16,2);
DEFINE _prima          DEC(16,2); 
DEFINE _cod_descuen    CHAR(3);
DEFINE _no_unidad      CHAR(5);
DEFINE _no_poliza      CHAR(10);
DEFINE _no_endoso      CHAR(5);
DEFINE _cod_cobertura  CHAR(5);

SET ISOLATION TO DIRTY READ;

LET v_nombre = '';
LET _contador = 1;
LET v_descuento = 0;
LET _descuento_cob = 0;
let v_tmp          = 0;

CREATE TEMP TABLE temp_unicob(
        no_poliza     CHAR(10),
        no_endoso     CHAR(5),
        no_unidad     CHAR(5),
		cod_cobertura CHAR(5),
        prima       DEC(16,2)
        ) WITH NO LOG;	  

-- SET DEBUG FILE TO "sp_pro54.trc";      
-- TRACE ON;                                                                     

IF a_general = 1 THEN
	SELECT SUM(prima) 
	  INTO v_prima
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

    FOREACH
	  SELECT y.prima, y.no_poliza,y.no_endoso,y.no_unidad, y.cod_cobertura, x.cod_producto 
	    INTO _prima, _no_poliza, _no_endoso, _no_unidad, _cod_cobertura, _cod_producto
	    FROM endeduni x, endedcob y, prdcobpd z
	   WHERE y.no_poliza = a_poliza
	     AND y.no_endoso = a_endoso
		 AND x.no_poliza = y.no_poliza
		 AND x.no_endoso = y.no_endoso
		 AND x.no_unidad = y.no_unidad
	     AND z.cod_producto = x.cod_producto  
	     AND z.cod_cobertura = y.cod_cobertura
		 AND z.acepta_desc = 1

      INSERT INTO  temp_unicob(
	  no_poliza,
	  no_endoso,
	  no_unidad,
	  cod_cobertura,
	  prima
	  )
	  VALUES(
	  _no_poliza,
	  _no_endoso,
	  _no_unidad,
	  _cod_cobertura,
	  _prima
	  );

	END FOREACH

	LET v_descuento = 0;


    FOREACH
		SELECT no_unidad, prima, cod_cobertura
		  INTO _no_unidad, _prima, _cod_cobertura
		  FROM temp_unicob
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso

        LET v_porcentaje = 0.00;

        LET v_porcentaje = sp_proe73(a_poliza, a_endoso, _no_unidad, _cod_cobertura);  

		LET _descuento_cob = _prima * v_porcentaje / 100;
		LET _prima = _prima -_descuento_cob;
		LET v_descuento = v_descuento + _descuento_cob;

		UPDATE temp_unicob
		   SET prima = _prima
		 WHERE no_poliza = a_poliza
	       AND no_endoso = a_endoso
		   AND no_unidad = _no_unidad
		   AND cod_cobertura = _cod_cobertura;

	END FOREACH


	FOREACH

		SELECT x.cod_descuen, y.nombre, y.orden
		  INTO _cod_descuen, v_nombre, v_orden
		  FROM endunide x, emidescu y
		 WHERE x.no_poliza = a_poliza
		   AND x.no_endoso = a_endoso
		   AND y.cod_descuen = x.cod_descuen
		GROUP BY x.cod_descuen, y.nombre, y.orden
 		ORDER BY y.orden

 		LET v_descuento = 0;

		FOREACH	

			SELECT x.porc_descuento, z.prima, z.cod_producto, z.no_unidad
			  INTO v_porcentaje, v_prima_uni, _cod_producto, _no_unidad
			  FROM endunide x, endeduni z
			 WHERE z.no_poliza = x.no_poliza
			   AND z.no_endoso = x.no_endoso
			   AND z.no_unidad = x.no_unidad
			   AND x.no_poliza = a_poliza
			   AND x.no_endoso = a_endoso
			   AND x.cod_descuen = _cod_descuen

				FOREACH	
				  SELECT prima, cod_cobertura
				    INTO _prima, _cod_cobertura
				    FROM temp_unicob
				   WHERE no_poliza = a_poliza
				   	 AND no_endoso = a_endoso
				   	 AND no_unidad = _no_unidad

    	  		  LET _descuento_cob = _prima * v_porcentaje / 100;
				  LET _prima = _prima -_descuento_cob;
				  LET v_descuento = v_descuento + _descuento_cob;

				UPDATE temp_unicob
				   SET prima = _prima
				 WHERE no_poliza = a_poliza
				   AND no_endoso = a_endoso
				   AND no_unidad = _no_unidad
				   AND cod_cobertura = _cod_cobertura;

				END FOREACH;

--			LET v_descuento = (v_prima_uni * v_porcentaje / 100) + v_descuento;

		END FOREACH;
		LET v_prima = v_prima - v_descuento;
		LET v_descuen_sal = v_descuento * -1; 
		RETURN
		    v_nombre,
			v_descuen_sal	WITH RESUME;
    END FOREACH

ELSE
	SELECT SUM(prima),sum(descuento) 
	  INTO v_prima,v_tmp
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad;

    FOREACH
	  SELECT y.prima, y.no_poliza,y.no_endoso,y.no_unidad, y.cod_cobertura 
	    INTO _prima, _no_poliza, _no_endoso, _no_unidad, _cod_cobertura
	    FROM endeduni x, endedcob y, prdcobpd z
	   WHERE y.no_poliza = a_poliza
	     AND y.no_endoso = a_endoso
		 AND y.no_unidad = a_unidad
		 AND x.no_poliza = y.no_poliza
		 AND x.no_endoso = y.no_endoso
		 AND x.no_unidad = y.no_unidad
	     AND z.cod_producto = x.cod_producto
	     AND z.cod_cobertura = y.cod_cobertura
		 AND z.acepta_desc = 1

      INSERT INTO  temp_unicob(
	  no_poliza,
	  no_endoso,
	  no_unidad,
	  cod_cobertura,
	  prima
	  )
	  VALUES(
	  _no_poliza,
	  _no_endoso,
	  _no_unidad,
	  _cod_cobertura,
	  _prima
	  );

	END FOREACH

{    FOREACH
		SELECT no_unidad, prima, cod_cobertura
		  INTO _no_unidad, _prima, _cod_cobertura
		  FROM temp_unicob
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso

        LET v_porcentaje = 0.00;

        LET v_porcentaje = sp_proe73(a_poliza, a_endoso, _no_unidad, _cod_cobertura);  

		LET _descuento_cob = _prima * v_porcentaje / 100;
		LET _prima = _prima -_descuento_cob;
		LET v_descuento = v_descuento + _descuento_cob;

		UPDATE temp_unicob
		   SET prima = _prima
		 WHERE no_poliza = a_poliza
	       AND no_endoso = a_endoso
		   AND no_unidad = _no_unidad
		   AND cod_cobertura = _cod_cobertura;

	END FOREACH	--}


	FOREACH
		SELECT y.orden, y.nombre, x.porc_descuento
		  INTO v_orden, v_nombre, v_porcentaje
		  FROM endunide x, emidescu y
		 WHERE y.cod_descuen = x.cod_descuen
		   AND x.no_poliza = a_poliza
		   AND x.no_unidad = a_unidad
		   AND x.no_endoso = a_endoso
		 ORDER BY y.orden

		LET v_descuento = 0;

		FOREACH

		  SELECT prima, cod_cobertura
		    INTO _prima, _cod_cobertura
		    FROM temp_unicob
		   WHERE no_poliza = a_poliza
		   	 AND no_endoso = a_endoso
		   	 AND no_unidad = a_unidad

  		  LET _descuento_cob = ROUND((_prima * v_porcentaje / 100),2);
		  LET _prima = _prima -_descuento_cob;
		  LET v_descuento = v_descuento + _descuento_cob;

		  UPDATE temp_unicob
		     SET prima = _prima
		   WHERE no_poliza = a_poliza
		     AND no_endoso = a_endoso
		     AND no_unidad = a_unidad
		     AND cod_cobertura = _cod_cobertura;

	END FOREACH;

--		LET v_descuento = v_prima * v_porcentaje / 100;
		LET v_prima = v_prima - v_descuento;
		LET v_descuen_sal = v_descuento * -1; 
		let v_tmp = v_tmp * -1;

		RETURN 
		    v_nombre,
			v_descuen_sal WITH RESUME;

	END FOREACH;
END IF

DROP TABLE temp_unicob;

END PROCEDURE