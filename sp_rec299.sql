-- Procedimiento que Carga la Siniestralidad acumulada por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec299;

CREATE PROCEDURE "informix".sp_rec299(a_compania	CHAR(3), 
a_periodo1	CHAR(7), 
a_periodo2	CHAR(7)
) RETURNING CHAR(7) as periodo,
            INTEGER as reclamos,
			DEC(16,2) as pagado_total,
			DEC(16,2) as pagado_bruto,
			DEC(16,2) as pagado_neto;

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
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo,a_no_reclamo      CHAR(10);
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
DEFINE _periodo_reclamo CHAR(7);
DEFINE _desc_ajus_nomb  CHAR(255);
DEFINE _cod_tipotran    CHAR(3);
define _pago_y_ded		DECIMAL(16,2);
define _salv_y_recup    DECIMAL(16,2);
define _pendiente       smallint;
define _cant_pago       smallint;
define _cnt             integer;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, '001');
let v_filtros = null;

-- Tabla Temporal
--DROP TABLE tmp_sinis;

CREATE TEMP TABLE tmp_reclamo(
		no_reclamo           CHAR(10),
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		periodo              CHAR(7)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_totales(
		cnt_reclamos         INTEGER,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		periodo              CHAR(7),
		PRIMARY KEY (periodo)) WITH NO LOG;


FOREACH
 SELECT no_reclamo,
        periodo
   INTO a_no_reclamo,
        _periodo
   FROM recrcmae 
  WHERE cod_compania = a_compania
    AND periodo      >= a_periodo1 
    AND periodo      <= a_periodo2 
	AND numrecla[1,2] in ('02','20','23')
	AND actualizado  = 1
	AND user_added = 'informix'
	   
	-- Pagos, Salvamentos, Recuperos y Deducibles

	LET _monto_total = 0;
	LET _monto_bruto = 0;
	LET _monto_neto  = 0;
	
	INSERT INTO tmp_reclamo
	values(
	a_no_reclamo,
	0,
	0,
	0,
	_periodo);

	FOREACH
	 SELECT no_reclamo,
			monto,
			periodo,
			no_tranrec,
			cod_tipotran
	   INTO _no_reclamo,
			_monto_total,
			_peri,
			_no_tranrec,
			_cod_tipotran
	   FROM rectrmae
	  WHERE cod_compania = a_compania
		AND actualizado  = 1
		AND cod_tipotran IN ('004','005','006','007')
		AND monto        <> 0
		AND no_reclamo = a_no_reclamo

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

		-- Actualizacion del Movimiento
		let _pago_y_ded   = 0.00;
		let _salv_y_recup = 0.00;
		let _cant_pago = 0;
		
		if _cod_tipotran in('004','007') then --Pago y deducible
			let _pago_y_ded = _monto_bruto;
		elif  _cod_tipotran in('005','006') then --Salvamento y Recupero
			let _salv_y_recup = _monto_bruto;
		end if	
		
		if _cod_tipotran = '004' then
			let _cant_pago = 1;
		end if

		INSERT INTO tmp_reclamo
		values(
		NULL,
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_peri);

	END FOREACH

END FOREACH

BEGIN
	DEFINE _pagado_total  DEC(16,2);
	DEFINE _pagado_bruto  DEC(16,2);
	DEFINE _pagado_neto   DEC(16,2);

	FOREACH 
		SELECT COUNT(no_reclamo),	
			   periodo
	      INTO _cnt,	
			   _periodo
	      FROM tmp_reclamo
	     WHERE no_reclamo is not null
	  GROUP BY periodo
	  
	    INSERT INTO tmp_totales
		values(
		_cnt,
		0,
		0,
		0,
		_periodo);

	END FOREACH
		
	FOREACH 
		SELECT SUM(pagado_total),
		       SUM(pagado_bruto), 
		       SUM(pagado_neto),
		       periodo
	      INTO _pagado_total,	
			   _pagado_bruto,
			   _pagado_neto,
			   _periodo
	      FROM tmp_reclamo
	  GROUP BY periodo
	  
		BEGIN
		ON EXCEPTION
			UPDATE tmp_totales
			   SET pagado_total = _pagado_total,
			       pagado_bruto = _pagado_bruto,
				   pagado_neto = _pagado_neto
			 WHERE periodo = _periodo;
		END EXCEPTION
	    INSERT INTO tmp_totales
		values(
		0,
		_pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_periodo);
		END

	END FOREACH
	
    FOREACH WITH HOLD
		SELECT cnt_reclamos,
		       pagado_total,
			   pagado_bruto,
			   pagado_neto,
			   periodo
		  INTO _cnt,
		       _pagado_total,
			   _pagado_bruto,
			   _pagado_neto,
			   _periodo
		  FROM tmp_totales
	  ORDER BY periodo
	  
	  RETURN _periodo,
	         _cnt,
			 _pagado_total,
			 _pagado_bruto,
			 _pagado_neto WITH RESUME;
    END FOREACH
END	
  
DROP TABLE tmp_reclamo;
DROP TABLE tmp_totales;




END PROCEDURE;
