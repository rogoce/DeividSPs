-- Procedimiento que Carga el Flujo de Caja para un
-- Rango de Fechas Dado en detalle
-- 
-- Creado    : 09/05/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.
  
DROP PROCEDURE sp_che18;

CREATE PROCEDURE "informix".sp_che18(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha_desde	DATE,
a_fecha_hasta	DATE
);

DEFINE _cod_flujo	CHAR(3);
DEFINE _fuente_dato	SMALLINT;
DEFINE _renglon		SMALLINT;
DEFINE _cuenta		CHAR(25);
DEFINE _cta			CHAR(25);
DEFINE _debito		DEC(16,2);
DEFINE _credito		DEC(16,2);
DEFINE _monto 		DEC(16,2);
DEFINE _banco   	CHAR(3);
DEFINE _no_remesa	CHAR(10);
DEFINE _no_requis	CHAR(10);

CREATE TEMP TABLE tmp_flujo(
cod_flujo	CHAR(3),
monto		DEC(16,2),
banco		CHAR(3),
db			DEC(16,2),
cr 			DEC(16,2)
);

CREATE TEMP TABLE tmp_flujo_det(
banco		CHAR(3),
tipo_flujo  SMALLINT,
cod_flujo	CHAR(3),
fuente_dato SMALLINT,
no_rem_req  CHAR(10),
renglon		SMALLINT,
cuenta		CHAR(25),
db			DEC(16,2),
cr 			DEC(16,2),
seleccionado SMALLINT  DEFAULT 1 NOT NULL
);

SET ISOLATION TO DIRTY READ;
-----------------------
-- Entradas de Efectivo
-----------------------
FOREACH
 SELECT	cod_flujo,
		fuente_dato
   INTO	_cod_flujo,
		_fuente_dato
   FROM	chqfluti
  WHERE tipo_flujo = 1
	
  FOREACH
	 SELECT	cuenta
	   INTO	_cuenta
	   FROM	chqflucu
	  WHERE cod_flujo = _cod_flujo

		LET _cuenta = TRIM(_cuenta) || '*';
		
	   -- Remesa de Flujo (Comprobantes)

	   FOREACH
		SELECT cod_banco,
		       no_remesa
		  INTO _banco,
		       _no_remesa
		  FROM cobremae 
		 WHERE cod_compania = a_compania
		   AND fecha        = a_fecha_desde
		   AND actualizado  = 1
		   AND tipo_remesa  = 'F'

			IF _no_remesa IS NULL THEN
				CONTINUE FOREACH;
			END IF

		   FOREACH
			SELECT debito,
				   credito,
				   renglon,
				   cuenta
			  INTO _debito,
			       _credito,
				   _renglon,
				   _cta
			  FROM cobasien     	   				
			 WHERE no_remesa = _no_remesa
			   AND cuenta    MATCHES _cuenta

				IF _debito IS NULL THEN
					LET _debito = 0;
				END IF

				IF _credito IS NULL THEN
					LET _credito = 0;
				END IF

				LET _monto = _debito - _credito;

				INSERT INTO tmp_flujo
				VALUES(
				_cod_flujo,
				_monto,
				_banco,
				_monto,
				0
				);

				INSERT INTO tmp_flujo_det
				VALUES(
				_banco,
				1,
				_cod_flujo,
				_fuente_dato,
				_no_remesa,
				_renglon,
				_cta,
				_debito,
				_credito,
				1
				);

		   END FOREACH

	   END FOREACH

		IF _fuente_dato = 1 THEN -- Caja

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

				IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;

					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					_monto,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					1,
					_cod_flujo,
					1,
					_no_remesa,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);
			   END FOREACH

		   END FOREACH

		ELIF _fuente_dato = 2 THEN -- Cheques

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

				IF _no_requis IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta    MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					_monto,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					1,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH

		ELSE -- Ambos

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

				IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
				    _cod_flujo,
					_monto,
					_banco,
					_monto,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					1,
					_cod_flujo,
					1,
					_no_remesa,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);
			   END FOREACH
		   END FOREACH

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					_monto,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					1,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);
			   END FOREACH
		   END FOREACH

		END IF
  END FOREACH
END FOREACH
---------------------
-- Salida de Efectivo
---------------------
FOREACH
 SELECT	cod_flujo,
		fuente_dato
   INTO	_cod_flujo,
		_fuente_dato
   FROM	chqfluti
  WHERE tipo_flujo = 2
	
	FOREACH
	 SELECT	cuenta
	   INTO	_cuenta
	   FROM	chqflucu
	  WHERE cod_flujo = _cod_flujo

		LET _cuenta = TRIM(_cuenta) || '*';

	   -- Remesa de Flujo (Comprobantes)
	   FOREACH
		SELECT cod_banco,
		       no_remesa
		  INTO _banco,
		       _no_remesa
		  FROM cobremae 
		 WHERE cod_compania = a_compania
		   AND fecha        = a_fecha_desde
		   AND actualizado  = 1
		   AND tipo_remesa  = 'F'

			IF _no_remesa IS NULL THEN
				CONTINUE FOREACH;
			END IF

		   FOREACH
			SELECT debito,
				   credito,
				   renglon,
				   cuenta
			  INTO _debito,
			       _credito,
				   _renglon,
				   _cta
			  FROM cobasien     	   				
			 WHERE no_remesa = _no_remesa
			   AND cuenta    MATCHES _cuenta

				IF _debito IS NULL THEN
					LET _debito = 0;
				END IF

				IF _credito IS NULL THEN
					LET _credito = 0;
				END IF

				LET _monto = _debito - _credito;

				INSERT INTO tmp_flujo
				VALUES(
				_cod_flujo,
				_monto,
				_banco,
				_monto,
				0
				);

				INSERT INTO tmp_flujo_det
				VALUES(
				_banco,
				2,
				_cod_flujo,
				1,
				_no_remesa,
				_renglon,
				_cta,
				_debito,
				_credito,
				1
				);
		   END FOREACH
	   END FOREACH

		IF _fuente_dato = 1 THEN -- Caja

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

				IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuanta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;

					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					_monto
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					2,
					_cod_flujo,
					1,
					_no_remesa,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH

		ELIF _fuente_dato = 2 THEN -- Cheques

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

				IF _no_requis IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					_monto
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					2,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

		  	   END FOREACH

	  	   END FOREACH

		ELSE					   -- Ambos

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

				IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					_monto
					);

				INSERT INTO tmp_flujo_det
				VALUES(
				_banco,
				2,
				_cod_flujo,
				1,
				_no_remesa,
				_renglon,
				_cta,
				_debito,
				_credito,
				1
				);
			   END FOREACH

		   END FOREACH

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

				IF _no_requis IS NULL THEN
					CONTINUE FOREACH;
				END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					_monto
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					2,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH
		   END FOREACH

		END IF
	END FOREACH
END FOREACH
-------------
-- Movimiento
-------------
FOREACH
 SELECT	cod_flujo,
		fuente_dato
   INTO	_cod_flujo,
		_fuente_dato
   FROM	chqfluti
  WHERE tipo_flujo = 3
	
	FOREACH
	 SELECT	cuenta
	   INTO	_cuenta
	   FROM	chqflucu
	  WHERE cod_flujo = _cod_flujo

		LET _cuenta = TRIM(_cuenta) || '*';

		IF _fuente_dato = 1 THEN -- Caja

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

				 IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				 END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;

					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					3,
					_cod_flujo,
					1,
					_no_remesa,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH
			   
		ELIF _fuente_dato = 2 THEN -- Cheques

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

			IF _no_requis IS NULL THEN
				CONTINUE FOREACH;
			END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					3,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH

		ELSE					   -- Ambos

		   FOREACH
			SELECT cod_banco,
			       no_remesa
			  INTO _banco,
			       _no_remesa
			  FROM cobremae 
			 WHERE cod_compania = a_compania
			   AND fecha        = a_fecha_desde
			   AND actualizado  = 1
			   AND tipo_remesa  <> 'F'

			     IF _no_remesa IS NULL THEN
					CONTINUE FOREACH;
				 END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM cobasien     	   				
				 WHERE no_remesa = _no_remesa
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;
					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					3,
					_cod_flujo,
					1,
					_no_remesa,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH

		   FOREACH
			SELECT cod_banco,
			       no_requis
			  INTO _banco,
			       _no_requis
			  FROM chqchmae 
			 WHERE cod_compania    = a_compania
			   AND fecha_impresion = a_fecha_desde
			   AND pagado          = 1

			IF _no_requis IS NULL THEN
				CONTINUE FOREACH;
			END IF

			   FOREACH
				SELECT debito,
					   credito,
					   renglon,
					   cuenta
				  INTO _debito,
				       _credito,
					   _renglon,
					   _cta
				  FROM chqchcta      	   				
				 WHERE no_requis = _no_requis
				   AND cuenta  MATCHES _cuenta

					IF _debito IS NULL THEN
						LET _debito = 0;
					END IF

					IF _credito IS NULL THEN
						LET _credito = 0;
					END IF

					LET _monto = _debito - _credito;
					LET _monto = _monto * -1;

					INSERT INTO tmp_flujo
					VALUES(
					_cod_flujo,
					_monto,
					_banco,
					0,
					0
					);

					INSERT INTO tmp_flujo_det
					VALUES(
					_banco,
					3,
					_cod_flujo,
					2,
					_no_requis,
					_renglon,
					_cta,
					_debito,
					_credito,
					1
					);

			   END FOREACH

		   END FOREACH

		END IF

	END FOREACH

END FOREACH

END PROCEDURE;