-- Procedimiento que Carga la Siniestralidad acumulada por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec298b;

CREATE PROCEDURE "informix".sp_rec298b(a_compania	CHAR(3), 
a_periodo1	CHAR(7), 
a_periodo2	CHAR(7)
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

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, '001');
let v_filtros = null;

-- Tabla Temporal
--DROP TABLE tmp_sinis;

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_abierto	 DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)  NOT NULL,
		pago_y_ded			 DEC(16,2) DEFAULT 0 NOT NULL,
		salv_y_recup         DEC(16,2) DEFAULT 0 NOT NULL,
		cant_pago            SMALLINT DEFAULT 0,
		pendiente            SMALLINT DEFAULT 0
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo);

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
		incurrido_abierto    DEC(16,2) NOT NULL,
		cod_agente			 CHAR(5),	
		cod_tipoprod		 CHAR(3),
		periodo_reclamo		 CHAR(7),
		pago_y_ded           DEC(16,2) NOT NULL,
		salv_y_recup         DEC(16,2) NOT NULL,
		cant_pago            SMALLINT DEFAULT 0,
		pendiente            SMALLINT DEFAULT 0,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);
CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);
CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);
CREATE INDEX xie08_tmp_sinis ON tmp_sinis(periodo);

FOREACH
 SELECT no_reclamo
   INTO a_no_reclamo
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
	--	AND periodo      >= a_periodo1 
	--	AND periodo      <= a_periodo2
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

		INSERT INTO tmp_incurrido(
		no_reclamo,
		pagado_total,
		pagado_bruto,
		pagado_neto,
		incurrido_abierto,
		periodo,
		pago_y_ded,
		salv_y_recup,
		cant_pago
		)
		VALUES(
		_no_reclamo,
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_incurrido_abierto,
		_peri,
		_pago_y_ded,
		_salv_y_recup,
		_cant_pago
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
	--	AND periodo      >= a_periodo1 
	--	AND periodo      <= a_periodo2
		AND variacion    <> 0
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

		SELECT periodo
		  INTO _periodo_rec
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		-- Variacion Bruta

		LET _monto_bruto = _monto_total / 100 * _porc_coas;

		IF _periodo_rec >= a_periodo1 AND _periodo_rec <= a_periodo2 THEN
		   IF _periodo_rec = _peri THEN
				LET _incurrido_abierto = _monto_bruto;
		   ELSE
				LET _incurrido_abierto = 0;
		   END IF
		ELSE
		   LET _incurrido_abierto = 0;
		END IF

		-- Variacion Neta

		LET _monto_neto  = 0;

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

			-- Informacion de Reaseguro

			LET _porc_reas = 0;

			FOREACH
			 select	porc_partic_suma
			   into _porc_reas
			   from rectrrea
			  where no_tranrec     = _no_tranrec
				and cod_cober_reas = _cod_cober_reas
				and tipo_contrato  = 1
				EXIT FOREACH;
			END FOREACH

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF;
		
			let _var_cob_bruto = _var_cob_total / 100 * _porc_coas;
			let _var_cob_neto  = _var_cob_bruto / 100 * _porc_reas;
			LET _monto_neto    = _monto_neto    + _var_cob_neto;

		end foreach

		-- Actualizacion del Movimiento

		INSERT INTO tmp_incurrido(
		no_reclamo,
		reserva_total,
		reserva_bruto,
		reserva_neto,
		incurrido_abierto,
		periodo
		)
		VALUES(
		_no_reclamo,
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_incurrido_abierto,
		_peri
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
			SUM(pagado_total),
			SUM(pagado_bruto),
			SUM(pagado_neto),
			SUM(reserva_total),
			SUM(reserva_bruto),
			SUM(reserva_neto),
			SUM(incurrido_abierto),
			SUM(salv_y_recup),
			SUM(pago_y_ded),
			SUM(cant_pago)
	   INTO _no_reclamo,	
			_pagado_total,
			_pagado_bruto,
			_pagado_neto,
			_reserva_total,
			_reserva_bruto,
			_reserva_neto,
			_incurrido_abierto,
			_salv_y_recup,
			_pago_y_ded,
			_cant_pago
	   FROM tmp_incurrido
	  GROUP BY no_reclamo
	  
	select sum(variacion)
	  into _monto_total
	  from rectrmae 
	 where no_reclamo = _no_reclamo 
	   and actualizado  	= 1
	 group by no_reclamo;
	
	let _pendiente = 0;

	if _monto_total > 0 then
		let _pendiente = 1;
	else
		let _pendiente = 0;
	end if


		-- Lectura de la Tabla de Reclamo

		SELECT no_poliza,
			   periodo,
			   numrecla,
			   ajust_interno,
			   cod_evento,
			   cod_suceso,
			   posible_recobro,
			   periodo
		  INTO _no_poliza,
			   _periodo,
			   _numrecla,
			   _ajust_interno,
			   _cod_evento,
			   _cod_suceso,
			   _posible_recobro,
			   _periodo_reclamo
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		-- Informacion de Polizas

		SELECT cod_ramo,
			   cod_grupo,
			   cod_subramo,
			   cod_contratante,
			   no_documento,
			   sucursal_origen,
			   cod_tipoprod
		  INTO _cod_ramo,
			   _cod_grupo,
			   _cod_subramo,
			   _cod_cliente,
			   _doc_poliza,
			   _cod_sucursal,
			   _cod_tipoprod
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

		FOREACH 
		 SELECT	cod_agente
		   INTO	_cod_agente
		   FROM	emipoagt
		  WHERE	no_poliza = _no_poliza
		 EXIT FOREACH;
		END FOREACH

		IF _cod_agente IS NULL THEN
			LET _cod_agente = '';
		END IF

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
		cod_acreedor,
		incurrido_abierto,
		cod_agente,
		cod_tipoprod,
		periodo_reclamo,
		pago_y_ded,
		salv_y_recup,
		cant_pago,
		pendiente
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
		_cod_acreedor,
		_incurrido_abierto,
		_cod_agente,
		_cod_tipoprod,
		_periodo_reclamo,
		_pago_y_ded,
		_salv_y_recup,
		_cant_pago,
		_pendiente);

	END FOREACH

DROP TABLE tmp_incurrido;

END 

-- Actualizacion del Incurrido

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;

--DROP TABLE tmp_sinis;
RETURN v_filtros;

END PROCEDURE;
