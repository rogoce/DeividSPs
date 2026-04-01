-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 23/01/2003 - Autor: Amado Perez 
--                          Se modifico para que leyera la sucursal del campo sucursal_origen
--                          de emipomae y no de cod_sucursal
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_preram4;

CREATE PROCEDURE "informix".sp_preram4(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7),
		a_sucursal  CHAR(255) DEFAULT "*",
		a_grupo     CHAR(255) DEFAULT "*",
		a_ramo      CHAR(255) DEFAULT "*",
		a_agente    CHAR(255) DEFAULT "*",
		a_ajustador CHAR(255) DEFAULT "*",
		a_evento    CHAR(255) DEFAULT "*",
		a_suceso    CHAR(255) DEFAULT "*",	
		a_tipoprod  CHAR(255) DEFAULT "*"	
		) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo,_periodo_rec CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);
DEFINE _no_tranrec      CHAR(10);

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
DEFINE _cod_tipoprod    CHAR(3);


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

CREATE TEMP TABLE tmp_incurrid(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_abierto	 DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)   NOT NULL,
		cod_ramo			 CHAR(3)   NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrid ON tmp_incurrid(no_reclamo);
CREATE INDEX xie02_tmp_incurrid ON tmp_incurrid(no_reclamo,periodo);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
LET v_filtros = "";

FOREACH
 SELECT no_reclamo,
 		monto,
		periodo,
		no_tranrec
   INTO _no_reclamo,
   		_monto_total,
		_peri,
		_no_tranrec
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
	AND cod_tipotran IN ('004','005','006','007')
	AND periodo      >= a_periodo1 
	AND periodo      <= a_periodo2
    AND monto        <> 0

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

	LET _porc_reas = 0;
	
	FOREACH
	 select	porc_partic_suma
	   into _porc_reas
	   from rectrrea
	  where no_tranrec    = _no_tranrec
	    and tipo_contrato = 1
		EXIT FOREACH;
	END FOREACH
	  
	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;

	SELECT periodo
	  INTO _periodo_rec
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	IF _periodo_rec >= a_periodo1 AND _periodo_rec <= a_periodo2 THEN
	   IF _periodo_rec = _peri THEN
	   		LET _incurrido_abierto = _monto_bruto;
	   ELSE
	   		LET _incurrido_abierto = 0;
	   END IF
	ELSE
	   LET _incurrido_abierto = 0;
	END IF

   -- Lectura de la Tabla de Reclamo

   SELECT no_poliza
     INTO _no_poliza
     FROM recrcmae
    WHERE no_reclamo = _no_reclamo;

   -- Informacion de Polizas

   SELECT cod_ramo
     INTO _cod_ramo
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrid(
	no_reclamo,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	incurrido_abierto,
	periodo,
	cod_ramo
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto,
	_incurrido_abierto,
	_peri,
	_cod_ramo
	);

END FOREACH

-- Variacion de Reserva

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH 
 SELECT no_reclamo,	
 		variacion,
		periodo,
		no_tranrec
   INTO _no_reclamo,	
   		_monto_total,
		_peri,
		_no_tranrec
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

	LET _porc_reas = 0;

	FOREACH
	 select	porc_partic_suma
	   into _porc_reas
	   from rectrrea
	  where no_tranrec    = _no_tranrec
	    and tipo_contrato = 1
		EXIT FOREACH;
	END FOREACH

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF;

	SELECT periodo
	  INTO _periodo_rec
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	IF _periodo_rec >= a_periodo1 AND _periodo_rec <= a_periodo2 THEN
	   IF _periodo_rec = _peri THEN
	   		LET _incurrido_abierto = _monto_bruto;
	   ELSE
	   		LET _incurrido_abierto = 0;
	   END IF
	ELSE
	   LET _incurrido_abierto = 0;
	END IF

   -- Lectura de la Tabla de Reclamo

   SELECT no_poliza
     INTO _no_poliza
     FROM recrcmae
    WHERE no_reclamo = _no_reclamo;

   -- Informacion de Polizas

   SELECT cod_ramo
     INTO _cod_ramo
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrid(
	no_reclamo,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	incurrido_abierto,
	periodo,
	cod_ramo
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto,
	_incurrido_abierto,
	_peri,
	_cod_ramo
	);

END FOREACH


RETURN v_filtros;

END PROCEDURE;
