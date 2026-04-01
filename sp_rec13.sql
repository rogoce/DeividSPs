-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 15/09/2000 - Autor: Yinia M. Zamora
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec13;

CREATE PROCEDURE "informix".sp_rec13(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7),
		a_sucursal  CHAR(255) DEFAULT "*",
		a_grupo     CHAR(255) DEFAULT "*",
		a_ramo      CHAR(255) DEFAULT "*"
		) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _vperiodo        CHAR(7);
DEFINE _numrecla        CHAR(18);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE v_saber          CHAR(2);
DEFINE v_desc_grupo,v_desc_ramo  CHAR(50);
DEFINE v_codigo         CHAR(5);
DEFINE _tipo            CHAR(1);

-- Tabla Temporal

--DROP TABLE tmp_siniestro;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_sinis1(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo            CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		pagado_total         DEC(16,2) NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo,periodo)
		) WITH NO LOG;

CREATE INDEX ie01_tmp_sinis1 ON tmp_sinis1(cod_sucursal);
CREATE INDEX ie02_tmp_sinis1 ON tmp_sinis1(cod_grupo);
CREATE INDEX ie03_tmp_sinis1 ON tmp_sinis1(cod_ramo);
CREATE INDEX ie04_tmp_sinis1 ON tmp_sinis1(no_poliza);

LET _monto_total = 0;

FOREACH WITH HOLD
 SELECT no_reclamo,periodo,SUM(monto)
   INTO _no_reclamo,_vperiodo,_monto_total
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND cod_tipotran IN (4,5,6,7)
    AND (periodo      >= a_periodo1 
    AND	 periodo      <= a_periodo2)
  GROUP BY no_reclamo,periodo
 HAVING SUM(monto) <> 0

	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
	       numrecla
	  INTO _no_poliza,
	       _numrecla
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Informacion de Polizas

	SELECT cod_ramo,
           cod_grupo,
		   cod_sucursal
	  INTO _cod_ramo,
	       _cod_grupo,
		   _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_sinis1(
	pagado_total,
	no_reclamo,
	no_poliza,
	cod_ramo,
	periodo,
	numrecla,
	cod_grupo,
	cod_sucursal,
    seleccionado
	)
	VALUES(
	_monto_total,
	_no_reclamo,
	_no_poliza,
	_cod_ramo,
	_vperiodo,
	_numrecla,
	_cod_grupo,
	_cod_sucursal,
        1
	);

END FOREACH
-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);
        -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; -- ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);
        -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis1
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

	LET v_filtros = TRIM(v_filtros) || " Ramo: "; --||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT prdramo.nombre,tmp_codigos.codigo
	      INTO v_desc_ramo,v_codigo
	      FROM prdramo,tmp_codigos
	     WHERE prdramo.cod_ramo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || TRIM(v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF
RETURN v_filtros;

END PROCEDURE;
