-- Procedimiento que Carga los Reclamos Pendientes
-- en un Periodo Dado
-- 
-- Creado    : 05/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Agregando el filtro de Agentes)
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec02_old;

CREATE PROCEDURE "informix".sp_rec02_old(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo   CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_grupo     CHAR(255) DEFAULT "*",
a_ramo      CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(255);

-- Variables para Filtros

DEFINE v_filtros     CHAR(255);
DEFINE _tipo         CHAR(1);

-- Variable del Procedure

DEFINE _monto_total  	DECIMAL(16,2);
DEFINE _monto_bruto  	DECIMAL(16,2);
DEFINE _monto_neto   	DECIMAL(16,2);
DEFINE _porc_coas    	DECIMAL;
DEFINE _porc_reas    	DECIMAL;

DEFINE _cod_coasegur 	CHAR(3);

DEFINE _no_reclamo   	CHAR(10);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _periodo      	CHAR(7);
DEFINE _numrecla     	CHAR(18);
DEFINE _cod_sucursal 	CHAR(3);
DEFINE _cod_ramo     	CHAR(3);
DEFINE _cod_grupo    	CHAR(5);
DEFINE _fecha           DATE;
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_agente      CHAR(5);


--SET DEBUG FILE TO "sp_rec02.trc ";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18) ,
		ultima_fecha         DATE      NOT NULL,
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
  		ajust_interno        CHAR(3),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);

CREATE TEMP TABLE tmp_agente(
        no_reclamo            CHAR(10)  NOT NULL,
	    cod_agente            CHAR(5)   NOT NULL,
	    seleccionado		  SMALLINT  DEFAULT 1 NOT NULL
	    ) WITH NO LOG;


---Variacion de Reserva
 
LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;


SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
 SELECT no_reclamo,		
        SUM(variacion)
   INTO _no_reclamo,	
        _monto_total
   FROM rectrmae 
  WHERE cod_compania = a_compania
    AND periodo     <= a_periodo 
	AND actualizado  = 1
--	and numrecla     = "02-0302-00270-01"
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 

-- Ultima Fecha de Transaccion

	 SELECT MAX(fecha)
	   INTO _fecha
	   FROM rectrmae
	  WHERE no_reclamo   = _no_reclamo
	    AND cod_compania = a_compania
	    AND periodo     <= a_periodo;

	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
		   periodo,
		   numrecla,
  		   ajust_interno
	  INTO _no_poliza,
	  	   _periodo,	
	  	   _numrecla,
		   _ajust_interno
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	
	IF _no_poliza IS NULL THEN
		CONTINUE FOREACH;
	END IF
    IF _numrecla = "00-0000-00000-00" THEN
	   CONTINUE FOREACH;
	END IF;
 
	-- Informacion de Polizas

	SELECT cod_ramo,
	       cod_grupo,
		   cod_sucursal
	  INTO _cod_ramo,	
	  	   _cod_grupo,
		   _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Informacion de Coseguro
 
	SELECT porc_partic_coas 
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	-- Informacion de Reaseguro

	LET _porc_reas = NULL;

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		EXIT FOREACH;

    END FOREACH

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;
 
	-- Actualizacion del Movimiento

	INSERT INTO tmp_sinis(
	pagado_total, 
	pagado_bruto,	
	pagado_neto,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	incurrido_total,	
	incurrido_bruto,
	incurrido_neto,
	no_reclamo,
	no_poliza,
	cod_ramo,
	periodo,	
	numrecla,	
	cod_grupo,
	ultima_fecha,
	cod_sucursal,
  	ajust_interno
	)
	VALUES(
	0,	
	0,
	0,
	_monto_total,	
	_monto_bruto,	
	_monto_neto,
	0,
	0,
	0,
	_no_reclamo,
	_no_poliza,	
	_cod_ramo,
	_periodo,	
	_numrecla,
	_cod_grupo,
	_fecha,
	_cod_sucursal,
	_ajust_interno
	);

    BEGIN
		FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

			INSERT INTO tmp_agente(
			no_reclamo,   
			cod_agente,   
			seleccionado 
			)
			VALUES(
			_no_reclamo,      
			_cod_agente, 
			1       
			);
		END FOREACH
	END

END FOREACH

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH WITH HOLD
 SELECT no_reclamo
   INTO _no_reclamo
   FROM tmp_sinis

 SELECT SUM(monto)
   INTO _monto_total
   FROM rectrmae
  WHERE no_reclamo   = _no_reclamo
    AND cod_compania = a_compania
    AND cod_tipotran IN (4,5,6,7) 
    AND periodo     <= a_periodo;

	IF _monto_total IS NULL THEN
		LET _monto_total = 0;
	END IF

	-- Informacion de Coseguro
 
    FOREACH
	SELECT porc_partic_coas 
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

	    EXIT FOREACH;
    END FOREACH

	-- Informacion de Reaseguro

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF

		EXIT FOREACH;

    END FOREACH

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	UPDATE tmp_sinis
	   SET pagado_total = _monto_total,
	       pagado_bruto = _monto_bruto,
	       pagado_neto  = _monto_neto
	 WHERE no_reclamo   = _no_reclamo;

END FOREACH

-- Actualizacion del Incurrido

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;
 
-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
IF a_ajustador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ajustador: " ||  TRIM(a_ajustador);

	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Agente: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_reclamo IN (SELECT no_reclamo FROM tmp_agente WHERE seleccionado = 0);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_reclamo IN (SELECT no_reclamo FROM tmp_agente WHERE seleccionado = 0);

	END IF

	DROP TABLE tmp_codigos;


END IF

DROP TABLE tmp_agente;


RETURN v_filtros;

END PROCEDURE;
