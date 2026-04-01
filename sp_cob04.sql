-- Procedimiento que Carga los Avisos de Cancelacion

-- Creado    : 22/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 21/08/2001 - Autor: Marquelda Valdelamar
-- Modificado: 28/07/2004 - Autor: Armando Moreno(Argumento callcenter para diferenciar procesos)

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob04;

CREATE PROCEDURE "informix".sp_cob04(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE,
a_cobrador CHAR(3),
a_callcenter integer default 0
)

DEFINE _no_poliza  		  CHAR(10);
DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_agente        CHAR(5);
DEFINE _tipo_aviso        SMALLINT;
DEFINE _prima             DEC(16,2);
DEFINE _saldo	          DEC(16,2);
DEFINE _por_vencer	      DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30		  DEC(16,2);
DEFINE _monto_60		  DEC(16,2);
DEFINE _monto_90		  DEC(16,2);
DEFINE _ramo_sis		  CHAR(3);
DEFINE _vigencia_final	  DATE;
DEFINE _estatus_poliza	  SMALLINT;
DEFINE _carta_aviso_can	  SMALLINT;
DEFINE _carta_prima_gan	  SMALLINT;
DEFINE _carta_vencida_sal SMALLINT;
DEFINE _carta_recorderis  SMALLINT;
DEFINE _cod_ramo		  CHAR(50);
DEFINE _cod_sucursal	  CHAR(50);
DEFINE _cod_cliente		  CHAR(10);
DEFINE _ano               SMALLINT;
DEFINE _tipo_cobra		  SMALLINT;
DEFINE _vigencia_inic	  DATE;
DEFINE _nombre_agente	  CHAR(50);
DEFINE _nombre_cliente	  CHAR(50);
DEFINE _nombre_acreedor	  CHAR(50);
DEFINE _doc_poliza        CHAR(20);
DEFINE _fecha_suscripcion DATE;
DEFINE _fecha_carta_canc  DATE;
DEFINE _fecha_ult_pago    DATE;
DEFINE _monto_moros_salud DEC(16,2);
DEFINE _nombre_ramo	      CHAR(50);
DEFINE _nombre_sucursal	  CHAR(50);
DEFINE _fecha_vence       DATE;
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cobra_poliza      CHAR(1);
define _dupli			  integer;

SET ISOLATION TO DIRTY READ;
let _dupli = 0;

-- Actualizacion de los Datos del Cobrador
if a_callcenter = 0 then

	-- Morosidad de Cartera
	CALL sp_cob03(
	a_compania,
	a_agencia,
	a_fecha
	);

	DELETE FROM cobaviso
	 WHERE cod_cobrador = a_cobrador;

	select tipo_cobrador
	  into _tipo_cobra
	  from cobcobra
	 where cod_cobrador = a_cobrador
	   and activo       = 1;


   if _tipo_cobra = 4 then	--electronico(visa/ach)
	FOREACH
	 SELECT no_poliza,
			cod_acreedor,
			cod_agente,
			prima_orig,
			saldo,
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90
	   INTO _no_poliza,
			_cod_acreedor,
			_cod_agente,
			_prima,
			_saldo,
		    _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90
	   FROM tmp_moros
	  WHERE saldo > 0

		LET _fecha_vence =  (a_fecha + 10);

		SELECT vigencia_final,
		       estatus_poliza,
			   carta_aviso_canc,
			   carta_prima_gan,
			   carta_vencida_sal,
			   carta_recorderis,
			   cod_ramo,
			   cod_contratante,
			   sucursal_origen,
			   vigencia_inic,
			   no_documento,
			   fecha_suscripcion,
			   fecha_aviso_canc,
			   fecha_ult_pago,
			   cobra_poliza
		  INTO _vigencia_final,
		       _estatus_poliza,
			   _carta_aviso_can,
			   _carta_prima_gan,
			   _carta_vencida_sal,
			   _carta_recorderis,
			   _cod_ramo,
			   _cod_cliente,
			   _cod_sucursal,
			   _vigencia_inic,
			   _doc_poliza,
			   _fecha_suscripcion,
			   _fecha_carta_canc,
			   _fecha_ult_pago,
			   _cobra_poliza
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		if _cobra_poliza = "T" or _cobra_poliza = "H" then
			let _cobra_poliza = "4"; --let _cobra_poliza = "S";
		else
			continue foreach;
		end if

		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	  --Excluye las polizas cuya fecha de vencimiento sean mayores que la vigencia final
	 	IF _vigencia_final <= _fecha_vence AND _saldo <= 0.00 THEN
			IF _ramo_sis <> 5 THEN
				CONTINUE FOREACH;
			END IF
		END IF

		IF _estatus_poliza = 2 THEN -- Polizas Canceladas
			LET _tipo_aviso = 2;
			IF _carta_prima_gan = 1 THEN
				CONTINUE FOREACH;
			END IF
			
		ELSE -- Poliza Activas

			IF _vigencia_final >= a_fecha THEN -- Vigentes

				IF _ramo_sis = 5 THEN -- Las Polizas de Salud se le Envian Avisos a los 30 Dias

					LET _tipo_aviso = 1;
					LET _monto_moros_salud = _monto_30 + _monto_60 + _monto_90;
					IF _monto_moros_salud > 0 THEN
						IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
							IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
							    CONTINUE FOREACH;           -- les envia Aviso Denuevo
							ELSE
								IF _fecha_ult_pago <= _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
									CONTINUE FOREACH;                        -- quedo morosa, denuevo Aviso
								END IF	  
							END IF
						END IF
					ELSE 
						CONTINUE FOREACH;				
					END IF

				ELSE

					IF _monto_90 > 0 THEN -- Con Morosidad a 90 Dias (Aviso de Cancelacion)

						LET _tipo_aviso = 1;
						IF _ramo_sis <> 3 THEN -- Las Fianzas no se le Envian Avisos
							IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
								IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
								    CONTINUE FOREACH;           -- les envia Aviso Denuevo
								ELSE
									IF _fecha_ult_pago < _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
										CONTINUE FOREACH;                       -- quedo morosa, denuevo Aviso
									END IF	  
								END IF
							END IF
						ELSE
							CONTINUE FOREACH;
						END IF

					ELSE 

						IF _monto_60 > 0 THEN -- Con Morosidad a 60 Dias (Carta de Recorderis)
							LET _tipo_aviso = 4;
						ELSE
							CONTINUE FOREACH;
						END IF

					END IF

				END IF

			ELSE -- Vencidas (Polizas Vencidas con Saldo)

				IF _carta_vencida_sal = 0 THEN
					LET _tipo_aviso = 3;
				ELSE
					CONTINUE FOREACH;
				END IF

			END IF   

		END IF

		BEGIN
		ON EXCEPTION IN(-268) -- Por si se encuentran polizas que tienen 2 corredores
		END EXCEPTION		  -- y ambos tienen cobradores diferentes asignados

			IF _tipo_aviso = 2 THEN -- Prima Ganada
				LET _ano =	YEAR(_vigencia_inic);
					IF _vigencia_inic IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELIF _tipo_aviso = 3 THEN -- Vencidas con Saldo
				LET _ano =	YEAR(_vigencia_final);
					IF _vigencia_final IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELSE
				LET _ano = 0;
			END IF

			-- Nombres
			SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			SELECT nombre
			  INTO _nombre_cliente
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			SELECT nombre
			  INTO _nombre_acreedor
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			SELECT nombre
			  INTO _nombre_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			SELECT descripcion
			  INTO _nombre_sucursal
			  FROM insagen
			 WHERE codigo_agencia = _cod_sucursal;

			INSERT INTO cobaviso(
			cod_cobrador, 
			no_poliza, 
			cod_acreedor, 
			cod_agente,
	        tipo_aviso, 
			prima, 
			monto_letras, 
			imprimir, 
			impreso,
			saldo, 
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90,
			cod_sucursal,
			cod_ramo,
			cod_cliente,
			ano,
			nombre_agente,
			nombre_cliente,
			nombre_acreedor,
			no_documento,
			vigencia_inic,
			vigencia_final,
			cobra_poliza
	        )
			VALUES(
			a_cobrador, 
			_no_poliza, 
			_cod_acreedor, 
			_cod_agente,
	        _tipo_aviso, 
			_prima,    
			'', 
			"0", 
			0,
			_saldo, 
	        _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90,
			_cod_sucursal,
			_cod_ramo,
			_cod_cliente,
			_ano,
			_nombre_agente,
			_nombre_cliente,
			_nombre_acreedor,
			_doc_poliza,
			_vigencia_inic,
			_vigencia_final,
			_cobra_poliza
			);
		END
	END FOREACH
   -------AQUI--------
   else

	FOREACH
	 SELECT no_poliza,
			cod_acreedor,
			cod_agente,
			prima_orig,
			saldo,
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90
	   INTO _no_poliza,
			_cod_acreedor,
			_cod_agente,
			_prima,
			_saldo,
		    _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90
	   FROM tmp_moros
	  WHERE cod_cobrador like a_cobrador
	    AND saldo > 0

		LET _fecha_vence =  (a_fecha + 10);

		SELECT vigencia_final,
		       estatus_poliza,
			   carta_aviso_canc,
			   carta_prima_gan,
			   carta_vencida_sal,
			   carta_recorderis,
			   cod_ramo,
			   cod_contratante,
			   sucursal_origen,
			   vigencia_inic,
			   no_documento,
			   fecha_suscripcion,
			   fecha_aviso_canc,
			   fecha_ult_pago,
			   cobra_poliza
		  INTO _vigencia_final,
		       _estatus_poliza,
			   _carta_aviso_can,
			   _carta_prima_gan,
			   _carta_vencida_sal,
			   _carta_recorderis,
			   _cod_ramo,
			   _cod_cliente,
			   _cod_sucursal,
			   _vigencia_inic,
			   _doc_poliza,
			   _fecha_suscripcion,
			   _fecha_carta_canc,
			   _fecha_ult_pago,
			   _cobra_poliza
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	  --Excluye las polizas cuya fecha de vencimiento sean mayores que la vigencia final
	 	IF _vigencia_final <= _fecha_vence AND _saldo <= 0.00 THEN
			IF _ramo_sis <> 5 THEN
				CONTINUE FOREACH;
			END IF
		END IF

		IF _estatus_poliza = 2 THEN -- Polizas Canceladas
			LET _tipo_aviso = 2;
			IF _carta_prima_gan = 1 THEN
				CONTINUE FOREACH;
			END IF
			
		ELSE -- Poliza Activas

			IF _vigencia_final >= a_fecha THEN -- Vigentes

				IF _ramo_sis = 5 THEN -- Las Polizas de Salud se le Envian Avisos a los 30 Dias

					LET _tipo_aviso = 1;
					LET _monto_moros_salud = _monto_30 + _monto_60 + _monto_90;
					IF _monto_moros_salud > 0 THEN
						IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
							IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
							    CONTINUE FOREACH;           -- les envia Aviso Denuevo
							ELSE
								IF _fecha_ult_pago <= _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
									CONTINUE FOREACH;                        -- quedo morosa, denuevo Aviso
								END IF	  
							END IF
						END IF
					ELSE 
						CONTINUE FOREACH;				
					END IF

				ELSE

					IF _monto_90 > 0 THEN -- Con Morosidad a 90 Dias (Aviso de Cancelacion)

						LET _tipo_aviso = 1;
						IF _ramo_sis <> 3 THEN -- Las Fianzas no se le Envian Avisos
							IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
								IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
								    CONTINUE FOREACH;           -- les envia Aviso Denuevo
								ELSE
									IF _fecha_ult_pago < _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
										CONTINUE FOREACH;                       -- quedo morosa, denuevo Aviso
									END IF	  
								END IF
							END IF
						ELSE
							CONTINUE FOREACH;
						END IF

					ELSE 

						IF _monto_60 > 0 THEN -- Con Morosidad a 60 Dias (Carta de Recorderis)
							LET _tipo_aviso = 4;
						ELSE
							CONTINUE FOREACH;
						END IF

					END IF

				END IF

			ELSE -- Vencidas (Polizas Vencidas con Saldo)

				IF _carta_vencida_sal = 0 THEN
					LET _tipo_aviso = 3;
				ELSE
					CONTINUE FOREACH;
				END IF

			END IF   

		END IF

		BEGIN
		ON EXCEPTION IN(-268) -- Por si se encuentran polizas que tienen 2 corredores
		END EXCEPTION		  -- y ambos tienen cobradores diferentes asignados

			IF _tipo_aviso = 2 THEN -- Prima Ganada
				LET _ano =	YEAR(_vigencia_inic);
					IF _vigencia_inic IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELIF _tipo_aviso = 3 THEN -- Vencidas con Saldo
				LET _ano =	YEAR(_vigencia_final);
					IF _vigencia_final IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELSE
				LET _ano = 0;
			END IF

			-- Nombres
			SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			SELECT nombre
			  INTO _nombre_cliente
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			SELECT nombre
			  INTO _nombre_acreedor
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			SELECT nombre
			  INTO _nombre_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			SELECT descripcion
			  INTO _nombre_sucursal
			  FROM insagen
			 WHERE codigo_agencia = _cod_sucursal;

			if _cobra_poliza = "1" then  --acreedor. se iguala a c para que les salga a las ejecutivas.
				let _cobra_poliza = "3"; --let _cobra_poliza = "C";
			end if

			INSERT INTO cobaviso(
			cod_cobrador, 
			no_poliza, 
			cod_acreedor, 
			cod_agente,
	        tipo_aviso, 
			prima, 
			monto_letras, 
			imprimir, 
			impreso,
			saldo, 
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90,
			cod_sucursal,
			cod_ramo,
			cod_cliente,
			ano,
			nombre_agente,
			nombre_cliente,
			nombre_acreedor,
			no_documento,
			vigencia_inic,
			vigencia_final,
			cobra_poliza
	        )
			VALUES(
			a_cobrador, 
			_no_poliza, 
			_cod_acreedor, 
			_cod_agente,
	        _tipo_aviso, 
			_prima,    
			'', 
			"0", 
			0,
			_saldo, 
	        _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90,
			_cod_sucursal,
			_cod_ramo,
			_cod_cliente,
			_ano,
			_nombre_agente,
			_nombre_cliente,
			_nombre_acreedor,
			_doc_poliza,
			_vigencia_inic,
			_vigencia_final,
			_cobra_poliza
			);
		END
	END FOREACH
   end if

	UPDATE cobcobra
	   SET fecha_aviso  = a_fecha
	 WHERE cod_cobrador = a_cobrador;

   
else										--******************callcenter*************

   CALL sp_cob156(
   a_compania,
   a_agencia,
   a_fecha
   );

   foreach
		select cod_cobrador
		  into _cod_cobrador
		  from cobcobra
		 where cod_sucursal = a_agencia
		   and activo       = 1
		   and tipo_cobrador in(1,7,8,9)
		 order by cod_cobrador

		DELETE FROM cobaviso
		 WHERE cod_cobrador = _cod_cobrador;
   end foreach

	FOREACH
	 SELECT no_poliza,
			cod_acreedor,
			cod_agente,
			prima_orig,
			saldo,
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90,
			cod_cobrador,
			cod_cliente
	   INTO _no_poliza,
			_cod_acreedor,
			_cod_agente,
			_prima,
			_saldo,
		    _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90,
			_cod_cobrador,
			_cod_cliente
	   FROM tmp_moros
	  WHERE saldo > 0

		LET _fecha_vence =  (a_fecha + 10);

		SELECT vigencia_final,
		       estatus_poliza,
			   carta_aviso_canc,
			   carta_prima_gan,
			   carta_vencida_sal,
			   carta_recorderis,
			   cod_ramo,
			   sucursal_origen,
			   vigencia_inic,
			   no_documento,
			   fecha_suscripcion,
			   fecha_aviso_canc,
			   fecha_ult_pago,
			   cobra_poliza
		  INTO _vigencia_final,
		       _estatus_poliza,
			   _carta_aviso_can,
			   _carta_prima_gan,
			   _carta_vencida_sal,
			   _carta_recorderis,
			   _cod_ramo,
			   _cod_sucursal,
			   _vigencia_inic,
			   _doc_poliza,
			   _fecha_suscripcion,
			   _fecha_carta_canc,
			   _fecha_ult_pago,
			   _cobra_poliza
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	  --Excluye las polizas cuya fecha de vencimiento sean mayores que la vigencia final
	 	IF _vigencia_final <= _fecha_vence AND _saldo <= 0.00 THEN
			IF _ramo_sis <> 5 THEN
				CONTINUE FOREACH;
			END IF
		END IF

		IF _estatus_poliza = 2 THEN -- Polizas Canceladas
			LET _tipo_aviso = 2;
			IF _carta_prima_gan = 1 THEN
				CONTINUE FOREACH;
			END IF
			
		ELSE -- Poliza Activas

			IF _vigencia_final >= a_fecha THEN -- Vigentes

				IF _ramo_sis = 5 THEN -- Las Polizas de Salud se le Envian Avisos a los 30 Dias

					LET _tipo_aviso = 1;
					LET _monto_moros_salud = _monto_30 + _monto_60 + _monto_90;
					IF _monto_moros_salud > 0 THEN
						IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
							IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
							    CONTINUE FOREACH;           -- les envia Aviso Denuevo
							ELSE
								IF _fecha_ult_pago <= _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
									CONTINUE FOREACH;                        -- quedo morosa, denuevo Aviso
								END IF	  
							END IF
						END IF
					ELSE 
						CONTINUE FOREACH;				
					END IF

				ELSE

					IF _monto_90 > 0 THEN -- Con Morosidad a 90 Dias (Aviso de Cancelacion)

						LET _tipo_aviso = 1;
						IF _ramo_sis <> 3 THEN -- Las Fianzas no se le Envian Avisos
							IF _carta_aviso_can = 1 THEN -- Polizas Que Tienen Avisos
								IF _fecha_ult_pago IS NULL THEN -- Polizas que no Han Pagado no se
								    CONTINUE FOREACH;           -- les envia Aviso Denuevo
								ELSE
									IF _fecha_ult_pago < _fecha_carta_canc THEN -- Si la Poliza tuvo algun Pago y
										CONTINUE FOREACH;                       -- quedo morosa, denuevo Aviso
									END IF	  
								END IF
							END IF
						ELSE
							CONTINUE FOREACH;
						END IF

					ELSE 

						IF _monto_60 > 0 THEN -- Con Morosidad a 60 Dias (Carta de Recorderis)
							LET _tipo_aviso = 4;
						ELSE
							CONTINUE FOREACH;
						END IF

					END IF

				END IF

			ELSE -- Vencidas (Polizas Vencidas con Saldo)

				IF _carta_vencida_sal = 0 THEN
					LET _tipo_aviso = 3;
				ELSE
					CONTINUE FOREACH;
				END IF

			END IF   

		END IF

		BEGIN
		ON EXCEPTION IN(-268) -- Por si se encuentran polizas que tienen 2 corredores
		END EXCEPTION		  -- y ambos tienen cobradores diferentes asignados

			IF _tipo_aviso = 2 THEN -- Prima Ganada
				LET _ano =	YEAR(_vigencia_inic);
					IF _vigencia_inic IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELIF _tipo_aviso = 3 THEN -- Vencidas con Saldo
				LET _ano =	YEAR(_vigencia_final);
					IF _vigencia_final IS NULL THEN
						LET _ano =	YEAR(_fecha_suscripcion);
					END IF
			ELSE
				LET _ano = 0;
			END IF

			-- Nombres
			SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			SELECT nombre
			  INTO _nombre_cliente
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			SELECT nombre
			  INTO _nombre_acreedor
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			SELECT nombre
			  INTO _nombre_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			SELECT descripcion
			  INTO _nombre_sucursal
			  FROM insagen
			 WHERE codigo_agencia = _cod_sucursal;

			select count(*)
			  into _dupli
			  from cobaviso
			 where no_poliza = _no_poliza;

			if _dupli = 0 then
			else
				continue foreach;
			end if				  

			INSERT INTO cobaviso(
			cod_cobrador, 
			no_poliza, 
			cod_acreedor, 
			cod_agente,
	        tipo_aviso, 
			prima, 
			monto_letras, 
			imprimir, 
			impreso,
			saldo, 
	        por_vencer, 
			exigible,
	        corriente, 
	        monto_30, 
	        monto_60, 
			monto_90,
			cod_sucursal,
			cod_ramo,
			cod_cliente,
			ano,
			nombre_agente,
			nombre_cliente,
			nombre_acreedor,
			no_documento,
			vigencia_inic,
			vigencia_final,
			cobra_poliza
	        )
			VALUES(
			_cod_cobrador, 
			_no_poliza, 
			_cod_acreedor, 
			_cod_agente,
	        _tipo_aviso, 
			_prima,    
			'', 
			"0", 
			0,
			_saldo, 
	        _por_vencer, 
			_exigible,
	        _corriente, 
	        _monto_30, 
	        _monto_60, 
			_monto_90,
			_cod_sucursal,
			_cod_ramo,
			_cod_cliente,
			_ano,
			_nombre_agente,
			_nombre_cliente,
			_nombre_acreedor,
			_doc_poliza,
			_vigencia_inic,
			_vigencia_final,
		    _cobra_poliza
			);
		END
	END FOREACH

   foreach
		select cod_cobrador
		  into _cod_cobrador
		  from cobcobra
		 where cod_sucursal = a_agencia
		   and activo       = 1
		   and tipo_cobrador in(1,7,8,9)
		 order by cod_cobrador

		UPDATE cobcobra
		   SET fecha_aviso  = a_fecha
		 WHERE cod_cobrador = _cod_cobrador;

   end foreach

end if

DROP TABLE tmp_moros;

END PROCEDURE;
