-- Procedimiento para traer polizas de auto y salud
--
-- Creado    : 07/05/2003 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 30/05/2003 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro115e;

CREATE PROCEDURE "informix".sp_pro115e(a_poliza CHAR(10), a_unidad CHAR(5), a_opcion CHAR(1))
  RETURNING INTEGER,  
   			CHAR(20);

  DEFINE v_retorno		CHAR(10);
  DEFINE v_error        INTEGER;
  DEFINE _no_documento  CHAR(20);
  DEFINE _nombre, _nombre_par, _conyuge, _hijo1, _hijo2, _hijo3, _hijo4  CHAR(100);
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal, _cod_parentesco, _cod_ramo, _cod_subramo CHAR(3);
  DEFINE _vigencia_inic DATE;
  DEFINE _no_unidad     CHAR(5);
  DEFINE _cant          SMALLINT;
  DEFINE _limite_1, _limite_2, _no_poliza CHAR(10);
  DEFINE _plan			CHAR(50);
  DEFINE _beneficio1	CHAR(65);
  DEFINE _beneficio2	CHAR(65);
  DEFINE _beneficio3	CHAR(65);
  DEFINE _beneficio4	CHAR(65);
  DEFINE _beneficio5	CHAR(65);

  SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro115e.trc"; 
--trace on;

LET v_retorno = 'ERROR';
LET _nombre_par = '';
LET _conyuge = '';
LET _hijo1 = '';
LET _hijo2 = '';
LET _hijo3 = '';
LET _hijo4 = '';
IF a_opcion = "1" THEN
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
		   AND y.cod_cliente = x.cod_contratante
		   AND (v.cod_endomov = '004' OR (v.cod_endomov = '011' AND x.nueva_renov = 'N'))  
		   AND z.no_poliza = x.no_poliza 
		   AND z.uso_auto = 'P'
		   AND u.no_motor = z.no_motor 
		   AND t.no_motor = u.no_motor 
		   AND x.cod_ramo = '002' 
		   AND (x.cod_subramo = '001' or  x.cod_subramo = '012')
		   AND x.actualizado = 1
		   AND x.no_poliza = a_poliza
		   AND z.no_unidad = a_unidad
--		   AND x.sucursal_origen NOT IN ('051','023','056') 

		BEGIN
			ON EXCEPTION SET v_error
  			 UPDATE fox_carnets
			    SET nomcli = _nombre,
			    	polifact = _no_documento,
			    	sucpoli = _cod_sucursal,
			    	placa = _placa,
			    	num_moto = _no_motor,
			        impreso = 0
			  WHERE polifact = _no_documento
			    AND num_moto = _no_motor;
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
		END

	END FOREACH

	FOREACH
		SELECT nomcli,
			   polifact,
			   sucpoli,
			   placa,
			   num_moto
		  INTO _nombre,
			   _no_documento,
			   _cod_sucursal,
			   _placa,
			   _no_motor
		  FROM fox_carnets
		 WHERE polifact = _no_documento

		BEGIN
			ON EXCEPTION IN(-239,-268)
  {			 UPDATE fox_carnets
			    SET impreso = 1
			  WHERE polifact = _no_documento
			    AND num_moto = _no_motor;}
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

	END FOREACH
ELSE
-- Panama 1, Panama 2, Global, Colectivo Especial, otros especiales
 
	FOREACH
		SELECT y.nombre,
		       v.vigencia_inic,
		       v.no_unidad,
		       v.no_poliza,
			   z.cod_carnet,
			   z.plan,
			   z.beneficio1,
			   z.beneficio2,
			   z.beneficio3,
			   z.beneficio4,
			   z.beneficio5
		  INTO _nombre,
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
	 	  FROM emipouni v, cliclien y, prdprod z
		 WHERE v.no_poliza = a_poliza 
		   AND v.activo = 1 
	       AND y.cod_cliente = v.cod_asegurado 
		   AND z.cod_producto = v.cod_producto
		   AND v.no_unidad = (trim(a_unidad))

        SELECT no_documento
          INTO _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		LET _cant = 0;
		LET _limite_1 = '';
		LET _limite_2 = '';
		LET _nombre_par = '';
		LET _conyuge = '';
		LET _hijo1 = '';
		LET _hijo2 = '';
		LET _hijo3 = '';
		LET _hijo4 = '';

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
				  END IF
			   END IF

		END FOREACH

		BEGIN
			ON EXCEPTION SET v_error
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
					  plan    = _plan,
					  beneficio1 = _beneficio1,
					  beneficio2 = _beneficio2,
					  beneficio3 = _beneficio3,
					  beneficio4 = _beneficio4,
					  beneficio5 = _beneficio5
			    WHERE poliza = _no_documento
			      AND unidad = _no_unidad;
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
			   _beneficio5
		  	   );
			END

	END FOREACH

	FOREACH
		SELECT poliza,
			   efectiva,
			   asegurado,
			   conyuge,
			   hijo1,
			   hijo2,
			   hijo3,
			   hijo4,
			   limite1,
			   limite2,
			   unidad
		  INTO _no_documento,
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
		  FROM fox_salud
		 WHERE poliza = _no_documento

		BEGIN
			ON EXCEPTION IN(-239,-268)
		  {	 UPDATE fox_salud
			    SET impreso = 1
			  WHERE poliza = _no_documento
			    AND unidad = _no_unidad;}
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
	END FOREACH
END IF


IF a_opcion = 1 THEN
	LET v_retorno = "Auto"; 
ELSE  				 
	IF _cod_subramo = '007' THEN
		LET v_retorno = "Panama 1";   				 
	ELIF _cod_subramo = '008' THEN	    
		LET v_retorno = "Panama 2";   				 
	ELIF _cod_subramo = '009' THEN	    
		LET v_retorno = "Global";   				 
	ELIF _cod_subramo = '010' THEN	    
		LET _cod_subramo = 'Colectivo Especial';
	ELIF _cod_subramo = '011' THEN	    
		LET v_retorno = "AA18PAESP1";   				 
	ELIF _cod_subramo = '013' THEN	    
		LET v_retorno = "Complementario";   				 
	ELIF _cod_subramo = '015' THEN	    
		LET v_retorno = "Plan Dental";   				 
	ELIF _cod_subramo = '016' THEN	    
		LET v_retorno = "Hospitalizacion";   				 
	ELIF _cod_subramo = '017' THEN	    
		LET v_retorno = "Costa Rica";   				 
	ELIF _cod_subramo = '020' THEN	    
		LET v_retorno = "Health Network";   				 
	ELIF _cod_subramo = '021' THEN	    
		LET v_retorno = "Ancon Premier Care";   				 
	END IF
END IF
RETURN 0,
       trim(v_retorno);


END PROCEDURE

