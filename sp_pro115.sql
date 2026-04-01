-- Procedimiento para traer a los corredores
--
-- Creado    : 07/05/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 22/05/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro115;

CREATE PROCEDURE "informix".sp_pro115(a_fecha1 DATE, a_fecha2 DATE)
  RETURNING INTEGER,  
   			CHAR(10);

  DEFINE v_retorno		CHAR(10);
  DEFINE v_error        INTEGER;
  DEFINE _no_documento  CHAR(20);
  DEFINE _nombre, _nombre_par, _conyuge, _hijo1, _hijo2, _hijo3, _hijo4  CHAR(100);
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal, _cod_parentesco CHAR(3);
  DEFINE _vigencia_inic DATE;
  DEFINE _no_unidad     CHAR(5);
  DEFINE _cant          SMALLINT;
  DEFINE _limite_1, _limite_2, _no_poliza CHAR(10);
  DEFINE _campo_documento  CHAR(20);
  DEFINE _cod_ramo, _cod_subramo CHAR(3);

  SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro115.trc"; 
--trace on;
DELETE FROM fox_carnets;
DELETE FROM fox_salud;

LET v_retorno = 'ERROR';
LET _nombre_par = '';
LET _conyuge = '';
LET _hijo1 = '';
LET _hijo2 = '';
LET _hijo3 = '';
LET _hijo4 = '';

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
	   AND x.sucursal_origen NOT IN ('051','023','056') 
	   AND t.no_motor = u.no_motor 
	   AND x.cod_ramo = '002' 
	   AND (x.cod_subramo = '001' or  x.cod_subramo = '012')
	   AND v.fecha_emision >= a_fecha1   
	   AND v.fecha_emision <= a_fecha2 
	   AND x.actualizado = 1

	BEGIN
		ON EXCEPTION IN(-239,-268)
		   CONTINUE FOREACH;
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
	END

END FOREACH

-- Panama 1, Panama 2, Global, Colectivo Especial, Especial

FOREACH
	SELECT x.no_documento,
	       y.nombre,
	       v.vigencia_inic,
	       v.no_unidad,
	       x.no_poliza,
		   x.cod_subramo
	  INTO _no_documento,
	       _nombre,
		   _vigencia_inic,
		   _no_unidad,
		   _no_poliza,
		   _cod_subramo
 	  FROM emipouni v, emipomae x, cliclien y
	 WHERE v.no_poliza = x.no_poliza 
	   AND v.activo = 1 
       AND y.cod_cliente = v.cod_asegurado 
       AND x.actualizado = 1  
       AND x.cod_ramo = '018' 
       AND x.cod_subramo in ('007','008','009','010','011')
       AND x.fecha_suscripcion >= a_fecha1 
       AND x.fecha_suscripcion <= a_fecha2

	LET _cant = 0;

	LET _limite_1 = '';
	LET _limite_2 = '';
	LET _nombre_par = '';
	LET _conyuge = '';
	LET _hijo1 = '';
	LET _hijo2 = '';
	LET _hijo3 = '';
	LET _hijo4 = '';

	IF _cod_subramo = '009' THEN
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
		ON EXCEPTION IN(-239,-268)
			CONTINUE FOREACH;
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

	BEGIN
		ON EXCEPTION SET v_error
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
		   cod_subramo
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
		   _cod_subramo
	  	   );
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

	 SELECT no_documento,
	       	cod_ramo,
			cod_subramo
	   INTO _no_documento,
	        _cod_ramo,
			_cod_subramo
	   FROM emipomae
	  WHERE no_poliza = _no_poliza
	    AND actualizado = 1
		AND cod_ramo = '018'
		AND cod_subramo IN ('007','008','009','010','011');

	 LET _campo_documento = NULL;
	 LET _limite_1 = '';
	 LET _limite_2 = '';
	 LET _nombre_par = '';
	 LET _conyuge = '';
	 LET _hijo1 = '';
	 LET _hijo2 = '';
	 LET _hijo3 = '';
	 LET _hijo4 = '';

	 SELECT poliza
	   INTO _campo_documento
	   FROM fox_salud
	  WHERE poliza = _no_documento
	    AND unidad = _no_unidad;

	 IF _campo_documento IS NOT NULL THEN
		CONTINUE FOREACH;
	 END IF

	SELECT y.nombre,
	       v.vigencia_inic
	  INTO _nombre,
		   _vigencia_inic
 	  FROM emipouni v, cliclien y
	 WHERE v.activo = 1 
       AND y.cod_cliente = v.cod_asegurado 
	   AND v.no_poliza = _no_poliza
	   AND v.no_unidad = _no_unidad;

	IF _cod_subramo = '009' THEN
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
			  END IF
		   END IF

	END FOREACH

	BEGIN
		ON EXCEPTION SET v_error
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
		   cod_subramo
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
		   _cod_subramo
	  	   );
	END
END FOREACH

LET v_retorno = "EXITO";   				 
RETURN 0,
       trim(v_retorno);


END PROCEDURE

