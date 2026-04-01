-- Procedimiento que Genera la Morosidad Total por Ramo
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/01/2002 Adicion del campo Grupo - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob5m;

CREATE PROCEDURE "informix".sp_cob5m(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _incobrable        INT;

DEFINE 	_cod_coasegur	CHAR(3);
DEFINE 	_cod_sucursal	CHAR(3);
DEFINE	_cod_ramo       CHAR(3);
DEFINE  _cod_formapago  CHAR(3);
DEFINE  _cod_acreedor   CHAR(5);
DEFINE  _cod_grupo      CHAR(5);
DEFINE  _cod_agente		CHAR(5);
DEFINE  _cod_cobrador   CHAR(3); 
DEFINE  _no_unidad      CHAR(5);

SET ISOLATION TO DIRTY READ;
 
-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		no_poliza       CHAR(10)	NOT NULL,
		tipo_produccion CHAR(10)    NOT NULL,
		doc_poliza      CHAR(20),
		cod_ramo        CHAR(3),
		cod_grupo       CHAR(5),  
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL, 
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_coasegur	CHAR(3),
		cod_formapago   CHAR(3),
		cod_acreedor    CHAR(5),
		cod_agente		CHAR(5)		NOT NULL,
		cod_cobrador    CHAR(3)     NOT NULL,
		incobrable      INTEGER,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE INDEX idx_tmp_moros_1 ON tmp_moros(tipo_produccion, cod_ramo);
CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);
CREATE INDEX xie03_tmp_moros ON tmp_moros(cod_acreedor);

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

BEGIN 

DEFINE _no_poliza         CHAR(10);
DEFINE _tipo_produccion   CHAR(10);
DEFINE _cod_ramo          CHAR(3); 
DEFINE _prima_orig            DEC(16,2);
DEFINE _saldo_tot             DEC(16,2);
DEFINE _por_vencer_tot        DEC(16,2);
DEFINE _exigible_tot          DEC(16,2);
DEFINE _corriente_tot         DEC(16,2);
DEFINE _monto_30_tot          DEC(16,2);
DEFINE _monto_60_tot          DEC(16,2);
DEFINE _monto_90_tot          DEC(16,2);

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _cod_tipoprod      CHAR(3);
DEFINE _cod_tipo_pol	  CHAR(3);	
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_final    DATE;

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 3;

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
 SELECT no_documento
   INTO	_no_documento
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2) 
	  --   cod_tipoprod      = _cod_tipoprod)    -- Sin Coaseguro
  GROUP BY no_documento

	-- Procedimiento que genera la morosidad para una poliza

{	CALL sp_cob33(
		 a_compania,
		 a_agencia,
		 _no_documento,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo;          }

	CALL sp_cob06(
		 _no_documento,
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
	       vigencia_final,
		   cod_ramo,
		   cod_grupo,
		   prima_bruta,
		   cod_formapag,
		   incobrable,
		   sucursal_origen,
		   cod_tipoprod
	  INTO _no_poliza,
	       _vigencia_final,
		   _cod_ramo,
		   _cod_grupo,
		   _prima_orig,
		   _cod_formapago,
		   _incobrable,
		   _cod_sucursal,
		   _cod_tipo_pol
	  FROM emipomae
	 WHERE no_documento       = _no_documento
	   AND actualizado        = 1
	   AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	        cod_tipoprod      = _cod_tipoprod2) 
	       -- cod_tipoprod      = _cod_tipoprod)   -- Sin Coaseguro
	 ORDER BY vigencia_final DESC
		EXIT FOREACH;
   END FOREACH

{
	IF _incobrable = 1 THEN	     -- No Incluye las Incobrables
		CONTINUE FOREACH;
 	END IF                                      

    IF _cod_formapago = "046" THEN    -- No Incluye las Cuentas en Abogado
		CONTINUE FOREACH;
 	END IF   
}

-- Seleccion de Tablas Relacionadas
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

	-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente
	   INTO	_cod_agente
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		SELECT cod_cobrador
    	  INTO _cod_cobrador			   
		 FROM  agtagent
		WHERE  cod_agente = _cod_agente;     
	 EXIT FOREACH;
	 END FOREACH

	IF _cod_tipo_pol = _cod_tipoprod THEN

		LET _tipo_produccion = 'Coaseguro';

		SELECT cod_coasegur
		  INTO _cod_ramo
		  FROM emicoami
		 WHERE no_poliza = _no_poliza;

	ELSE
		LET _tipo_produccion = 'Cartera';
	END IF

	-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_moros(
	no_poliza,
	tipo_produccion,
	doc_poliza,
	cod_ramo,      
	cod_grupo,
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90,
	cod_sucursal,
	cod_coasegur,
	cod_formapago,
	cod_acreedor,
	cod_agente,
	cod_cobrador,
	incobrable
	)
	VALUES(
	_no_poliza,
	_tipo_produccion,
	_no_documento,
	_cod_ramo,
	_cod_grupo,      
	_prima_orig,    
	_saldo_tot,          
	_por_vencer_tot,     
	_exigible_tot,       
	_corriente_tot,     
	_monto_30_tot,       
	_monto_60_tot,       
	_monto_90_tot,
	_cod_sucursal,
	_cod_coasegur,
	_cod_formapago,
	_cod_acreedor,
	_cod_agente,
	_cod_cobrador,
	_incobrable	);

END FOREACH

END

END PROCEDURE;

