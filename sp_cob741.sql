-- Procedimiento que Genera la Morosidad de Cartera
-- 
-- Creado    : 15/01/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob741;		

CREATE PROCEDURE "informix".sp_cob741(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_fecha      DATE,   
a_tipo_moros CHAR(1) DEFAULT '1' 
) 
--RETURNING CHAR(20);

DEFINE _cod_agente,_cod_producto  CHAR(5); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus           CHAR(1); 
DEFINE _forma_pago        CHAR(2);
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 
DEFINE _fecha_ult_pago    DATE;
DEFINE _monto_ult_pago    DEC(16,2);    
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _saldo_sin         DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);
DEFINE _nombre_agente	  CHAR(50);
DEFINE _telefono          CHAR(10);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_vendedor      CHAR(3);
DEFINE _nombre_acreedor	  CHAR(50);
DEFINE _nombre_coasegur	  CHAR(50);

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_formapag      CHAR(3);  
DEFINE _cod_coasegur      CHAR(3);
DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_sucursal      CHAR(3);
DEFINE _cod_ramo          CHAR(3);

DEFINE v_cod_tipoprod     CHAR(3);
DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _porcentaje        DEC(16,2);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;
DEFINE _no_unidad         CHAR(5);
DEFINE _tipo_produccion   SMALLINT;

DEFINE _prima_orig_tot    DEC(16,2);
DEFINE _saldo_tot, _saldo_sin_imp DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _incobrable		  INTEGER;
DEFINE _apartado          CHAR(20);
define _porc_impuesto     dec(16,2);	
DEFINE _count             INTEGER;

LET _count = 0;

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		cod_agente		CHAR(5)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		estatus         CHAR(1)     NOT NULL,
		forma_pago      CHAR(2)		NOT NULL,
		vigencia_inic   DATE,
		vigencia_final  DATE,
		fecha_ult_pago  DATE,
		monto_ult_pago  DEC(16,2),
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo_sin_imp   DEC(16,2)   DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		nombre_agente   CHAR(50)	NOT NULL,
		telefono		CHAR(10),
		cod_cobrador    CHAR(3)     NOT NULL,
		cod_vendedor    CHAR(3)     NOT NULL,
		nombre_acreedor CHAR(50),
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_acreedor    CHAR(5),
		cod_ramo        CHAR(3),
		cod_formapago   CHAR(3),
		cod_cliente     CHAR(10),
		incobrable		INTEGER,
		cod_coasegur	CHAR(3),
		apartado        CHAR(20),
		cod_producto	CHAR(5),
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);
CREATE INDEX xie03_tmp_moros ON tmp_moros(cod_acreedor);

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Coaseguro Mayoritario

{SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Sin Coaseguro}

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

-- Seleccion de la Polizas

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";   
--TRACE ON;                                                                  

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND cod_tipoprod      = _cod_tipoprod1  -- Coaseguro Mayoritario
  GROUP BY no_documento		


	CALL sp_cob741b(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _saldo_sin_imp, _saldo_tot;         
    				 

 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

	IF a_tipo_moros = '1' THEN -- Diferente de Cero
		IF _saldo_tot = 0 THEN
			CONTINUE FOREACH;
		END IF
	ELIF a_tipo_moros = '2' THEN -- Mayores de Cero
	 	IF _saldo_tot <= 0 THEN                   
			CONTINUE FOREACH;
		END IF
	ELIF a_tipo_moros = '3' THEN -- Menores de Cero
	 	IF _saldo_tot >= 0 THEN                   
			CONTINUE FOREACH;
		END IF
	ELSE
 	END IF                                      

	FOREACH
	 SELECT	no_poliza,
			cod_contratante,
		    estatus_poliza,
		   	cod_formapag,
		   	vigencia_inic,
		    vigencia_final,
		    fecha_ult_pago,
		    sucursal_origen,
		    prima_bruta,
		    cod_ramo,
		    incobrable,
		    cod_tipoprod	   
	   INTO	_no_poliza,
			_cod_cliente,   
		   _estatus,       
		   _cod_formapag,  
		   _vigencia_inic, 
		   _vigencia_final,
		   _poliza_ult_pago,
		   _cod_sucursal,
		   _prima_orig_tot,
		   _cod_ramo,
		   _incobrable,
		   v_cod_tipoprod
	   FROM	emipomae
	  WHERE no_documento       = _doc_poliza
		AND actualizado        = 1			   	   -- Poliza este actualizada
		AND cod_tipoprod      = _cod_tipoprod1 --OR -- Coaseguro Mayoritario
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

	-- Lectura de Tablas Relacionadas
--Compania Coaseguradora
	SELECT cod_coasegur
	  INTO _cod_coasegur
	  FROM emicoami
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_coasegur
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;

	IF _nombre_coasegur IS NULL THEN
		LET _nombre_coasegur = '... Aseguradora Incorrecta ...';
	END IF

--Cliente de la poliza
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
--Forma de Pago
	SELECT nombre
	  INTO _forma_pago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _forma_pago IS NULL THEN
		LET _forma_pago = '';
	END IF

--Estatus de la Poliza
	IF _estatus = '2' THEN -- Poliza Cancelada
		LET _estatus = 'C';
	ELSE
		LET _estatus = '';
	END IF

-- Selecciona el Primer Acreedor de la Poliza

	LET _nombre_acreedor = '... SIN ACREEDOR ...';
	LET _cod_acreedor    = '';

	FOREACH
	 SELECT	cod_acreedor,	no_unidad
	   INTO	_cod_acreedor,	_no_unidad
	   FROM emipoacr
	  WHERE	no_poliza = _no_poliza
	  ORDER BY no_unidad

		IF _cod_acreedor IS NOT NULL THEN

			SELECT nombre
			  INTO _nombre_acreedor
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			EXIT FOREACH;

		END IF

	END FOREACH

	IF _cod_acreedor IS NULL THEN
		LET _cod_acreedor = '';
	END	IF
	-- Se determina el producto
	FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	emipouni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH
	-- Se determina la fecha y el monto
	-- del ultimo pago

	LET _fecha_ult_pago = NULL;

   FOREACH
	SELECT fecha, 
	       monto
	  INTO _fecha_ult_pago,
	  	   _monto_ult_pago
	  FROM cobredet
	 WHERE doc_remesa   = _doc_poliza	-- Recibos de la Poliza
	   AND actualizado  = 1			    -- Recibo este actualizado
	   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
       AND periodo     <= _periodo	    -- No Incluye Periodos Futuros
--	   AND fecha       <= a_fecha	    -- Hechas durante y antes de la fecha seleccionada
	 ORDER BY fecha DESC
		EXIT FOREACH;
	END FOREACH

	IF _fecha_ult_pago IS NULL THEN
		LET _monto_ult_pago = 0;
	END IF

	-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		SELECT nombre,
			   telefono1,
			   cod_cobrador,
			   cod_vendedor,
			   apartado
		 INTO  _nombre_agente,
			   _telefono,
			   _cod_cobrador,
			   _cod_vendedor,
			   _apartado
		 FROM  agtagent
		WHERE  cod_agente = _cod_agente;     

		LET _prima_orig = _prima_orig_tot / 100 * _porcentaje;
		LET _saldo      = _saldo_tot      / 100 * _porcentaje;
		LET _saldo_sin	= _saldo_sin_imp  / 100 * _porcentaje;

	END FOREACH
		 	   	
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
		fecha_ult_pago,
		monto_ult_pago,
		prima_orig,    
		saldo, 
		saldo_sin_imp,         
		nombre_agente,
		telefono,
		cod_cobrador,
		cod_vendedor,
		nombre_acreedor,        
		cod_sucursal,
		cod_acreedor,
		cod_ramo,
		cod_formapago,
		cod_cliente,
		incobrable,
		cod_coasegur,
		apartado,
		cod_producto
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
		_fecha_ult_pago,
		_monto_ult_pago,
		_prima_orig,    
		_saldo_tot, 
		_saldo_sin_imp,         
		_nombre_agente,
		_telefono,
		_cod_cobrador,
		_cod_vendedor,
		_nombre_acreedor,       
		_cod_sucursal,
		_cod_acreedor,
		_cod_ramo,
		_cod_formapag,
		_cod_cliente,
		_incobrable,
		_cod_coasegur,
		_apartado,
		_cod_producto
		);

END FOREACH

END PROCEDURE;
