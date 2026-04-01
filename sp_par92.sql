-- Procedimiento que Genera la Morosidad Total por Ramo basado en prima neta
-- Especial Gerencia
-- Creado    : 18/02/2003 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par92;

CREATE PROCEDURE "informix".sp_par92(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
) RETURNING CHAR(50),  -- Nombre Ramo
			INTEGER,   -- Cantidad de Polizas	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Compania
			CHAR(255); -- Filtros


DEFINE _mes_contable     CHAR(2);
DEFINE _ano_contable     CHAR(4);
DEFINE _periodo          CHAR(7);
DEFINE _incobrable       INT;
DEFINE 	_cod_coasegur	 CHAR(3);
DEFINE 	_cod_sucursal	 CHAR(3);
DEFINE	_cod_ramo        CHAR(3);
DEFINE  _cod_formapago   CHAR(3);
DEFINE  _cod_acreedor    CHAR(5);
DEFINE  _cod_grupo       CHAR(5);
DEFINE  _cod_agente		 CHAR(5);
DEFINE  _gestion		 CHAR(1);
DEFINE  _cod_cobrador    CHAR(3); 
DEFINE  _no_unidad       CHAR(5);
DEFINE _porc_partic_coas DEC(7,4);

DEFINE v_nombre_ramo       CHAR(50);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE v_filtros           CHAR(255);

SET ISOLATION TO DIRTY READ;

let v_filtros = "";
LET  v_compania_nombre = sp_sis01(a_compania); 
 
-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		no_poliza       CHAR(10)	NOT NULL,
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
		cod_formapago   CHAR(3),
		cod_acreedor    CHAR(5),
		cod_agente		CHAR(5)		NOT NULL,
		cod_cobrador    CHAR(3)     NOT NULL,
		incobrable      INTEGER,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		gestion		    CHAR(1)		NOT NULL,
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

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
DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _cod_tipoprod4     CHAR(3);
DEFINE _cod_tipo_pol	  CHAR(3);	
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_final    DATE;

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

LET _prima_orig = 0;
LET _saldo      = 0;
LET _por_vencer = 0;
LET _exigible   = 0;
LET _corriente  = 0;
LET _monto_30   = 0;
LET _monto_60   = 0;
LET _monto_90   = 0;

-- Seleccion de la Polizas

FOREACH 
 SELECT no_documento
   INTO	_no_documento
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	and cod_tipoprod       = "002"
  GROUP BY no_documento

	let _no_poliza = sp_sis21(_no_documento);

	SELECT vigencia_final,
		   cod_ramo,
		   cod_grupo,
		   cod_formapag,
		   incobrable,
		   sucursal_origen,
		   cod_tipoprod,
		   gestion,
		   prima_bruta
	  INTO _vigencia_final,
		   _cod_ramo,
		   _cod_grupo,
		   _cod_formapago,
		   _incobrable,
		   _cod_sucursal,
		   _cod_tipo_pol,
		   _gestion,
		   _prima_orig
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipo_pol <> "002" THEN
    	CONTINUE FOREACH;
  	END IF

	CALL sp_cob33(
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
					 _saldo;          

{
	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
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
}

	IF _saldo = 0 THEN
		CONTINUE FOREACH;
	END IF

	-- Selecciona el Primer Acreedor de la Poliza
	LET _cod_acreedor    = '';

	FOREACH
	 SELECT	cod_acreedor,
	 		no_unidad
	   INTO	_cod_acreedor,
	   		_no_unidad
	   FROM emipoacr
	  WHERE	no_poliza = _no_poliza
	  ORDER BY no_unidad
	END FOREACH

	IF _cod_acreedor IS NULL THEN
		LET _cod_acreedor = '';
	END	IF

	-- Determina un agente de la poliza y su cobrador

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

	--filtro de gestion.
	IF _gestion IS NULL THEN
		LET _gestion = 'P';  --Pendiente
	END IF

	IF _prima_orig IS NULL THEN
		LET _prima_orig = 0;
	END	IF
	IF _saldo IS NULL THEN
		LET _saldo = 0;
	END	IF
	IF _por_vencer IS NULL THEN
		LET _por_vencer = 0;
	END	IF
	IF _exigible IS NULL THEN
		LET _exigible = 0;
	END	IF
	IF _corriente IS NULL THEN
		LET _corriente = 0;
	END	IF
	IF _monto_30 IS NULL THEN
		LET _monto_30 = 0;
	END	IF
	IF _monto_60 IS NULL THEN
		LET _monto_60 = 0;
	END	IF
	IF _monto_90 IS NULL THEN
		LET _monto_90 = 0;
	END	IF

	-- Insercion de la Tabla Temporal
	INSERT INTO tmp_moros(
	no_poliza,
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
	cod_formapago,
	cod_acreedor,
	cod_agente,
	cod_cobrador,
	incobrable,
	gestion
	)
	VALUES(
	_no_poliza,
	_no_documento,
	_cod_ramo,
	_cod_grupo,      
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90,
	_cod_sucursal,
	_cod_formapago,
	_cod_acreedor,
	_cod_agente,
	_cod_cobrador,
	_incobrable,
	_gestion);

END FOREACH

FOREACH
 SELECT	cod_ramo,       
		COUNT(*),
 		SUM(prima_orig),    
		SUM(saldo),          
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90)
   INTO	_cod_ramo,       
		v_cantidad,
   		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros		  
  WHERE seleccionado = 1
  GROUP BY cod_ramo
  ORDER BY cod_ramo

  SELECT nombre
    INTO v_nombre_ramo
    FROM prdramo
   WHERE cod_ramo = _cod_ramo;

	RETURN 	v_nombre_ramo,
			v_cantidad,
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_compania_nombre,
			v_filtros        
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END

END PROCEDURE;
