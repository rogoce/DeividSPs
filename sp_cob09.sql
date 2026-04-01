-- Procedimiento que Genera las Polizas Vigentes sin Pago
-- 
-- Creado    : 11/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 21/08/2002 - Autor: Amado Perez Mendoza, se incluye la linea "SET ISOLATION TO DIRTY READ"
-- Modificado: 26/08/2002 - Autor: Marquelda Valdelamar, se incluyen los filtros como en morosidad y se corrige saldo
-- SIS v.2.0 - DEIVID, S.A.

---DROP PROCEDURE sp_cob09;

CREATE PROCEDURE "informix".sp_cob09(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)

DEFINE _cod_agente        CHAR(5); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus           CHAR(1); 
DEFINE _forma_pago        CHAR(2);
DEFINE _cod_acreedor	  CHAR(5);
DEFINE _nombre_acreedor   CHAR(50);
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);
DEFINE _nombre_agente	  CHAR(50);
DEFINE _telefono          CHAR(10);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_sucursal      CHAR(3);

DEFINE _fecha_canc        DATE;
DEFINE _fecha_ult_pago    DATE;

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_formapag      CHAR(3);  

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _porcentaje        DEC(16,2);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;

DEFINE _prima_orig_tot    DEC(16,2);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);

DEFINE _count             INTEGER;

LET _count = 0;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";

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
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL, 
		nombre_agente   CHAR(50)	NOT NULL,
		cod_cobrador    CHAR(3)     NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SET ISOLATION TO DIRTY READ;

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Sin Coaseguro

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
-- Vigentes y sin pagos

FOREACH 
 SELECT no_poliza,
		cod_contratante,
		no_documento,
		estatus_poliza,
		cod_formapag,
		vigencia_inic,
		vigencia_final,
		saldo,
		fecha_ult_pago,
		fecha_cancelacion,
		cod_sucursal,
		prima_bruta
   INTO	_no_poliza,     
		_cod_cliente,   
		_doc_poliza,    
		_estatus,       
		_cod_formapag,  
		_vigencia_inic, 
		_vigencia_final,
		_poliza_saldo,
		_poliza_ult_pago,
		_fecha_canc,
		_cod_sucursal,
		_prima_orig_tot
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
	AND vigencia_final    >= a_fecha		   -- Polizas Vigentes

	-- Si la poliza se cancelo en la fecha pedida
	-- no se debe tomar en cuenta

	IF _fecha_canc IS NOT NULL THEN
		IF _fecha_canc <= a_fecha THEN
			CONTINUE FOREACH;
		END IF
	END IF

	-- Se determina la fecha del ultimo pago
	LET _fecha_ult_pago = NULL;

   FOREACH
	SELECT fecha
	  INTO _fecha_ult_pago
	  FROM cobredet
	 WHERE no_poliza    = _no_poliza	-- Recibos de la Poliza
	   AND actualizado  = 1			    -- Recibo este actualizado
	   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
	   AND periodo     <= _periodo	    -- No Incluye Periodos Futuros
	   AND fecha       <= a_fecha	    -- Hechas durante y antes de la fecha seleccionada
	 ORDER BY fecha DESC

		EXIT FOREACH;

	END FOREACH

	IF _fecha_ult_pago IS NOT NULL THEN
		CONTINUE FOREACH;
	END IF

   {	-- Procedimiento que genera la morosidad para una poliza
  	CALL sp_cob01(
		 _no_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _prima_orig_tot,
    				 _saldo_tot,            
    				 _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot;         }

-- Procedimiento que genera la morosidad para un documento
   CALL sp_cob33(
        a_compania, 
        '001', 
        _doc_poliza,
		_periodo,
        a_fecha 
        ) RETURNING _por_vencer_tot,    
					_exigible_tot,      
					_corriente_tot,    
					_monto_30_tot,      
					_monto_60_tot,      
					_monto_90_tot,
					_saldo_tot;     

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

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		SELECT nombre,
			   cod_cobrador
		 INTO  _nombre_agente,
			   _cod_cobrador
		 FROM  agtagent
		WHERE  cod_agente = _cod_agente;     

		LET _prima_orig = _prima_orig_tot / 100 * _porcentaje;
		LET _saldo      = _saldo_tot      / 100 * _porcentaje;
		LET _por_vencer = _por_vencer_tot / 100 * _porcentaje;
		LET _exigible   = _exigible_tot   / 100 * _porcentaje;
		LET _corriente  = _corriente_tot  / 100 * _porcentaje;
		LET _monto_30   = _monto_30_tot   / 100 * _porcentaje;
		LET _monto_60   = _monto_60_tot   / 100 * _porcentaje;
		LET _monto_90   = _monto_90_tot   / 100 * _porcentaje;
		 	   	
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
		prima_orig,    
		saldo,          
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90,
		nombre_agente,
		cod_cobrador,
		cod_sucursal
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
		_prima_orig,    
		_saldo,          
		_por_vencer,     
		_exigible,       
		_corriente,     
		_monto_30,       
		_monto_60,       
		_monto_90,
		_nombre_agente,
		_cod_cobrador,
		_cod_sucursal
		);

	END FOREACH

END FOREACH

END PROCEDURE;

