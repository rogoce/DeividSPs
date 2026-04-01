-- Procedimiento que Carga el Siniestros Incurridos Cedidos (Excluyendo salvamento y Deducible en Detalle)
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/12/2000 - Autor: Yinia M. Zamora--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec44;

CREATE PROCEDURE "informix".sp_rec44(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_reaseguradora CHAR(255) DEFAULT "*") RETURNING CHAR(18),CHAR(20),CHAR(50),DATE,DATE,DEC(16,2),CHAR(50),CHAR(50),CHAR(50),CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);
DEFINE _doc_reclamo    CHAR(18);

DEFINE _monto_total,_monto_variacion   DECIMAL(16,2);
DEFINE _monto_bruto,_variacion_neta    DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _pagado_neto     DECIMAL(16,2);
DEFINE _reserva_neto    DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas,_porc_reas1       DECIMAL;

DEFINE _cod_coasegur,v_cod_coasegur   CHAR(3);

DEFINE _no_reclamo,_transaccion  CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo,_cod_contrato       CHAR(5);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_cliente      CHAR(10);
DEFINE _tipo_transaccion SMALLINT;
DEFINE _tipo_contrato    CHAR(1);
DEFINE _nombre_contrato,v_cliente_nombre,v_ramo_nombre,
       v_compania_nombre,v_nombre_reasegur   CHAR(50);
DEFINE _fecha_siniestro,_fecha_reclamo  DATE;


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);


-- Tabla Temporal


CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
	    cod_cliente          CHAR(10)  NOT NULL,
		cod_contrato         CHAR(05)  NOT NULL,
		cod_coasegur         CHAR(03),
		tipo_transaccion     SMALLINT,
		tipo_contrato        CHAR(1),
		fecha_reclamo        DATE,
		fecha_siniestro      DATE,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		transaccion          CHAR(10)  NOT NULL,
	  	pagado_neto          DEC(16,2) NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		doc_poliza           CHAR(20)  NOT NULL,
		PRIMARY KEY (no_reclamo,transaccion,cod_coasegur)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);
CREATE INDEX xie08_tmp_sinis ON tmp_sinis(tipo_contrato);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
LET _pagado_neto = 0;


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT a.no_reclamo,
 		a.monto,
	    a.cod_sucursal,
		a.transaccion,
		a.fecha,
		b.tipo_transaccion
   INTO _no_reclamo,
   		_monto_total,
	   _cod_sucursal,
	   _transaccion,
	   _fecha_reclamo,
	   _tipo_transaccion
  FROM rectrmae a,rectitra b
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
    AND a.cod_tipotran = b.cod_tipotran
    AND b.tipo_transaccion = 4
    AND a.periodo BETWEEN a_periodo1 AND a_periodo2
    AND a.monto   <> 0

	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
	       fecha_siniestro,
	       numrecla,
	       periodo,
		   cod_reclamante
	  INTO _no_poliza,
	       _fecha_siniestro,
	       _numrecla,
		   _periodo,
		   _cod_cliente
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Informacion de Polizas

	SELECT cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento
	  INTO _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza
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

    LET _monto_bruto     = _monto_total / 100 * _porc_coas;

	-- Informacion de Reaseguro

   FOREACH
    SELECT recreaco.cod_contrato,recreaco.porc_partic_suma,
	       reacomae.tipo_contrato
	  INTO _cod_contrato,_porc_reas,_tipo_contrato
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 3

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;

	IF _porc_reas = 0 THEN
	   CONTINUE FOREACH;
	END IF

	-- Calculos

	LET _monto_bruto    = _monto_bruto     / 100 * _porc_reas;
	
	   FOREACH
	      SELECT recreafa.porc_partic_reas,recreafa.cod_coasegur
	   	   INTO  _porc_reas1,v_cod_coasegur
	       FROM  recreaco,recreafa
     	  WHERE  recreaco.no_reclamo     = _no_reclamo
		    AND  recreaco.no_reclamo     = recreafa.no_reclamo
	        AND  recreaco.cod_contrato   = recreafa.cod_contrato
	
          IF _porc_reas1 IS NULL THEN
	         LET _porc_reas1 = 0;
          END IF;

	      IF _porc_reas1 = 0 THEN
	         CONTINUE FOREACH;
	      END IF

    	-- Calculos

		    LET _pagado_neto    = _monto_bruto     / 100 * _porc_reas1;

			-- Actualizacion del Movimiento

			BEGIN
			ON EXCEPTION IN(-239)

				UPDATE tmp_sinis
				   SET pagado_neto     = pagado_neto   + _pagado_neto
				 WHERE no_reclamo      = _no_reclamo
				   AND transaccion     = _transaccion
				   AND cod_coasegur    = v_cod_coasegur; 

			END EXCEPTION

			INSERT INTO tmp_sinis(
		   	pagado_neto,
			no_reclamo,
			no_poliza,
			cod_ramo,
			periodo,
			numrecla,
			transaccion,
			cod_grupo,
			cod_sucursal,
			cod_subramo,
			cod_cliente,
			cod_contrato,
			cod_coasegur,
			tipo_transaccion,
			tipo_contrato,
			fecha_reclamo,
			fecha_siniestro,
			doc_poliza
		   		    )
			VALUES(
			_pagado_neto,
		    _no_reclamo,
			_no_poliza,
			_cod_ramo,
			_periodo,
			_numrecla,
			_transaccion,
			_cod_grupo,
			_cod_sucursal,
			_cod_subramo,
			_cod_cliente,
			_cod_contrato,
			v_cod_coasegur,
			_tipo_transaccion,
			_tipo_contrato,
			_fecha_reclamo,
			_fecha_siniestro,
			_doc_poliza
		   	);

		END
		END FOREACH
		LET _pagado_neto = 0;
		LET _monto_total = 0;
	
	END FOREACH

END FOREACH

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


{IF a_tipo_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Tipo Contrato : " ||  TRIM(a_tipo_contrato);

	LET _tipo = sp_sis04(a_tipo_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_contrato NOT IN (SELECT codigo FROM tmp_codigos);

   END IF		        -- (E) Excluir estos Registros

   DROP TABLE tmp_codigos;

END IF }
IF a_reaseguradora <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Reasegurdora: " ||  TRIM(a_reaseguradora);

	LET _tipo = sp_sis04(a_reaseguradora);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT no_reclamo,
 		no_poliza,
		cod_ramo,
		cod_cliente,
		fecha_reclamo,
		fecha_siniestro,
		pagado_neto,
 	   	periodo,
		numrecla,
		transaccion,
		tipo_transaccion,
		tipo_contrato,
		doc_poliza,
		cod_coasegur

   INTO	_no_reclamo,
   		_no_poliza,	
		_cod_ramo,
		_cod_cliente,
		_fecha_reclamo,
		_fecha_siniestro,
	    _pagado_neto,
		_periodo,
		_doc_reclamo,
	   	_transaccion,
		_tipo_transaccion,
		_tipo_contrato,
		_doc_poliza,
		_cod_coasegur
   FROM tmp_sinis
  WHERE seleccionado = 1

   	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

  	SELECT nombre
	  INTO v_cliente_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;


    SELECT nombre
           INTO v_nombre_reasegur
           FROM emicoase
          WHERE cod_coasegur = _cod_coasegur;

    RETURN _doc_reclamo,
	       _doc_poliza,
	 	   v_cliente_nombre,
	 	   _fecha_siniestro,
		   _fecha_reclamo,
		   _pagado_neto,
	 	   v_ramo_nombre,
		   v_nombre_reasegur,
		   v_compania_nombre,
		   v_filtros
		  WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;


END PROCEDURE;
