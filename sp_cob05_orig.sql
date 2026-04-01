-- Procedimiento que Genera la Morosidad Total por Ramo
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob05;

CREATE PROCEDURE "informix".sp_cob05(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)

DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		no_poliza       CHAR(10)	NOT NULL,
		tipo_produccion CHAR(10)    NOT NULL,
		cod_ramo        CHAR(3)     NOT NULL,
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL, 
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE INDEX idx_tmp_moros_1 ON tmp_moros(tipo_produccion, cod_ramo);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob02.trc";

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

-- Coaseguro Minoritario

BEGIN 

DEFINE _no_poliza         CHAR(10);
DEFINE _tipo_produccion   CHAR(10);
DEFINE _cod_ramo          CHAR(3); 
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);

DEFINE _cod_tipoprod      CHAR(3);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;

-- Se Determina el Codigo del Coaseguro Minoritario
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

LET _tipo_produccion = 'Coaseguro';

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 3;

-- Seleccion de la Polizas

FOREACH 
 SELECT no_poliza,
		cod_ramo,
		saldo,
		fecha_ult_pago
   INTO	_no_poliza,     
		_cod_ramo,   
		_poliza_saldo,
		_poliza_ult_pago
   FROM emipomae 
  WHERE cod_compania       = a_compania		-- Seleccion por Compania
    AND actualizado        = 1			   	-- Poliza este actualizada
	AND cod_tipoprod       = _cod_tipoprod  -- Coaseguro Minoritario
	AND periodo           <= _periodo		-- No Incluye Periodos Futuros
	AND fecha_suscripcion <= a_fecha		-- Hechas durante y antes de la fecha seleccionada

	-- 	Verificacion para las polizas ya pagadas

	IF _poliza_saldo = 0 THEN
		IF _poliza_ult_pago IS NOT NULL THEN
			IF a_fecha >= _poliza_ult_pago THEN
				CONTINUE FOREACH;
			END IF
		END IF
	END IF

	-- Procedimiento que genera la morosidad para una poliza

	CALL sp_cob01(
		 _no_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _prima_orig,
    				 _saldo,            
    				 _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90;         

	IF _saldo = 0 THEN
		CONTINUE FOREACH;
	END IF

	-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_moros(
	no_poliza,
	tipo_produccion,
	cod_ramo,      
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90
	)
	VALUES(
	_no_poliza,
	_tipo_produccion,
	_cod_ramo,      
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90
	);

END FOREACH

END

-- Cartera de Agentes

BEGIN 

DEFINE _no_poliza         CHAR(10);
DEFINE _tipo_produccion   CHAR(10);
DEFINE _cod_ramo          CHAR(3); 
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;


-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

LET _tipo_produccion = 'Cartera';

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Sin Coaseguro

-- Seleccion de la Polizas

FOREACH 
 SELECT no_poliza,
		cod_ramo,
		saldo,
		fecha_ult_pago
   INTO	_no_poliza,     
		_cod_ramo,   
		_poliza_saldo,
		_poliza_ult_pago
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
	AND periodo           <= _periodo		   -- No Incluye Periodos Futuros
	AND fecha_suscripcion <= a_fecha		   -- Hechas durante y antes de la fecha seleccionada

-- 	Verificacion para las polizas ya pagadas

	IF _poliza_saldo = 0 THEN
		IF _poliza_ult_pago IS NOT NULL THEN
			IF a_fecha >= _poliza_ult_pago THEN
				CONTINUE FOREACH;
			END IF
		END IF
	END IF

	-- Procedimiento que genera la morosidad para una poliza

	CALL sp_cob01(
		 _no_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _prima_orig,
    				 _saldo,            
    				 _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90;         

	IF _saldo = 0 THEN
		CONTINUE FOREACH;
	END IF

	-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_moros(
	no_poliza,
	tipo_produccion,
	cod_ramo,      
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90
	)
	VALUES(
	_no_poliza,
	_tipo_produccion,
	_cod_ramo,      
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90
	);

END FOREACH

END

END PROCEDURE;

