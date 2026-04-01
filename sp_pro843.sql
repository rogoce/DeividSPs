-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 06/12/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro843;

CREATE PROCEDURE "informix".sp_pro843(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2	CHAR(7),
		a_poliza    CHAR(10),
		a_sucursal  CHAR(255) DEFAULT "*",
		a_grupo     CHAR(255) DEFAULT "*",
		a_ramo      CHAR(255) DEFAULT "*",
		a_agente    CHAR(255) DEFAULT "*",
		a_ajustador CHAR(255) DEFAULT "*",
		a_evento    CHAR(255) DEFAULT "*",
		a_suceso    CHAR(255) DEFAULT "*"
		) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo     CHAR(50);
DEFINE v_codigo         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,r_no_reclamo CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _cod_acreedor    CHAR(5);
DEFINE _incurrido_poliza, _incurrido_retencion, _incurrido_contrato DEC(16,2);
DEFINE _incurrido_facultativo, _incurrido_total  DEC(16,2);
DEFINE _tipo_contrato   SMALLINT;
DEFINE _no_tranrec      CHAR(10);


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		periodo              CHAR(7) NOT NULL,
		no_tranrec			 char(10)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
		ajust_interno   	 CHAR(3)   NOT NULL,
		cod_evento     	     CHAR(3)   NOT NULL,
		cod_suceso     	     CHAR(3),
		cod_cliente          CHAR(10)  NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		posible_recobro		 INT       NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		doc_poliza           CHAR(20)  NOT NULL,
		cod_acreedor		 CHAR(5),
		PRIMARY KEY (no_reclamo, periodo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);
CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);
CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH
  SELECT no_reclamo
    INTO r_no_reclamo
	FROM recrcmae
   WHERE no_poliza = a_poliza

	FOREACH
	 SELECT no_reclamo,
	 		monto,
			periodo,
			no_tranrec
	   INTO _no_reclamo,	
	   		_monto_total,
			_periodo,
			_no_tranrec
	   FROM rectrmae
	  WHERE cod_compania = a_compania
	    AND actualizado  = 1
		AND cod_tipotran IN ('004','005','006','007')
		AND periodo      <= a_periodo2
		AND periodo		 >= a_periodo1
	    AND monto        <> 0
		AND no_reclamo = r_no_reclamo
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

		SELECT porc_partic_suma
		  INTO _porc_reas
		  FROM rectrrea
		 WHERE no_tranrec    = _no_tranrec
		   AND tipo_contrato = 1;

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		-- Calculos

		LET _monto_bruto = _monto_total / 100 * _porc_coas;
		LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

		-- Actualizacion del Movimiento

		INSERT INTO tmp_incurrido(
		no_reclamo,
		pagado_total,
		pagado_bruto,
		pagado_neto,
		periodo,
		no_tranrec
		)
		VALUES(
		_no_reclamo,
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_periodo,
		_no_tranrec
		);

	END FOREACH

	-- Variacion de Reserva

	LET _monto_total = 0;
	LET _monto_bruto = 0;
	LET _monto_neto  = 0;
	LET _porc_reas = 0;
	LET _porc_coas = 0;

	FOREACH 
	 SELECT no_reclamo,	
	 		variacion,
			periodo,
			no_tranrec
	   INTO _no_reclamo,	
	   		_monto_total,
			_periodo,
			_no_tranrec
	   FROM rectrmae
	  WHERE cod_compania = a_compania
	    AND actualizado  = 1
	    AND cod_tipotran MATCHES '*' -- Para que incluya el indice creado
		AND periodo      >= a_periodo1 
		AND periodo      <= a_periodo2
	    AND variacion    <> 0
		AND no_reclamo   = r_no_reclamo

		-- Informacion de Coaseguro

		SELECT porc_partic_coas
		  INTO _porc_coas
	      FROM reccoas
	     WHERE no_reclamo   = _no_reclamo
	       AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		-- Informacion de Reaseguro

		SELECT porc_partic_suma
		  INTO _porc_reas
		  FROM rectrrea
		 WHERE no_tranrec    = _no_tranrec
		   AND tipo_contrato = 1;

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;
	 
		-- Calculos

		LET _monto_bruto = _monto_total / 100 * _porc_coas;
		LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

		-- Actualizacion del Movimiento

		INSERT INTO tmp_incurrido(
		no_reclamo,
		reserva_total,
		reserva_bruto,
		reserva_neto,
		periodo,
		no_tranrec
		)
		VALUES(
		_no_reclamo,
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_periodo,
		_no_tranrec
		);

	END FOREACH
END FOREACH

BEGIN

DEFINE _pagado_total  DEC(16,2);
DEFINE _pagado_bruto  DEC(16,2);
DEFINE _pagado_neto   DEC(16,2);
DEFINE _reserva_total DEC(16,2);
DEFINE _reserva_bruto DEC(16,2);
DEFINE _reserva_neto  DEC(16,2);

FOREACH 
 SELECT no_reclamo,	
        periodo,
        SUM(pagado_total),
		SUM(pagado_bruto),
		SUM(pagado_neto),
		SUM(reserva_total),
		SUM(reserva_bruto),
		SUM(reserva_neto)
   INTO _no_reclamo,	
        _periodo,
        _pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_reserva_total,
		_reserva_bruto,
		_reserva_neto
   FROM tmp_incurrido
  GROUP BY no_reclamo, periodo
  
  	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  INTO _no_poliza,
	       _numrecla,
		   _ajust_interno,
		   _cod_evento,
		   _cod_suceso,
		   _posible_recobro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Informacion de Polizas

	SELECT cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento,
		   cod_sucursal
	  INTO _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza,
		   _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET _cod_acreedor = '';

	FOREACH
	 SELECT cod_acreedor, no_unidad  
	   INTO _cod_acreedor, _no_unidad
	   FROM emipoacr
	  WHERE no_poliza = _no_poliza
	  ORDER BY no_unidad
		EXIT FOREACH;
	END FOREACH

	INSERT INTO tmp_sinis(
	no_reclamo,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	no_poliza,
	periodo,
	numrecla,
	ajust_interno,
	cod_evento,
	cod_suceso,
	posible_recobro,
	cod_ramo,
	cod_grupo,
	cod_subramo,
	cod_cliente,
	doc_poliza,
	cod_sucursal,
	incurrido_total,
	incurrido_bruto,
	incurrido_neto,
	seleccionado,
	cod_acreedor
	)
	VALUES(
	_no_reclamo,
	_pagado_total,
	_pagado_bruto,
	_pagado_neto,
	_reserva_total,
	_reserva_bruto,
	_reserva_neto,
	_no_poliza,
	_periodo,
	_numrecla,
	_ajust_interno,
	_cod_evento,
	_cod_suceso,
	_posible_recobro,
	_cod_ramo,
	_cod_grupo,
	_cod_subramo,
	_cod_cliente,
	_doc_poliza,
	_cod_sucursal,
	0,
	0,
	0,
	1,
	_cod_acreedor
	);

END FOREACH

END 

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

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT cligrupo.nombre,tmp_codigos.codigo
	      INTO v_desc_grupo,v_codigo
	      FROM cligrupo,tmp_codigos
	     WHERE cligrupo.cod_grupo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
    END FOREACH

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

IF a_evento <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Evento: " ||  TRIM(a_evento);

	LET _tipo = sp_sis04(a_evento);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_suceso <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Suceso: " ||  TRIM(a_suceso);

	LET _tipo = sp_sis04(a_suceso);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_suceso NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_suceso IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

LET _incurrido_poliza      = 0;
LET _incurrido_retencion   = 0;
LET _incurrido_contrato    = 0;
LET _incurrido_facultativo = 0;

FOREACH
    SELECT (pagado_bruto + reserva_bruto),
	       no_tranrec
	  INTO _incurrido_total,
	       _no_reclamo
	  FROM tmp_sinis

    LET _incurrido_poliza = _incurrido_poliza + _incurrido_total;

	FOREACH  
		SELECT porc_partic_suma,
		  	   tipo_contrato
		  INTO _porc_reas,
		       _tipo_contrato
		  FROM rectrrea
		 WHERE no_tranrec = _no_reclamo

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF;

		    IF _tipo_contrato = 1  THEN
			   LET _incurrido_retencion = _incurrido_retencion + _incurrido_total * _porc_reas /100;
			ELIF _tipo_contrato = 3	THEN
			   LET _incurrido_facultativo = _incurrido_facultativo + _incurrido_total * _porc_reas /100;
			ELSE
			   LET _incurrido_contrato = _incurrido_contrato + _incurrido_total * _porc_reas /100;
			END IF

	END FOREACH

END FOREACH

UPDATE tmp_contratos
   SET incurrido        = _incurrido_poliza,      
	   incu_retencion   = _incurrido_retencion, 
	   incu_contrato    = _incurrido_contrato,
	   incu_facultativo	= _incurrido_facultativo
 WHERE no_poliza        = a_poliza;

DROP TABLE tmp_incurrido;
drop table tmp_sinis;

RETURN v_filtros;


END PROCEDURE;
