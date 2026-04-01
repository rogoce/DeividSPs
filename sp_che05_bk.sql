-- Procedimiento que Genera el Proceso Intermedio de Seleccion
-- de a cuales corredores se generaran los cheques  

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2005 - Autor: Amado Perez Mendoza
-- Modificado: 23/05/2007 - Autor: Amado Perez Mendoza
--                                 Se busca los saldo arrastre de agtsalra y se insertan en tmp_ramo

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che05;

CREATE PROCEDURE sp_che05(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE
) RETURNING SMALLINT,	-- Generar Cheque
			CHAR(50),   -- Agente
			DEC(16,2),	-- Comision Total
			DEC(16,2),	-- Comision	Periodo
			DEC(16,2),	-- Comision	Arrastre
			CHAR(5),	-- Codigo Corredor
			SMALLINT,   -- Tipo de pago
			CHAR(17),	-- Codigo de cuenta
			DEC(16,2);  -- Deuda 
			
DEFINE v_generar_chq    SMALLINT; 
DEFINE v_nombre_agt     CHAR(50); 
DEFINE v_comision       DEC(16,2);
DEFINE v_comis_periodo  DEC(16,2);
DEFINE v_comis_arrastre DEC(16,2);
DEFINE v_cod_cuenta     CHAR(17);
DEFINE v_alias     		CHAR(50);
DEFINE v_deuda_tot		DEC(16,2);

DEFINE _cod_agente      CHAR(5);  
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _monto_minimo    DEC(16,2);
DEFINE _tipo_pago       SMALLINT; 
DEFINE _quincena     	SMALLINT;
DEFINE _deuda			DEC(16,2);
DEFINE _cant_reg        INTEGER;

DEFINE _comis_desc		DEC(16,2);
DEFINE _saldo           DEC(16,2);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che05.trc";
--TRACE ON;

--DROP TABLE tmp_ramo;

CREATE TEMP TABLE tmp_ramo(
	cod_agente		CHAR(5),
	cod_ramo		CHAR(3),
	comision		DEC(16,2),
	PRIMARY KEY (cod_agente, cod_ramo)
	) WITH NO LOG;

SELECT chq_monto_min
  INTO _monto_minimo
  FROM parparam
 WHERE cod_compania = a_compania;

IF _monto_minimo IS NULL THEN
	LET _monto_minimo = 0;
END IF

IF DAY(a_fecha_desde) < 16 THEN
   LET _quincena = 1;
ELSE	
   LET _quincena = 2;
END IF

-- Genera los registros de las comisiones

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
1
);

-- Genera el archivo para las comisiones de Ducruet

execute procedure sp_che28(a_fecha_desde, a_fecha_hasta);

-- Genera archivo para envio de correos en ach

execute procedure sp_che35(a_fecha_desde, a_fecha_hasta);

-- Genera el intermedio de los cheques

LET _comis_desc = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		comision
   INTO	_cod_agente,
   		_no_poliza,
		v_comision
   FROM	tmp_agente
  WHERE no_poliza <> '00000'

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre,
		   generar_cheque,
		   saldo
	  INTO v_nombre_agt,
	  	   v_generar_chq,
		   v_comis_arrastre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 	   		   	

	BEGIN

		ON EXCEPTION IN(-239)

			UPDATE tmp_ramo
			   SET comision   = comision + v_comision
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;

		END EXCEPTION

		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		_cod_ramo,
		v_comision
		);

	END

END FOREACH

--Buscando los arrastres del corredor y agregarlos en tmp_ramo
FOREACH
    SELECT cod_agente
	  INTO _cod_agente
	  FROM tmp_agente
	GROUP BY cod_agente

    FOREACH
		SELECT monto,
		       cod_ramo
		  INTO _saldo,
		       _cod_ramo
		  FROM agtsalra
		 WHERE cod_agente = _cod_agente

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF

		BEGIN

			ON EXCEPTION IN(-239)

				UPDATE tmp_ramo
				   SET comision   = comision + _saldo
				 WHERE cod_agente = _cod_agente
				   AND cod_ramo   = _cod_ramo;

			END EXCEPTION

			INSERT INTO tmp_ramo(
			cod_agente,
			cod_ramo,
			comision
			)
			VALUES(
			_cod_agente,
			_cod_ramo,
			_saldo
			);

		END

	END FOREACH

END FOREACH

FOREACH  --Comision Descontada
 SELECT SUM(comision),
		cod_agente
   INTO _comis_desc,
		_cod_agente
   FROM tmp_agente
  WHERE no_poliza = '00000'
  GROUP BY cod_agente

	LET _comis_desc = _comis_desc * -1;
	LET _cant_reg = 0;

   SELECT COUNT(*)
     INTO _cant_reg
	 FROM tmp_ramo
	WHERE cod_agente = _cod_agente;

   IF _cant_reg IS NULL THEN
   	LET _cant_reg = 0;
   END IF

   IF _cant_reg > 0 THEN
	   FOREACH		
		SELECT comision,
			   cod_ramo	
		  INTO v_comision,
		       _cod_ramo   
		  FROM tmp_ramo
		 WHERE cod_agente = _cod_agente
		 ORDER BY cod_ramo

			IF _comis_desc = 0 THEN
				EXIT FOREACH;
			ELSE
				IF _comis_desc >= v_comision THEN
					UPDATE tmp_ramo
					   SET comision   = 0
					 WHERE cod_agente = _cod_agente
					   AND cod_ramo   = _cod_ramo;
					LET _comis_desc   = _comis_desc - v_comision;
				ELSE
					UPDATE tmp_ramo
					   SET comision   = comision - _comis_desc
					 WHERE cod_agente = _cod_agente
					   AND cod_ramo   = _cod_ramo;
					LET _comis_desc   = 0;
				END IF
			END IF

		END FOREACH

        SELECT SUM(comision)
		  INTO v_comision
		  FROM tmp_ramo
		 WHERE cod_agente = _cod_agente;

        IF v_comision = 0 AND _comis_desc > 0 THEN
			FOREACH
				SELECT cod_ramo
				  INTO _cod_ramo
				  FROM tmp_ramo
				 WHERE cod_agente = _cod_agente
				   AND comision   = 0
				 EXIT FOREACH;
			END FOREACH

			UPDATE tmp_ramo
			   SET comision   = _comis_desc * -1
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;
        END IF 

	ELSE
		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		'002',
		_comis_desc * -1
		);
	END IF

--	DELETE FROM tmp_ramo
--	 WHERE cod_agente = _cod_agente
--	   AND comision   = 0; 

END FOREACH

FOREACH
 SELECT SUM(comision),
		cod_agente
   INTO v_comis_periodo,
		_cod_agente
   FROM tmp_ramo
  GROUP BY cod_agente

	SELECT nombre,
		   generar_cheque,
		   saldo,
		   tipo_pago,
		   cod_cuenta,
		   alias
	  INTO v_nombre_agt,
	  	   v_generar_chq,
		   v_comis_arrastre,
		   _tipo_pago,
		   v_cod_cuenta,
		   v_alias
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 	   		   	

    LET _deuda	= 0;
	LET v_deuda_tot = 0;

	SELECT sum(monto)
	  INTO _deuda
	  FROM agtdeuda
	 WHERE quincena = 0
	   AND cod_agente = _cod_agente;

	LET v_deuda_tot = v_deuda_tot + _deuda; 

 	IF _quincena = 1 THEN
		SELECT SUM(monto)
		  INTO _deuda
		  FROM agtdeuda
		 WHERE cod_agente = _cod_agente
		   AND quincena = 1;
	ELIF _quincena = 2 THEN
		SELECT SUM(monto)
		  INTO _deuda
		  FROM agtdeuda
		 WHERE cod_agente = _cod_agente
		   AND quincena = 2;
	END IF
  
	LET v_deuda_tot = v_deuda_tot + _deuda; 
  
	LET v_comision = v_comis_periodo;
--	LET v_comision = v_comis_arrastre + v_comis_periodo;

	IF v_comision <= 0 THEN
		LET v_generar_chq = 0;
	END IF

	IF _tipo_pago <> 1 THEN	 -- Pregunta si no es ACH
		IF v_comision < _monto_minimo THEN
			LET v_generar_chq = 0;
		END IF
	END IF

	IF TRIM(v_nombre_agt[1,7]) = "DIRECTO" THEN
		LET v_nombre_agt = v_alias;
	END IF

	RETURN  v_generar_chq,
			v_nombre_agt,
			v_comision,
			v_comis_periodo - v_comis_arrastre,
			v_comis_arrastre,
			_cod_agente,
			_tipo_pago,
			v_cod_cuenta,
			v_deuda_tot
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;

END PROCEDURE;