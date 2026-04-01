-- Procedimiento que Carga el Siniestros Incurridos Contrato Incluyendo pagos, recuperos, salvamento y Deducible)
-- En un Periodo Dado  -- COPIA DE sp_rec61
-- Creado    : 05/12/2001 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec708_1;
CREATE PROCEDURE "informix".sp_rec708_1(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_ajustador CHAR(255) DEFAULT "*",a_evento CHAR(255) DEFAULT "*",a_suceso CHAR(255) DEFAULT "*",a_tipo_contrato CHAR(255) DEFAULT "*") RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total,_monto_variacion   DECIMAL(16,2);
DEFINE _monto_bruto,_variacion_neta    DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _pagado_neto     DECIMAL(16,2);
DEFINE _reserva_neto    DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,_transaccion  CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo,_cod_contrato       CHAR(5);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _ajust_interno    CHAR(3);
DEFINE _cod_evento       CHAR(3);
DEFINE _cod_suceso       CHAR(3);
DEFINE _cod_cliente      CHAR(10);
DEFINE _posible_recobro  INT;
DEFINE _variacion        DECIMAL(16,2);
DEFINE _tipo_transaccion SMALLINT;
DEFINE _tipo_contrato    CHAR(1);
DEFINE _nombre_contrato  CHAR(50);

DEFINE _dt_siniestro      DATE;
DEFINE _serie 			  SMALLINT;
DEFINE _serie1 			  SMALLINT;
define _si_hay            SMALLINT;


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
		cod_subramo          CHAR(3)   NOT NULL,
		ajust_interno   	 CHAR(3)   NOT NULL,
		cod_evento     	     CHAR(3)   NOT NULL,
		cod_suceso     	     CHAR(3),
		cod_cliente          CHAR(10)  NOT NULL,
		cod_contrato         CHAR(05)  NOT NULL,
		tipo_transaccion     SMALLINT,
		tipo_contrato        CHAR(1),
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		transaccion          CHAR(10)  NOT NULL,
	  	pagado_neto          DEC(16,2) NOT NULL,
	   	incurrido_neto       DEC(16,2) NOT NULL,
		posible_recobro		 INT       NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		doc_poliza           CHAR(20)  NOT NULL,
		nombre_contrato      CHAR(50)  NOT NULL,
	   	variacion       	 DEC(16,2) NOT NULL,
		serie				 smallint,
		PRIMARY KEY (no_reclamo,transaccion,nombre_contrato,serie)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);
CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);
CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);
CREATE INDEX xie08_tmp_sinis ON tmp_sinis(tipo_contrato);
CREATE INDEX xie09_tmp_sinis ON tmp_sinis(serie);


-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
LET _pagado_neto = 0;
let _si_hay = 0;


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT a.no_reclamo,
 		a.monto,
	    a.cod_sucursal,
		a.transaccion,
		a.variacion,
		b.tipo_transaccion
  INTO _no_reclamo,
   		_monto_total,
	   _cod_sucursal,
	   _transaccion,
	   _variacion,
	   _tipo_transaccion
  FROM rectrmae a,rectitra b
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
    AND a.cod_tipotran = b.cod_tipotran
    AND a.periodo >= a_periodo1
    AND a.periodo <= a_periodo2
    AND a.monto   <> 0
--    AND b.tipo_transaccion = 4
    AND b.tipo_transaccion in (4,5,6,7)

	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
	       periodo,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  INTO _no_poliza,
	       _periodo,
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
    LET _monto_variacion = _variacion   / 100 * _porc_coas;

	-- Informacion de Reaseguro

   FOREACH
	SELECT recreaco.cod_contrato,recreaco.porc_partic_suma,reacomae.nombre,
	       reacomae.tipo_contrato,reacomae.serie
	  INTO _cod_contrato,_porc_reas,_nombre_contrato,_tipo_contrato,_serie
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
--	   AND reacomae.tipo_contrato <> 1

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;

	IF _porc_reas = 0 THEN
	   CONTINUE FOREACH;
	END IF

	-- Calculos

	LET _pagado_neto    = _monto_bruto     / 100 * _porc_reas;
	LET _variacion_neta = _monto_variacion / 100 * _porc_reas;
---	/***************** la serie cambia por la vigencia del contrato ********/
	SELECT fecha_siniestro 
	  INTO _dt_siniestro
	  FROM recrcmae 
	 WHERE no_reclamo = _no_reclamo   -- '218854'   
	   AND numrecla   = _numrecla -- '01-0611-00040-01' 
	   AND no_poliza  = _no_poliza;   -- '570769';

	 foreach
	 SELECT cod_contrato	
	   INTO _cod_contrato	
	   FROM recreaco
	  WHERE no_reclamo = _no_reclamo	
	 order by cod_contrato desc
	  exit foreach;
	   end foreach

	SELECT tipo_contrato
	  INTO _tipo_contrato
	  FROM reacomae
	 WHERE cod_contrato = _cod_contrato;

	 foreach
    SELECT serie 
	  INTO _serie1 
      FROM reacomae 
	 WHERE tipo_contrato = _tipo_contrato 
	   AND _dt_siniestro BETWEEN vigencia_inic AND vigencia_final
	 order by serie desc
	  exit foreach;
	   end foreach

		if _serie1 is not null or _serie1 <> 0 then
		   LET _serie = _serie1;	
	   end if
---	/***************** la serie cambia por la vigencia del contrato ********/
	-- Actualizacion del Movimiento

	BEGIN
	ON EXCEPTION IN(-239)

		UPDATE tmp_sinis
		   SET pagado_neto     = pagado_neto   + _pagado_neto,
		       variacion       = variacion     + _variacion_neta
		 WHERE no_reclamo      = _no_reclamo
		   AND transaccion     = _transaccion
		   AND nombre_contrato = _nombre_contrato
		   and serie           = _serie		   ; 

	END EXCEPTION

		INSERT INTO tmp_sinis(
	   	pagado_neto,
		incurrido_neto,
		no_reclamo,
		no_poliza,
		cod_ramo,
		periodo,
		numrecla,
		transaccion,
		cod_grupo,
		ajust_interno,
		cod_evento,
		cod_suceso,
		posible_recobro,
		cod_sucursal,
		cod_subramo,
		cod_cliente,
		cod_contrato,
		tipo_transaccion,
		tipo_contrato,
		doc_poliza,
		nombre_contrato,
		variacion,
		serie
	    )
		VALUES(
		_pagado_neto,
	   	0,
	    _no_reclamo,
		_no_poliza,
		_cod_ramo,
		_periodo,
		_numrecla,
		_transaccion,
		_cod_grupo,
		_ajust_interno,
		_cod_evento,
		_cod_suceso,
		_posible_recobro,
		_cod_sucursal,
		_cod_subramo,
		_cod_cliente,
		_cod_contrato,
		_tipo_transaccion,
		_tipo_contrato,
		_doc_poliza,
		_nombre_contrato,
		_variacion_neta,
		_serie
		);

	END

	LET _pagado_neto = 0;
	LET _variacion   = 0;
	LET _monto_total = 0;

	END FOREACH

END FOREACH

-- Actualizacion del Incurrido

UPDATE tmp_sinis
   SET incurrido_neto  = pagado_neto  + variacion;

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

IF a_tipo_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Tipo Contrato : " ||  TRIM(a_tipo_contrato);

	LET _tipo = sp_sis04(a_tipo_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_contrato NOT IN (SELECT codigo FROM tmp_codigos);

   END IF		        -- (E) Excluir estos Registros

   DROP TABLE tmp_codigos;

END IF

RETURN v_filtros;

END PROCEDURE;
