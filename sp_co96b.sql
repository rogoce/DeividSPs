-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/07/2001 - Autor: Lic Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co96b;

CREATE PROCEDURE "informix".sp_co96b(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7),
		a_nopoliza	CHAR(10),
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

DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_total     DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
--DEFINE _porc_reas       DECIMAL;
DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, periodo)
		) WITH NO LOG;

CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_bruto = 0;
LET _monto_total = 0;

FOREACH
 SELECT a.no_reclamo,
 		a.monto,
		a.periodo
   INTO _no_reclamo,	
   		_monto_total,
		_periodo
   FROM rectrmae a, recrcmae b
  WHERE a.cod_compania = a_compania
    AND a.actualizado  = 1
	AND a.cod_tipotran IN ('004','005','006','007')
	AND a.periodo      >= a_periodo1 
	AND a.periodo      <= a_periodo2
    AND a.monto        <> 0
	AND b.no_reclamo   = a.no_reclamo
	AND b.no_poliza    = a_nopoliza

	-- Informacion de Coseguro

	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;

	-- Actualizacion del Movimiento

	BEGIN
	ON EXCEPTION IN(-239)

		UPDATE tmp_sinis
		   SET pagado_bruto  = pagado_bruto  + _monto_bruto
		 WHERE no_reclamo    = _no_reclamo
		   AND periodo       = _periodo;

	END EXCEPTION

	INSERT INTO tmp_sinis(
	no_reclamo,
	pagado_bruto,
	no_poliza,
	periodo
	)
	VALUES(
	_no_reclamo,
	_monto_bruto,
	a_nopoliza,
	_periodo
	);
	END

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

RETURN v_filtros;

END PROCEDURE;