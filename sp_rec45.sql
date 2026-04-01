-- Procedimiento que Carga el An lisis de Reclamos Ramo Auto por Subramo/Tipo de Veh¡culo
-- en un Periodo Dado
--
-- Creado    : 08/02/2001 - Autor: Yinia M. Zamora
-- Modificado:
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec45;

CREATE PROCEDURE "informix".sp_rec45(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*") 
RETURNING CHAR(50),   -- Nombre Subramo
	      CHAR(50),	  -- Nombre Tipo Veh¡culo
	      DEC(16,2),  -- Incurrido Bruto
	      SMALLINT,	  -- Reclamos Abiertos
	      DEC(16,2),  -- Deducible Bruto
	      CHAR(50),	  -- Nombre Compa¤¡a
		  CHAR(255);  -- Filtros
	


DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;

DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _transaccion     CHAR(10);

DEFINE _cod_sucursal,_cod_tipoveh,_cod_coasegur   CHAR(3);
DEFINE _cod_grupo,_no_unidad                      CHAR(5);
DEFINE _cod_ramo,v_cod_ramo,_cod_subramo,_cod_tipotran   CHAR(3);
DEFINE _cod_cliente                               CHAR(10);
DEFINE _tipo_transaccion                          SMALLINT;
DEFINE _pagado_bruto,_salvado_bruto,_recupero_bruto,_deducible_bruto,
       _deducible_neto,_deducible_total,_variacion_bruta,_variacion_neta,
	   _variacion_total,_incurrido_bruto,_monto_total,_total_bruto,
	   _pagado_total,_pagado_neto,_total,_reserva_bruta,
	   _pagado_bruto1,_pagado_total1,_pagado_neto1   DEC(16,2);
DEFINE v_nom_subra,v_nom_tipo,v_compania_nombre   CHAR(50);
DEFINE _rec_abiertos,_cerrar_rec                  SMALLINT;


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

--DROP TABLE tmp_sinis;
-- Tabla Temporal

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_total1        DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto1        DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto1         DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruta        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neta         DEC(16,2) DEFAULT 0 NOT NULL,
		deducible_total      DEC(16,2) DEFAULT 0 NOT NULL,
		deducible_bruto      DEC(16,2) DEFAULT 0 NOT NULL,
		deducible_neto       DEC(16,2) DEFAULT 0 NOT NULL)
		WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
		cod_tipoveh          CHAR(3),
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		reserva_bruta        DEC(16,2) NOT NULL,
		pagado_bruto1 		 DEC(16,2) NOT NULL,
		deducible_bruto      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
	   	rec_abiertos         SMALLINT,
		cerrar_rec           SMALLINT,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo)) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(no_poliza);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_bruto     = 0;
LET _monto_neto      = 0;
LET _pagado_bruto    = 0;
LET _pagado_bruto1   = 0;
LET _reserva_bruta   = 0;
LET _deducible_bruto = 0;
LET _incurrido_bruto = 0;
LET _variacion_bruta = 0;
LET _rec_abiertos    = 0;

LET v_compania_nombre = sp_sis01(a_compania);

SELECT cod_ramo
       INTO v_cod_ramo
	   FROM prdramo
	  WHERE ramo_sis = 1;

FOREACH
 SELECT a.no_reclamo,
        a.transaccion,
 		a.monto,
	    a.cod_sucursal,
		a.cod_tipotran,
		a.cerrar_rec
   INTO _no_reclamo,
    	_transaccion,
   		_monto_total,
	   _cod_sucursal,
	   _cod_tipotran,
	   _cerrar_rec
   FROM rectrmae a
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
	AND a.cod_tipotran IN ('004')
    AND a.periodo BETWEEN a_periodo1 AND a_periodo2
    AND a.monto   <> 0

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

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco,reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;
	EXIT FOREACH;
	END FOREACH

	-- Calculos
	IF _monto_total IS NULL THEN
	   LET _monto_total = 0;
	END IF
    LET _monto_bruto     = _monto_total   / 100 * _porc_coas;
    LET _monto_neto      = _monto_bruto   / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	pagado_total,
	pagado_bruto,
	pagado_neto
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto
	);

END FOREACH

-- Salvamente,Deducible, Recupero

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
FOREACH
 SELECT a.no_reclamo,
        a.transaccion,
 		a.monto,
	    a.cod_sucursal,
		a.cod_tipotran,
		a.cerrar_rec
   INTO _no_reclamo,
    	_transaccion,
   		_monto_total,
	   _cod_sucursal,
	   _cod_tipotran,
	   _cerrar_rec
   FROM rectrmae a
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
	AND a.cod_tipotran IN ('005','006','007')
    AND a.periodo BETWEEN a_periodo1 AND a_periodo2
    AND a.monto   <> 0

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

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco,reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;
	EXIT FOREACH;
	END FOREACH

	-- Calculos
	IF _monto_total IS NULL THEN
	   LET _monto_total = 0;
	END IF
    LET _monto_bruto     = _monto_total   / 100 * _porc_coas;
    LET _monto_neto      = _monto_bruto   / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	pagado_total1,
	pagado_bruto1,
	pagado_neto1
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto
	);

END FOREACH

-- Actualizacion del Movimiento

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH
 SELECT no_reclamo,
  		variacion
   INTO _no_reclamo,
   		_monto_total
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND cod_tipotran MATCHES '*' -- Para que incluya el indice creado
	AND periodo      >= a_periodo1
	AND periodo      <= a_periodo2
    AND variacion    <> 0

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
 
	-- Calculos
    IF _monto_total IS NULL THEN
	   LET _monto_total = 0;
	END IF

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	reserva_total,
	reserva_bruta,
	reserva_neta
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto
	);

END FOREACH

-- Deducible -----------------------------------------------------|

FOREACH
 SELECT a.no_reclamo,
        a.transaccion,
 		a.monto,
	    a.cod_sucursal,
		a.cod_tipotran,
		a.cerrar_rec
   INTO _no_reclamo,
    	_transaccion,
   		_monto_total,
	   _cod_sucursal,
	   _cod_tipotran,
	   _cerrar_rec
   FROM rectrmae a
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
	AND a.cod_tipotran IN ('007')
    AND a.periodo BETWEEN a_periodo1 AND a_periodo2
    AND a.monto   <> 0

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

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco,reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;
	EXIT FOREACH;
	END FOREACH

	-- Calculos
	IF _monto_total IS NULL THEN
	   LET _monto_total = 0;
	END IF
    LET _monto_bruto     = _monto_total   / 100 * _porc_coas;
    LET _monto_neto      = _monto_bruto   / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	deducible_total,
	deducible_bruto,
	deducible_neto
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto
	);

END FOREACH

-- Lectura de la Tablas de Reclamos

BEGIN

DEFINE _pagado_total,_pagado_total1  DEC(16,2);
DEFINE _pagado_bruto,_pagado_bruto1  DEC(16,2);
DEFINE _pagado_neto,_pagado_neto1    DEC(16,2);
DEFINE _reserva_total DEC(16,2);
DEFINE _reserva_bruta DEC(16,2);
DEFINE _reserva_neta  DEC(16,2);
DEFINE _rec_abiertos  SMALLINT;

FOREACH

 SELECT no_reclamo,
        SUM(pagado_total),
		SUM(pagado_bruto),
		SUM(pagado_neto),
		SUM(reserva_total),
		SUM(reserva_bruta),
		SUM(reserva_neta),
        SUM(pagado_total1),
		SUM(pagado_bruto1),
		SUM(pagado_neto1),
		SUM(deducible_bruto)
   INTO _no_reclamo,
        _pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_reserva_total,
		_reserva_bruta,
		_reserva_neta,
        _pagado_total1,
		_pagado_bruto1,
		_pagado_neto1,
		_deducible_bruto
   FROM tmp_incurrido
  GROUP BY no_reclamo

 SELECT no_poliza,
        periodo,
   	    numrecla,
 	    no_unidad
   INTO _no_poliza,
        _periodo,
        _numrecla,
        _no_unidad
   FROM recrcmae
  WHERE no_reclamo = _no_reclamo;

 LET _rec_abiertos = 0;
 FOREACH
 SELECT cerrar_rec
        INTO _cerrar_rec
		FROM rectrmae
	   WHERE cod_compania = a_compania
	     AND cod_sucursal = a_agencia
		 AND no_reclamo   = _no_reclamo
		 AND cerrar_rec   = 0

 IF _cerrar_rec = 0 THEN
    LET _rec_abiertos = _rec_abiertos + 1;
 END IF
 END FOREACH; 

 -- Informacion de Polizas

 SELECT cod_ramo,
        cod_grupo,
 	    cod_subramo
   INTO _cod_ramo,
       _cod_grupo,
       _cod_subramo
  FROM emipomae
 WHERE no_poliza = _no_poliza
   AND cod_ramo  = v_cod_ramo;

 IF _cod_ramo IS NULL OR
    _cod_ramo = " "   THEN
    CONTINUE FOREACH;
 END IF;

-- Informacion de Subramo/Tipo Veh¡culo

 SELECT  cod_tipoveh
   INTO  _cod_tipoveh
   FROM  emiauto
  WHERE  no_poliza = _no_poliza
     AND no_unidad = _no_unidad;

 IF _cod_tipoveh IS NULL THEN
    SELECT cod_tipoveh
     INTO _cod_tipoveh
     FROM endmoaut
    WHERE no_poliza = _no_poliza
      AND no_endoso = "00000"
      AND no_unidad = _no_unidad;
 END IF;
 IF _cod_tipoveh IS NULL THEN
     LET _cod_tipoveh = "001";
 END IF


 INSERT INTO tmp_sinis(
     	incurrido_bruto,
		pagado_bruto,
		pagado_bruto1,
		reserva_bruta,
		deducible_bruto,
		rec_abiertos,
		no_reclamo,
		no_poliza,
		cod_subramo,
		cod_tipoveh,
		periodo,
		numrecla,
		cod_grupo,
		cod_sucursal
		)
		VALUES(
		0,
		_pagado_bruto,
		_pagado_bruto1,
	   	_reserva_bruta,
		_deducible_bruto,
		_rec_abiertos,
		_no_reclamo,
		_no_poliza,
		_cod_subramo,
		_cod_tipoveh,
		_periodo,
		_numrecla,
		_cod_grupo,
		_cod_sucursal
		);

END FOREACH
DROP TABLE tmp_incurrido;

END

-- Actualizacion del Incurrido

UPDATE tmp_sinis
       SET incurrido_bruto = pagado_bruto + pagado_bruto1 + reserva_bruta;

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

 FOREACH
 SELECT cod_subramo,
        cod_tipoveh,
	    SUM(incurrido_bruto),
	    SUM(deducible_bruto),
		SUM(rec_abiertos)
   INTO	_cod_subramo,
        _cod_tipoveh,
	    _incurrido_bruto,
		_deducible_bruto,
		_rec_abiertos
   FROM tmp_sinis
  WHERE seleccionado = 1
  GROUP BY cod_subramo,cod_tipoveh
  ORDER BY cod_subramo,cod_tipoveh

  SELECT nombre
         INTO v_nom_subra
		 FROM prdsubra
		WHERE cod_ramo    = v_cod_ramo
		  AND cod_subramo = _cod_subramo;


  SELECT nombre
         INTO v_nom_tipo
		 FROM emitiveh
		WHERE cod_tipoveh = _cod_tipoveh;

   RETURN  v_nom_subra,
           v_nom_tipo,
		   _incurrido_bruto,
		   _rec_abiertos,
		   _deducible_bruto,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

END PROCEDURE;
