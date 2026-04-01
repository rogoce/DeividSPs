-- Procedimiento que Carga la Siniestralidad acumulada por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec139;

CREATE PROCEDURE "informix".sp_rec139(
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

DEFINE _var_cob_total	DECIMAL(16,2);
DEFINE _var_cob_bruto   DECIMAL(16,2);
DEFINE _var_cob_neto    DECIMAL(16,2);

define _cod_cobertura	char(5);
define _cod_cober_reas	char(3);

DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo char(7);
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
DEFINE _periodo_reclamo CHAR(7);
DEFINE _desc_ajus_nomb  CHAR(255);


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal
--DROP TABLE tmp_sinis;

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		no_tranrec           CHAR(10)  NOT NULL,
        cod_cobertura        CHAR(5)   NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)  NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo);
CREATE INDEX xie03_tmp_incurrido ON tmp_incurrido(no_tranrec);
CREATE INDEX xie04_tmp_incurrido ON tmp_incurrido(cod_cobertura);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

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

	-- Informacion de Coaseguro

	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF


	-- Calculos
	LET _monto_total = 0;
	LET _monto_bruto = 0;
	LET _monto_neto  = 0;

	Foreach
	   select cod_cobertura,
	          monto
		 into _cod_cobertura,
	          _monto_total
		 from rectrcob
	    where no_tranrec = _no_tranrec
		  and monto     <> 0

	   LET _monto_bruto = _monto_total / 100 * _porc_coas;

		-- Actualizacion del Movimiento

		INSERT INTO tmp_incurrido(
		no_reclamo,
		pagado_bruto,
		periodo,
		no_tranrec,
		cod_cobertura
		)
		VALUES(
		_no_reclamo,
		_monto_bruto,
		_peri,
		_no_tranrec,
		_cod_cobertura
		);
	End Foreach

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

	-- Variacion Bruta

	LET _monto_bruto = _monto_total / 100 * _porc_coas;

	foreach
	 select	cod_cobertura,
	        variacion
	   into	_cod_cobertura,
	        _var_cob_total
	   from rectrcob
	  where no_tranrec = _no_tranrec
		and variacion  <> 0

		select cod_cober_reas
		  into _cod_cober_reas
		  from prdcober
		 where cod_cobertura = _cod_cobertura;
	
		let _var_cob_bruto = _var_cob_total / 100 * _porc_coas;

		-- Actualizacion del Movimiento

		INSERT INTO tmp_incurrido(
		no_reclamo,
		reserva_bruto,
		periodo,
		no_tranrec,
		cod_cobertura
		)
		VALUES(
		_no_reclamo,
		_var_cob_bruto,
		_peri,
		_no_tranrec,
		_cod_cobertura
		);

	end foreach


END FOREACH


RETURN '';

END PROCEDURE;
