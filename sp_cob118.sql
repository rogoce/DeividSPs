-- Pagos por Pagador por Semana
-- 
-- Creado    : 02/07/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/07/2003 - Autor: Demetrio Hurtado Almanza

DROP PROCEDURE sp_cob118;

CREATE PROCEDURE "informix".sp_cob118(a_compania CHAR(3), a_agencia CHAR(3), a_desde date, a_hasta date) 
RETURNING CHAR(100), -- Nombre Pagador
			INTEGER,   -- Cantidad	
			DEC(16,2), -- Prima Pagada
			SMALLINT,  -- cnt. por vencer
			DEC(16,2), -- Por Vencer
			SMALLINT,  -- cnt. exigible
			DEC(16,2), -- Exigible
			SMALLINT,  -- cnt. corriente
			DEC(16,2), -- Corriente
			SMALLINT,  -- cnt. 30
			DEC(16,2), -- Dias 30
			SMALLINT,  -- cnt. 60
			DEC(16,2), -- Dias 60
			SMALLINT,  -- cnt. 90
			DEC(16,2), -- Dias 90
			CHAR(50);  -- Nombre Compania

DEFINE _doc_poliza       	CHAR(20); 
DEFINE _monto_pagado     	DEC(16,2);
DEFINE _cod_tipoprod     	CHAR(3);  
DEFINE _tipo_produccion  	SMALLINT; 

DEFINE _por_vencer       	DEC(16,2);
DEFINE _exigible         	DEC(16,2);
DEFINE _corriente        	DEC(16,2);
DEFINE _monto_30         	DEC(16,2);
DEFINE _monto_60         	DEC(16,2);
DEFINE _monto_90         	DEC(16,2);
DEFINE _saldo_total      	DEC(16,2);
DEFINE _cnt_por_vencer   	SMALLINT;
DEFINE _cnt_exigible	 	SMALLINT;
DEFINE _cnt_corriente	 	SMALLINT;
DEFINE _cnt_monto_30	 	SMALLINT;
DEFINE _cnt_monto_60	 	SMALLINT;
DEFINE _cnt_monto_90	 	SMALLINT;

DEFINE _montoTotal       	DEC(16,2);
DEFINE _montoPagado      	DEC(16,2);

DEFINE _no_poliza        	CHAR(10); 
define _fecha				date;
DEFINE _nombre_cobrador  	CHAR(100);
DEFINE _cod_pagador      	CHAR(10);

DEFINE v_cantidad		   	INTEGER;
DEFINE v_monto_pagado      	DEC(16,2);
DEFINE v_por_vencer        	DEC(16,2);
DEFINE v_exigible          	DEC(16,2);
DEFINE v_corriente         	DEC(16,2);
DEFINE v_monto_30          	DEC(16,2);
DEFINE v_monto_60          	DEC(16,2);
DEFINE v_monto_90          	DEC(16,2);
DEFINE v_compania_nombre   	CHAR(50);

DEFINE _mes_contable      	CHAR(2);
DEFINE _ano_contable      	CHAR(4);
DEFINE _periodo           	CHAR(7);

SET ISOLATION TO DIRTY READ;

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_hasta);

IF MONTH(a_hasta) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_hasta);
ELSE
	LET _mes_contable = MONTH(a_hasta);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

-- Tabla Temporal 

CREATE TEMP TABLE tmp_pagos(
		no_documento    CHAR(20)	NOT NULL,
		monto_pagado    DEC(16,2)	NOT NULL
		) WITH NO LOG;

CREATE TEMP TABLE tmp_moros(
		nombre_pagador  CHAR(100),
		monto_pagado    DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL,
		cnt_por_vencer  SMALLINT    DEFAULT 0 NOT NULL,
		cnt_exigible    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_corriente   SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_30    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_60    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_90    SMALLINT    DEFAULT 0 NOT NULL
		) WITH NO LOG;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

FOREACH
 SELECT d.doc_remesa, 
        d.monto,
		d.fecha
   INTO _doc_poliza,
    	_monto_pagado,
		_fecha
   FROM cobremae m, cobredet d
  WHERE m.no_remesa    = d.no_remesa
    and d.actualizado  = 1			              -- Recibo este actualizado
    AND d.tipo_mov     IN ('P', 'N')           	  -- Pago de Prima(P)
    AND date_posteo    >= a_desde
	and date_posteo    <= a_hasta

	Let _no_poliza = sp_sis21(_doc_poliza);

	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 4 then	--Reaseguro Asumido
		continue foreach;
	End if

	INSERT INTO tmp_pagos(
	no_documento,
	monto_pagado
	)
	VALUES(
	_doc_poliza,
	_monto_pagado
	);

END FOREACH

FOREACH 
 SELECT no_documento,
		SUM(monto_pagado)
   INTO	_doc_poliza,     
		_monto_pagado
   FROM tmp_pagos
  GROUP BY no_documento

	Let _no_poliza = sp_sis21(_doc_poliza);

	 SELECT	cod_tipoprod,
			cod_pagador
	  INTO	_cod_tipoprod,
			_cod_pagador
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

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

	select nombre
	  into _nombre_cobrador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	INSERT INTO tmp_moros(
	nombre_pagador,
	monto_pagado,
	por_vencer,
	exigible,
	corriente,
	monto_30,
	monto_60,
	monto_90,
	cnt_por_vencer,
	cnt_exigible,
	cnt_corriente,
	cnt_monto_30,
	cnt_monto_60,
	cnt_monto_90
	)
	VALUES(
	_nombre_cobrador,
	_monto_pagado,
	_por_vencer,
	_exigible,
	_corriente,
	_monto_30,
	_monto_60,
	_monto_90,
	_cnt_por_vencer,
	_cnt_exigible,
	_cnt_corriente,
	_cnt_monto_30,
	_cnt_monto_60,
	_cnt_monto_90
	);
    
END FOREACH

FOREACH
 SELECT	nombre_pagador,
		COUNT(*),
		SUM(monto_pagado),    
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90),
		SUM(cnt_por_vencer),
		SUM(cnt_exigible),
		SUM(cnt_corriente),
		SUM(cnt_monto_30),
		SUM(cnt_monto_60),
		SUM(cnt_monto_90)
   INTO	_nombre_cobrador,
		v_cantidad,
   		v_monto_pagado,    
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		_cnt_por_vencer,
		_cnt_exigible,
		_cnt_corriente,
		_cnt_monto_30,
		_cnt_monto_60,
		_cnt_monto_90
   FROM	tmp_moros
  GROUP BY nombre_pagador
  ORDER BY nombre_pagador

	 LET _cnt_exigible = _cnt_corriente + _cnt_monto_30 + _cnt_monto_60 + _cnt_monto_90; 
    
	RETURN 	_nombre_cobrador,
			v_cantidad,
			v_monto_pagado,    
			_cnt_por_vencer,
			v_por_vencer,     
			_cnt_exigible,
			v_exigible,       
			_cnt_corriente,
			v_corriente,     
			_cnt_monto_30,
			v_monto_30,       
			_cnt_monto_60,
			v_monto_60,       
			_cnt_monto_90,
			v_monto_90,
	  		v_compania_nombre
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;
DROP TABLE tmp_pagos;

END PROCEDURE;
