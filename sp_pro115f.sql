-- Procedure que genera los datos para los carnets de auto y salud
DROP PROCEDURE sp_pro115f;

CREATE PROCEDURE "informix".sp_pro115f(a_fecha1 DATE, a_fecha2 DATE)
  RETURNING INTEGER,  
   			CHAR(10);

  DEFINE v_retorno			CHAR(10);
  DEFINE v_error, _contador INTEGER;
  DEFINE _no_documento  	CHAR(20);
  DEFINE _nombre, _nombre_par, _conyuge, _hijo1, _hijo2, _hijo3, _hijo4  CHAR(100);
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal, _cod_parentesco CHAR(3);
  DEFINE _vigencia_inic DATE;
  DEFINE _no_unidad     CHAR(5);
  DEFINE _cant, _impreso  SMALLINT;
  DEFINE _limite_1, _limite_2, _no_poliza CHAR(10);
  DEFINE _campo_documento  CHAR(20);
  DEFINE _cod_ramo, _cod_subramo CHAR(3);
  DEFINE _cod_asegurado CHAR(10);
  DEFINE _plan			CHAR(50);
  DEFINE _beneficio1	CHAR(65);
  DEFINE _beneficio2	CHAR(65);
  DEFINE _beneficio3	CHAR(65);
  DEFINE _beneficio4	CHAR(65);
  DEFINE _beneficio5	CHAR(65);
  DEFINE _hijo5, _hijo6, _hijo7, _hijo8 CHAR(50);

  SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro115.trc"; 
--trace on;
DELETE FROM fox_carnets WHERE impreso = 1;
DELETE FROM fox_salud WHERE impreso = 1;

LET v_retorno = 'ERROR';
LET _nombre_par = '';
LET _conyuge = '';
LET _hijo1 = '';
LET _hijo2 = '';
LET _hijo3 = '';
LET _hijo4 = '';
LET _hijo5 = '';
LET _hijo6 = '';
LET _hijo7 = '';
LET _hijo8 = '';

FOREACH
	SELECT x.no_documento,
	       y.nombre,
	       t.placa,
	       u.no_motor,
	       x.cod_sucursal 
	  INTO _no_documento,
	       _nombre,
	       _placa,
	       _no_motor,
	       _cod_sucursal
	  FROM emivehic t, endmoaut u, endedmae v, emipomae x, cliclien y, emiauto z 
	 WHERE x.no_poliza = v.no_poliza  
	   AND x.estatus_poliza = 1 
	   AND u.no_poliza = v.no_poliza
	   AND u.no_endoso = v.no_endoso 
	   AND y.cod_cliente = x.cod_contratante
	   AND (v.cod_endomov = '004' OR (v.cod_endomov = '011' AND x.nueva_renov = 'N'))  
	   AND z.no_motor =  u.no_motor 
	   AND z.no_poliza = v.no_poliza 
	   AND z.uso_auto = 'P'
	   AND x.sucursal_origen NOT IN ('051','023','056','047') 
	   AND t.no_motor = u.no_motor 
	   AND x.cod_ramo = '002' 
	   AND (x.cod_subramo = '001' or  x.cod_subramo = '012')
	   AND v.fecha_emision >= a_fecha1   
	   AND v.fecha_emision <= a_fecha2 
	   AND x.actualizado = 1

	BEGIN
		ON EXCEPTION SET v_error
		 --	RETURN v_error,
		 --	       trim(_no_documento); 
		END EXCEPTION
	  	INSERT INTO fox_carnets(
		   nomcli,
		   polifact,
		   sucpoli,
		   placa,
		   num_moto
		   )
	  	   VALUES(
	  	   _nombre,
	  	   _no_documento,
	  	   _cod_sucursal,
	  	   _placa,
	  	   _no_motor
	  	   );

		BEGIN
			ON EXCEPTION IN(-239,-268)
			 LET _impreso = 0;
			 SELECT impreso
			   INTO _impreso
			   FROM fox_hechos
			  WHERE polifact = _no_documento
			    AND num_moto = _no_motor;
			 
			 UPDATE fox_carnets
			    SET impreso = _impreso
			  WHERE polifact = _no_documento
			    AND num_moto = _no_motor;
			END EXCEPTION
		  	INSERT INTO fox_hechos(
			   nomcli,
			   polifact,
			   sucpoli,
			   placa,
			   num_moto
			   )
		  	   VALUES(
		  	   _nombre,
		  	   _no_documento,
		  	   _cod_sucursal,
		  	   _placa,
		  	   _no_motor
		  	   );
		END
	END

END FOREACH

-- Panama 1, Panama 2, Global, Colectivo Especial, Especial

FOREACH
	SELECT x.no_documento,
	       y.nombre,
	       v.vigencia_inic,
	       v.no_unidad,
	       x.no_poliza,
		   z.cod_carnet,
		   z.plan,
		   z.beneficio1,
		   z.beneficio2,
		   z.beneficio3,
		   z.beneficio4,
		   z.beneficio5
	  INTO _no_documento,
	       _nombre,
		   _vigencia_inic,
		   _no_unidad,
		   _no_poliza,
		   _cod_subramo,
		   _plan,
		   _beneficio1,
		   _beneficio2,
		   _beneficio3,
		   _beneficio4,
		   _beneficio5
 	  FROM emipouni v, emipomae x, cliclien y, prdprod z, emicarnet u
	 WHERE v.no_poliza = x.no_poliza 
	   AND v.activo = 1 
       AND y.cod_cliente = v.cod_asegurado 
       AND x.actualizado = 1  
       AND x.cod_ramo = '018' 
	   AND z.cod_producto = v.cod_producto
       AND u.cod_carnet = z.cod_carnet
       AND ((x.fecha_suscripcion >= a_fecha1 
       AND x.fecha_suscripcion <= a_fecha2)
	    OR (v.fecha_emision >= a_fecha1
	   AND v.fecha_emision <= a_fecha1))

	LET _cant = 0;

	LET _limite_1 = '';
	LET _limite_2 = '';
	LET _nombre_par = '';
	LET _conyuge = '';
	LET _hijo1 = '';
	LET _hijo2 = '';
	LET _hijo3 = '';
	LET _hijo4 = '';
	LET _hijo5 = '';
	LET _hijo6 = '';
	LET _hijo7 = '';
	LET _hijo8 = '';

	IF _cod_subramo = '009' OR _cod_subramo = '013' THEN
		SELECT limite_1,  
		       limite_2 
		  INTO _limite_1,
		       _limite_2
		  FROM emipocob  
		 WHERE no_poliza = _no_poliza 
		   AND no_unidad = _no_unidad
	       AND cod_cobertura = '00570';
	END IF

	FOREACH
		SELECT x.nombre, 
		       y.cod_parentesco 
		  INTO _nombre_par,
			   _cod_parentesco
		  FROM cliclien x, emidepen y 
		 WHERE x.cod_cliente = y.cod_cliente
           AND y.no_poliza = _no_poliza 
           AND y.no_unidad = _no_unidad
		   AND y.activo = 1

		   IF _cod_parentesco = '001' THEN
			  LET _conyuge	=  _nombre_par;
		   ELSE
			  LET _cant = _cant + 1;
			  IF _cant = 1 THEN
			     LET _hijo1 = _nombre_par;
			  ELIF _cant = 2 THEN
			     LET _hijo2 = _nombre_par;
			  ELIF _cant = 3 THEN
			     LET _hijo3 = _nombre_par;
			  ELIF _cant = 4 THEN
			     LET _hijo4 = _nombre_par;
			  ELIF _cant = 5 THEN
			     LET _hijo5 = _nombre_par;
			  ELIF _cant = 6 THEN
			     LET _hijo6 = _nombre_par;
			  ELIF _cant = 7 THEN
			     LET _hijo7 = _nombre_par;
			  ELIF _cant = 8 THEN
			     LET _hijo8 = _nombre_par;
			  END IF
		   END IF

	END FOREACH

	BEGIN
		ON EXCEPTION SET v_error
			IF 	v_error <> -268 AND v_error <> -239 THEN
			   UPDATE fox_salud
			      SET poliza = _no_documento,
					  efectiva = _vigencia_inic,
					  asegurado = _nombre,
					  conyuge = _conyuge,
					  hijo1 = _hijo1,
					  hijo2 = _hijo2,
					  hijo3 = _hijo3,
					  hijo4 = _hijo4,
					  limite1 = _limite_1,
					  limite2 = _limite_2,
					  unidad = _no_unidad,
					  cod_subramo = _cod_subramo,
					  impreso = 0,
					  beneficio1 = _beneficio1,
					  beneficio2 = _beneficio2,
					  beneficio3 = _beneficio3,
					  beneficio4 = _beneficio4,
					  plan       = _plan,
					  hijo5 = _hijo5,
					  hijo6 = _hijo6,
					  hijo7 = _hijo7,
					  hijo8 = _hijo8,
					  beneficio5 = _beneficio5
			    WHERE poliza = _no_documento
			      AND unidad = _no_unidad;
		   --		RETURN v_error,
		   --		       trim(v_retorno);
			END IF	        
		END EXCEPTION
	  	INSERT INTO fox_salud(
		   poliza,
		   efectiva,
		   asegurado,
		   conyuge,
		   hijo1,
		   hijo2,
		   hijo3,
		   hijo4,
		   limite1,
		   limite2,
		   unidad,
		   cod_subramo,
		   plan,
		   beneficio1,
		   beneficio2,
		   beneficio3,
		   beneficio4,
		   hijo5,
		   hijo6,
		   hijo7,
		   hijo8,
           beneficio5		   
		   )
	  	   VALUES(
		   _no_documento,
		   _vigencia_inic,
	  	   _nombre,
	  	   _conyuge,
	  	   _hijo1,
	  	   _hijo2,
	  	   _hijo3,
		   _hijo4,
		   _limite_1,
		   _limite_2,
		   _no_unidad,
		   _cod_subramo,
		   _plan,
		   _beneficio1,
		   _beneficio2,
		   _beneficio3,
		   _beneficio4,
	  	   _hijo5,
	  	   _hijo6,
	  	   _hijo7,
		   _hijo8,
		   _beneficio5
	  	   );

		BEGIN
			ON EXCEPTION IN(-239,-268)
			 LET _impreso = 0;

			 SELECT impreso
			   INTO _impreso
			   FROM fox_hech_sal
			  WHERE poliza = _no_documento
			    AND unidad = _no_unidad;

			 UPDATE fox_salud
			    SET impreso = _impreso
			  WHERE poliza = _no_documento
			    AND unidad = _no_unidad;
			END EXCEPTION
		  	INSERT INTO fox_hech_sal(
			   poliza,
			   efectiva,
			   asegurado,
			   conyugue,
			   hijo1,
			   hijo2,
			   hijo3,
			   hijo4,
			   limite1,
			   limite2,
			   unidad
			   )
		  	   VALUES(
		  	   _no_documento,
		  	   _vigencia_inic,
		  	   _nombre,
		  	   _conyuge,
		  	   _hijo1,
			   _hijo2,
			   _hijo3,
			   _hijo4,
			   _limite_1,
			   _limite_2,
			   _no_unidad
		  	   );
		END
	END

END FOREACH



-- Dependientes nuevos activos y no activos

FOREACH
	SELECT no_poliza,
	       no_unidad
	  INTO _no_poliza,
	       _no_unidad
	  FROM emidepen	 
	 WHERE (date_added >= a_fecha1
	   AND date_added <= a_fecha2)
	    OR (no_activo_desde >= a_fecha1
	   AND no_activo_desde <= a_fecha2)
  GROUP BY no_poliza, no_unidad

	 SELECT x.no_documento,
	       	z.cod_carnet,
			y.cod_asegurado,
			y.vigencia_inic,
			z.plan,
			z.beneficio1,
			z.beneficio2,
			z.beneficio3,
			z.beneficio4,
			z.beneficio5
	   INTO _no_documento,
	        _cod_subramo,
			_cod_asegurado,
			_vigencia_inic,
			_plan,
			_beneficio1,
			_beneficio2,
			_beneficio3,
			_beneficio4,
			_beneficio5
	   FROM emipomae x, emipouni y, prdprod z, emicarnet u
	  WHERE x.no_poliza = _no_poliza
	    AND x.actualizado = 1
		AND x.cod_ramo = '018'
		AND y.no_poliza = x.no_poliza
		AND y.no_unidad = _no_unidad
		AND y.activo    = 1
		AND z.cod_producto = y.cod_producto
		AND z.cod_carnet = u.cod_carnet;

	 IF _no_documento IS NULL THEN
		CONTINUE FOREACH;
	 END IF

	 LET _campo_documento = NULL;
	 LET _limite_1 = '';
	 LET _limite_2 = '';
	 LET _nombre_par = '';
	 LET _conyuge = '';
	 LET _hijo1 = '';
	 LET _hijo2 = '';
	 LET _hijo3 = '';
	 LET _hijo4 = '';
	 LET _hijo5 = '';
	 LET _hijo6 = '';
	 LET _hijo7 = '';
	 LET _hijo8 = '';

	 SELECT poliza
	   INTO _campo_documento
	   FROM fox_salud
	  WHERE poliza = _no_documento
	    AND unidad = _no_unidad;

	 IF _campo_documento IS NOT NULL THEN
		CONTINUE FOREACH;
	 END IF

	SELECT nombre
	  INTO _nombre
 	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	IF _cod_subramo = '009' OR _cod_subramo = '013' THEN
		SELECT limite_1,  
		       limite_2 
		  INTO _limite_1,
		       _limite_2
		  FROM emipocob  
		 WHERE no_poliza = _no_poliza 
		   AND no_unidad = _no_unidad
	       AND cod_cobertura = '00570';
	END IF

	LET _cant = 0;

	FOREACH
		SELECT x.nombre, 
		       y.cod_parentesco 
		  INTO _nombre_par,
			   _cod_parentesco
		  FROM cliclien x, emidepen y 
		 WHERE x.cod_cliente = y.cod_cliente
           AND y.no_poliza = _no_poliza 
           AND y.no_unidad = _no_unidad
		   AND y.activo = 1

		   IF _cod_parentesco = '001' THEN
			  LET _conyuge	=  _nombre_par;
		   ELSE
			  LET _cant = _cant + 1;
			  IF _cant = 1 THEN
			     LET _hijo1 = _nombre_par;
			  ELIF _cant = 2 THEN
			     LET _hijo2 = _nombre_par;
			  ELIF _cant = 3 THEN
			     LET _hijo3 = _nombre_par;
			  ELIF _cant = 4 THEN
			     LET _hijo4 = _nombre_par;
			  ELIF _cant = 5 THEN
			     LET _hijo5 = _nombre_par;
			  ELIF _cant = 6 THEN
			     LET _hijo6 = _nombre_par;
			  ELIF _cant = 7 THEN
			     LET _hijo7 = _nombre_par;
			  ELIF _cant = 8 THEN
			     LET _hijo8 = _nombre_par;
			  END IF
		   END IF

	END FOREACH

	BEGIN
		ON EXCEPTION SET v_error
			IF 	v_error <> -268 AND v_error <> -239 THEN
		 --		RETURN v_error,
		  --		       trim(v_retorno);
			END IF	        
		END EXCEPTION
	  	INSERT INTO fox_salud(
		   poliza,
		   efectiva,
		   asegurado,
		   conyuge,
		   hijo1,
		   hijo2,
		   hijo3,
		   hijo4,
		   limite1,
		   limite2,
		   unidad,
		   cod_subramo,
		   plan,
		   beneficio1,
		   beneficio2,
		   beneficio3,
		   beneficio4,
		   hijo5,
		   hijo6,
		   hijo7,
		   hijo8,
           beneficio5		   
		   )
	  	   VALUES(
		   _no_documento,
		   _vigencia_inic,
	  	   _nombre,
	  	   _conyuge,
	  	   _hijo1,
	  	   _hijo2,
	  	   _hijo3,
		   _hijo4,
		   _limite_1,
		   _limite_2,
		   _no_unidad,
		   _cod_subramo,
		   _plan,
		   _beneficio1,
		   _beneficio2,
		   _beneficio3,
		   _beneficio4,
	  	   _hijo5,
	  	   _hijo6,
	  	   _hijo7,
		   _hijo8,
		   _beneficio5
	  	   );
	END
END FOREACH

SELECT count(*) 
  INTO _contador
  FROM fox_generado;

IF _contador > 0 THEN
	UPDATE fox_generado
	   SET fecha_desde = a_fecha1,
	       fecha_hasta = a_fecha2,
		   generado = current; 
ELSE
	INSERT INTO fox_generado(
	   fecha_desde,
	   fecha_hasta,
	   generado
	   ) 
	   VALUES(
	   a_fecha1,
	   a_fecha2,
	   current
	   ); 
END IF

LET v_retorno = "EXITO";   				 
RETURN 0,
       trim(v_retorno);


END PROCEDURE
                                                                                          
