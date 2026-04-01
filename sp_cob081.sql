-- Procedimiento que Genera los Cobros por Cobrador
-- 
-- Creado    : 11/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/04/2002 - Autor: Amado Perez - Se vuelve a preguntar por tipo de produccion
--												 al cargar la morosidad.
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob081;

CREATE PROCEDURE "informix".sp_cob081(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
) 
--RETURNING CHAR(10);

DEFINE _cod_agente       CHAR(5);  
DEFINE _no_poliza        CHAR(10); 
DEFINE _nombre_cliente   CHAR(100);
DEFINE _doc_poliza       CHAR(20); 
DEFINE _estatus          CHAR(1);  
DEFINE _forma_pago       CHAR(2);  
DEFINE _vigencia_inic    DATE;     
DEFINE _vigencia_final   DATE;     
DEFINE _monto_pagado     DEC(16,2);
DEFINE _prima_neta       DEC(16,2);
DEFINE _prima_orig       DEC(16,2);
DEFINE _saldo            DEC(16,2);
DEFINE _por_vencer       DEC(16,2);
DEFINE _exigible         DEC(16,2);
DEFINE _corriente        DEC(16,2);
DEFINE _monto_30         DEC(16,2);
DEFINE _monto_60         DEC(16,2);
DEFINE _monto_90         DEC(16,2);
DEFINE _nombre_agente    CHAR(50); 
DEFINE _cod_cobrador     CHAR(3);  

DEFINE _cod_cliente      CHAR(10); 
DEFINE _cod_formapag     CHAR(3);  
DEFINE _cod_sucursal     CHAR(3);  
DEFINE _cod_ramo         CHAR(3);  

DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 

DEFINE _fecha_char       CHAR(10); 
DEFINE _fecha            DATE;     
DEFINE _porcentaje       DEC(16,2);

DEFINE _montoTotal       DEC(16,2);
DEFINE _montoPagado      DEC(16,2);

DEFINE _monto_pagado_tot DEC(16,2);
DEFINE _saldo_total      DEC(16,2);
DEFINE _por_vencer_total DEC(16,2);
DEFINE _exigible_total   DEC(16,2);
DEFINE _corriente_total  DEC(16,2);
DEFINE _monto_30_total   DEC(16,2);
DEFINE _monto_60_total   DEC(16,2);
DEFINE _monto_90_total   DEC(16,2);
DEFINE _prima_neta_tot   DEC(16,2);
DEFINE _cant_agentes     SMALLINT;
DEFINE _periodo          CHAR(7);
DEFINE _mes				 SMALLINT;
DEFINE _ano              SMALLINT;
DEFINE _mes2			 CHAR(2);	
DEFINE _ano2			 CHAR(4);
DEFINE _cnt_por_vencer   SMALLINT;
DEFINE _cnt_exigible	 SMALLINT;
DEFINE _cnt_corriente	 SMALLINT;
DEFINE _cnt_monto_30	 SMALLINT;
DEFINE _cnt_monto_60	 SMALLINT;
DEFINE _porc_comis_agt   DEC(5,2);

DEFINE _cnt_monto_90	 SMALLINT;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob08.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

CREATE TEMP TABLE tmp_pagos(
		no_documento    CHAR(18)	NOT NULL,
		monto_pagado    DEC(16,2)	NOT NULL,
		prima_neta      DEC(16,2)   NOT NULL
--		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_moros(
		cod_agente		CHAR(5)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		estatus         CHAR(1)     NOT NULL,
		forma_pago      CHAR(2)		NOT NULL,
		vigencia_inic   DATE,
		vigencia_final  DATE,
		monto_pagado    DEC(16,2)	DEFAULT 0 NOT NULL,
		prima_neta      DEC(16,2)   DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL,
		comision        DEC(16,2)   DEFAULT 0 NOT NULL, 
		nombre_agente   CHAR(50)	NOT NULL,
		cod_cobrador    CHAR(3)     NOT NULL,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_ramo        CHAR(3)     NOT NULL,
		cod_formapag    CHAR(3)     NOT NULL,
		cnt_por_vencer  SMALLINT    DEFAULT 0 NOT NULL,
		cnt_exigible    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_corriente   SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_30    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_60    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_90    SMALLINT    DEFAULT 0 NOT NULL,
		PRIMARY KEY (cod_agente, doc_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);

-- Fecha de Seleccion

--LET _fecha_char[4,5] = '28';

LET _periodo = a_periodo2;
LET _mes     = _periodo[6,7];
LET _ano     = _periodo[1,4];

IF _mes = 1 THEN 
	LET _ano2    = _ano - 1;
	LET _periodo = _ano2 || "-" || "12";
ELSE
	IF (_mes - 1) < 10 THEN
	    LET _mes2 = "0" || (_mes - 1);
	ELSE
	    LET _mes2 = (_mes - 1);
	END IF
	LET _periodo = _ano || "-" || _mes2;
END IF

IF   _periodo[6,7] = 2 THEN
	LET _fecha_char[1,2] = '28';
ELIF _periodo[6,7] = 4  OR
	 _periodo[6,7] = 6  OR
	 _periodo[6,7] = 9  OR
	 _periodo[6,7] = 11 THEN
	LET _fecha_char[1,2] = '30';
ELSE
	LET _fecha_char[1,2] = '31';
END IF

LET _fecha_char[3,3]  = '/';
LET _fecha_char[4,5]  = _periodo[6,7];
LET _fecha_char[6,6]  = '/';
LET _fecha_char[7,10] = _periodo[1,4];

LET _fecha = _fecha_char;

--RETURN;

-- Pago a Polizas

FOREACH
 SELECT doc_remesa, 
        monto,
		prima_neta,
		no_poliza
   INTO _doc_poliza,
    	_monto_pagado,
		_prima_neta,
		_no_poliza
   FROM cobredet
  WHERE actualizado  = 1			              -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')           	  -- Pago de Prima(P)
    AND periodo BETWEEN a_periodo1 AND a_periodo2 -- Periodo de Seleccion
  
	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_produccion = 3 OR		 -- Coaseguro Minoritario
	   _tipo_produccion = 4 THEN	 -- Reaseguro Asumido
		CONTINUE FOREACH;
	END IF

--TRACE ON;

	INSERT INTO tmp_pagos(
	no_documento,
	monto_pagado,
	prima_neta
	)
	VALUES(
	_doc_poliza,
	_monto_pagado,
	_prima_neta
	);

END FOREACH
--SET DEBUG FILE TO "sp_cob08.trc";
--trace on;

FOREACH 
 SELECT no_documento,
		SUM(monto_pagado),
		SUM(prima_neta)
   INTO	_doc_poliza,     
		_monto_pagado,
		_prima_neta
   FROM tmp_pagos
  GROUP BY no_documento

	FOREACH
	 SELECT	no_poliza,
			prima_bruta,
			vigencia_final,
			cod_contratante,
	        cod_formapag,
		    estatus_poliza,
		    vigencia_inic,
		    cod_sucursal,
			cod_ramo,
			cod_tipoprod
	   INTO	_no_poliza,
			_prima_orig,
			_vigencia_final,
			_cod_cliente,
	        _cod_formapag,
		    _estatus,
		    _vigencia_inic,
		    _cod_sucursal,
			_cod_ramo,
			_cod_tipoprod
	   FROM	emipomae
	  WHERE no_documento = _doc_poliza
		AND actualizado  = 1			   	
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH


	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;


-- Procedimiento que genera la morosidad para una poliza

--	RETURN _no_poliza WITH RESUME;

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 _fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo_total;         

	-- Calcula a que Morosidad Afectan los Montos Pagados

	LET _montoTotal  = _corriente + _monto_30 + _monto_60 + _monto_90 + _por_vencer;
	LET _montoPagado = _monto_pagado;

	IF _montoTotal > 0 THEN

		IF _monto_90 <> 0 THEN

			IF _monto_90 >= _montoPagado THEN

				LET _monto_90    = _montoPagado;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_90;

			END IF	

		END IF

		IF _monto_60 <> 0 THEN

			IF _monto_60 >= _montoPagado THEN

				LET _monto_60    = _montoPagado;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_60;

			END IF	

		END IF

		IF _monto_30 <> 0 THEN

			IF _monto_30 >= _montoPagado THEN

				LET _monto_30    = _montoPagado;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_30;

			END IF	

		END IF
		
		IF _corriente <> 0 THEN

			IF _corriente >= _montoPagado THEN

				LET _corriente   = _montoPagado;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _corriente;

			END IF	

		END IF

		IF _por_vencer <> 0 THEN

			LET _por_vencer  = _montoPagado;
			LET _montoPagado = 0;

		END IF

		IF _montoPagado <> 0 THEN
			LET _corriente = _corriente + _montoPagado;
		END IF			

	ELSE

		LET _monto_90   = 0;
		LET _monto_60   = 0;
		LET _monto_30   = 0;
		LET _corriente  = _montoPagado;
		LET _por_vencer = 0;

	END IF

	LET _exigible = _corriente + _monto_30 + _monto_60 + _monto_90;

	-- Lectura de Tablas Relacionadas

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
	SELECT nombre
	  INTO _forma_pago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _forma_pago IS NULL THEN
		LET _forma_pago = '';
	END IF

	IF _estatus = '2' THEN -- Poliza Cancelada
		LET _estatus = 'C';
	ELSE
		LET _estatus = '';
	END IF

	-- Determina todos los agentes de la poliza

	LET _monto_pagado_tot = _monto_pagado;
	LET _prima_neta_tot   = _prima_neta;
	LET _por_vencer_total = _por_vencer;
	LET _exigible_total   = _exigible;
	LET _corriente_total  = _corriente;
	LET _monto_30_total   = _monto_30;
	LET _monto_60_total   = _monto_60;
	LET _monto_90_total   = _monto_90;

--	IF _tipo_produccion = 3 THEN	 -- Coaseguro Minoritario

--	ELSE

		SELECT COUNT(*)
		  INTO _cant_agentes
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza;

		IF _cant_agentes IS NULL THEN
			LET _cant_agentes = 0;
		END IF

		IF _cant_agentes = 0 THEN

			LET _cod_agente = '00099';

			SELECT nombre,
				   cod_cobrador	
			  INTO _nombre_agente,
			       _cod_cobrador	
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			IF _por_vencer <> 0 THEN
				LET _cnt_por_vencer = 1;
			ELSE
				LET _cnt_por_vencer = 0;
			END IF
			IF _exigible <> 0 THEN
				LET _cnt_exigible = 1;
			ELSE
				LET _cnt_exigible = 0;
			END IF
			IF _corriente <> 0 THEN
				LET _cnt_corriente = 1;
			ELSE
				LET _cnt_corriente = 0;
			END IF
			IF _monto_30 <> 0 THEN
				LET _cnt_monto_30 = 1;
			ELSE
				LET _cnt_monto_30 = 0;
			END IF
			IF _monto_60 <> 0 THEN
				LET _cnt_monto_60 = 1;
			ELSE
				LET _cnt_monto_60 = 0;
			END IF
			IF _monto_90 <> 0 THEN
				LET _cnt_monto_90 = 1;
			ELSE
				LET _cnt_monto_90 = 0;
			END IF


			INSERT INTO tmp_moros(
			cod_agente,
			no_poliza,      
			nombre_cliente, 
			doc_poliza,     
			estatus,        
			forma_pago,     
			vigencia_inic,  
			vigencia_final, 
			monto_pagado,
			prima_neta,    
			por_vencer,     
			exigible,       
			corriente,     
			monto_30,       
			monto_60,       
			monto_90,
			nombre_agente,
			cod_cobrador,
			cod_sucursal,
			cod_ramo,
			cod_formapag,
			cnt_por_vencer,
			cnt_exigible,
			cnt_corriente,
			cnt_monto_30,
			cnt_monto_60,
			cnt_monto_90
			)
			VALUES(
			_cod_agente,
			_no_poliza,      
			_nombre_cliente, 
			_doc_poliza,     
			_estatus,        
			_forma_pago,     
			_vigencia_inic,  
			_vigencia_final, 
			_monto_pagado, 
			_prima_neta,   
			_por_vencer,     
			_exigible,       
			_corriente,     
			_monto_30,       
			_monto_60,       
			_monto_90,
			_nombre_agente,
			_cod_cobrador,
			_cod_sucursal,
			_cod_ramo,
			_cod_formapag,
			_cnt_por_vencer,
			_cnt_exigible,
			_cnt_corriente,
			_cnt_monto_30,
			_cnt_monto_60,
			_cnt_monto_90
			);

		ELSE

			FOREACH 
			 SELECT	cod_agente,
					porc_partic_agt,
					porc_comis_agt
			   INTO	_cod_agente,
					_porcentaje,
					_porc_comis_agt
			   FROM emipoagt
			  WHERE	no_poliza = _no_poliza

				SELECT nombre,
					   cod_cobrador	
				 INTO  _nombre_agente,
				       _cod_cobrador	
				 FROM  agtagent
				WHERE  cod_agente = _cod_agente;     

				LET _monto_pagado = _monto_pagado_tot   / 100 * _porcentaje;
				LET _prima_neta   = _prima_neta_tot     / 100 * _porcentaje;
				LET _por_vencer   = _por_vencer_total   / 100 * _porcentaje;
				LET _exigible     = _exigible_total     / 100 * _porcentaje;
				LET _corriente    = _corriente_total    / 100 * _porcentaje;
				LET _monto_30     = _monto_30_total     / 100 * _porcentaje;
				LET _monto_60     = _monto_60_total     / 100 * _porcentaje;
				LET _monto_90     = _monto_90_total     / 100 * _porcentaje;


				IF _por_vencer <> 0 THEN
					LET _cnt_por_vencer = 1;
				ELSE
					LET _cnt_por_vencer = 0;
				END IF
				IF _exigible <> 0 THEN
					LET _cnt_exigible = 1;
				ELSE
					LET _cnt_exigible = 0;
				END IF
				IF _corriente <> 0 THEN
					LET _cnt_corriente = 1;
				ELSE
					LET _cnt_corriente = 0;
				END IF
				IF _monto_30 <> 0 THEN
					LET _cnt_monto_30 = 1;
				ELSE
					LET _cnt_monto_30 = 0;
				END IF
				IF _monto_60 <> 0 THEN
					LET _cnt_monto_60 = 1;
				ELSE
					LET _cnt_monto_60 = 0;
				END IF
				IF _monto_90 <> 0 THEN
					LET _cnt_monto_90 = 1;
				ELSE
					LET _cnt_monto_90 = 0;
				END IF

				-- Actualizacion de la Tabla Temporal

				INSERT INTO tmp_moros(
				cod_agente,
				no_poliza,      
				nombre_cliente, 
				doc_poliza,     
				estatus,        
				forma_pago,     
				vigencia_inic,  
				vigencia_final, 
				monto_pagado,
				prima_neta,    
				por_vencer,     
				exigible,       
				corriente,     
				monto_30,       
				monto_60,       
				monto_90,
				comision,
				nombre_agente,
				cod_cobrador,
				cod_sucursal,
				cod_ramo,
				cod_formapag,
				cnt_por_vencer,
				cnt_exigible,
				cnt_corriente,
				cnt_monto_30,
				cnt_monto_60,
				cnt_monto_90
				)
				VALUES(
				_cod_agente,
				_no_poliza,      
				_nombre_cliente, 
				_doc_poliza,     
				_estatus,        
				_forma_pago,     
				_vigencia_inic,  
				_vigencia_final, 
				_monto_pagado,
				_prima_neta,    
				_por_vencer - _por_vencer * _porc_comis_agt / 100,     
				_exigible - _exigible * _porc_comis_agt / 100,       
				_corriente - _corriente * _porc_comis_agt / 100,     
				_monto_30 - _monto_30 * _porc_comis_agt / 100,       
				_monto_60 - _monto_60 * _porc_comis_agt / 100,       
				_monto_90 - _monto_90 * _porc_comis_agt / 100,
				_prima_neta * _porc_comis_agt / 100,
				_nombre_agente,
				_cod_cobrador,
				_cod_sucursal,
				_cod_ramo,
				_cod_formapag,
				_cnt_por_vencer,
				_cnt_exigible,
				_cnt_corriente,
				_cnt_monto_30,
				_cnt_monto_60,
				_cnt_monto_90
				);

			END FOREACH

		END IF

--	END IF

END FOREACH

DROP TABLE tmp_pagos;

END PROCEDURE;
