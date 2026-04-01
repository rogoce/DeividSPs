-- Procedimiento que Genera el Proceso Intermedio de Seleccion
-- de a cuales corredores se generaran los cheques  

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che42;

CREATE PROCEDURE sp_che42(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_fecha_hasta2 DATE, a_agente CHAR(5)) 
RETURNING   SMALLINT,	-- Generar Cheque
			CHAR(50),   -- Agente
			DEC(16,2),	-- Comision	Periodo
			CHAR(5),	-- Codigo Corredor
			SMALLINT,   -- Tipo de pago
			CHAR(17);	-- Codigo de cuenta
			
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

DEFINE _comis_desc		DEC(16,2);

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

IF DAY(a_fecha_desde) < 15 THEN
   LET _quincena = 1;
ELSE	
   LET _quincena = 2;
END IF

-- Genera los registros de las comisiones

CALL sp_che43(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
a_agente,
0
);


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
    AND cod_agente = a_agente

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

FOREACH 
 SELECT SUM(comision),
		cod_agente
   INTO _comis_desc,
		_cod_agente
   FROM tmp_agente
  WHERE no_poliza = '00000'
    AND cod_agente = a_agente
  GROUP BY cod_agente

	LET _comis_desc = _comis_desc * -1;

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

	DELETE FROM tmp_ramo
	 WHERE cod_agente = _cod_agente
	   AND comision   = 0; 

END FOREACH

FOREACH
 SELECT SUM(comision),
		cod_agente,
		cod_ramo
   INTO v_comis_periodo,
		_cod_agente,
		_cod_ramo
   FROM tmp_ramo
  GROUP BY cod_agente, cod_ramo

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
  
 --	LET v_comision = v_comis_arrastre + v_comis_periodo;

 --	IF _tipo_pago <> 1 THEN	 -- Pregunta si no es ACH
 --	IF v_comis_periodo < _monto_minimo THEN

		BEGIN

			ON EXCEPTION IN(-239,-268)

				UPDATE agtsalhi
				   SET monto      = monto + v_comis_periodo
				 WHERE cod_agente = _cod_agente
				   AND cod_ramo   = _cod_ramo
				   AND fecha_al   = a_fecha_hasta2;

			END EXCEPTION

			INSERT INTO agtsalhi(
			cod_agente,
			cod_ramo,
			monto,
			fecha_al,
			fecha_desde,
			fecha_hasta
			)
			VALUES(
			_cod_agente,
			_cod_ramo,
			v_comis_periodo,
			a_fecha_hasta2,
			a_fecha_desde,
			a_fecha_hasta
			);

		END

--	END IF

	RETURN  v_generar_chq,
			v_nombre_agt,
			v_comis_periodo,
			_cod_agente,
			_tipo_pago,
			_cod_ramo
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;
DROP TABLE tmp_ramo;

END PROCEDURE;