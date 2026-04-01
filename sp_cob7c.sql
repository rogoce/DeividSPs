-- Procedimiento que Genera la Morosidad Especial de Cartera
-- 
-- Creado    : 11/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/03/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob7c;

CREATE PROCEDURE "informix".sp_cob7c(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)

DEFINE _cod_agente      CHAR(5); 
DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_coasegur	CHAR(3);
DEFINE _cod_formapago   CHAR(3);
DEFINE _cod_acreedor    CHAR(5);
DEFINE _no_unidad      CHAR(5);

DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus,_gestion           CHAR(1); 
DEFINE _forma_pago        CHAR(2);
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
DEFINE _incobrable        INTEGER;

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_formapag      CHAR(3);  
DEFINE _cod_cobrador      CHAR(3);  
DEFINE _cod_ramo          CHAR(3);

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
DEFINE _cant_agentes      INTEGER;

SET ISOLATION TO DIRTY READ;

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
		cod_ramo        CHAR(3)     NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_coasegur	CHAR(3),
		cod_formapago   CHAR(3),
		cod_acreedor    CHAR(5),
		cod_cobrador    CHAR(3)     NOT NULL,
		incobrable      INTEGER,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		gestion		    CHAR(1)		NOT NULL,
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

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
FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento		

	CALL sp_cob06(
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
  				 
 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

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
			cod_ramo,
			prima_bruta,
			incobrable,
			cod_formapag,
			sucursal_origen,
			gestion
	   INTO	_no_poliza,     
			_cod_cliente,   
			_doc_poliza,    
			_estatus,       
			_cod_formapag,  
			_vigencia_inic, 
			_vigencia_final,
			_poliza_saldo,
			_poliza_ult_pago,
			_cod_ramo,
			_prima_orig_tot,
			_incobrable,
			_cod_formapago,
			_cod_sucursal,
			_gestion
	   FROM emipomae 
	  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
	    AND actualizado        = 1			   	   -- Poliza este actualizada
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
		AND no_documento       = _doc_poliza
	  ORDER BY vigencia_final DESC
			EXIT FOREACH;
	END FOREACH

   	IF _incobrable     =   0    AND
   	    _cod_formapag <> "046"  THEN -- No Incluye las Incobrables
		CONTINUE FOREACH;
 	END IF
              

-- Lectura de Tablas Relacionadas
--Compania Coaseguradora
	SELECT cod_coasegur
	  INTO _cod_coasegur
	  FROM emicoami
	 WHERE no_poliza = _no_poliza;

-- Selecciona el Primer Acreedor de la Poliza
	LET _cod_acreedor    = '';

	FOREACH
	 SELECT	cod_acreedor,	no_unidad
	   INTO	_cod_acreedor,	_no_unidad
	   FROM emipoacr
	  WHERE	no_poliza = _no_poliza
	  ORDER BY no_unidad

	END FOREACH

	IF _cod_acreedor IS NULL THEN
		LET _cod_acreedor = '';
	END	IF

-- Cliente de la Poliza
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
	SELECT nombre
	  INTO _forma_pago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

-- Forma de Pago
	IF _forma_pago IS NULL THEN
		LET _forma_pago = '';
	END IF

	IF _gestion IS NULL THEN
		LET _gestion = 'P';
	END IF

	IF _estatus = '2' THEN -- Poliza Cancelada
		LET _estatus = 'C';
	ELSE
		LET _estatus = '';
	END IF

-- Determina todos los agentes de la poliza
	LET _cant_agentes = 0;
	
	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		LET _cant_agentes = _cant_agentes + 1;

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
		cod_ramo,
		cod_sucursal,
		cod_coasegur,
		cod_formapago,
		cod_acreedor,
		cod_cobrador,
		incobrable,
		gestion
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
		_cod_ramo,
		_cod_sucursal,
		_cod_coasegur,
		_cod_formapago,
		_cod_acreedor,
		_cod_cobrador,
		_incobrable,
		_gestion );
	END FOREACH

	IF _cant_agentes = 0 THEN

		LET _prima_orig = _prima_orig_tot;
		LET _saldo      = _saldo_tot;
		LET _por_vencer = _por_vencer_tot;
		LET _exigible   = _exigible_tot;
		LET _corriente  = _corriente_tot;
		LET _monto_30   = _monto_30_tot;
		LET _monto_60   = _monto_60_tot;
		LET _monto_90   = _monto_90_tot;
		 	   	
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
		cod_ramo,
		cod_sucursal,
		cod_coasegur,
		cod_formapago,
		cod_acreedor,
		cod_cobrador,
		incobrable,
		gestion
		)
		VALUES(
		'00000',
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
		'... Corredor Incorrecto ...',
		_cod_ramo,
		_cod_sucursal,
		_cod_coasegur,
		_cod_formapago,
		_cod_acreedor,
		_cod_cobrador,
		_incobrable,
		_gestion);

	END IF

END FOREACH

END PROCEDURE;

