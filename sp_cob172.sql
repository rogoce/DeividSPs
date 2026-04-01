-- Procedimiento que Genera la Morosidad de Cartera para Semusa
-- 
-- Creado    : 23/10/2004 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob172;		

CREATE PROCEDURE "informix".sp_cob172(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_fecha      DATE,
a_cod_agente char(10)	
) 

DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 

DEFINE _cod_cliente       CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _nombre_ramo       CHAR(50);

DEFINE _cod_tipoprod      CHAR(3);
DEFINE _cod_tipoprod4     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _cod_tipo_pol	  CHAR(3);	

DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		doc_poliza      CHAR(20),
		nombre_cliente  CHAR(100),
		vigencia_inic   DATE,
		vigencia_final  DATE,
		saldo           DEC(16,2),
		ramo			char(50)
		) WITH NO LOG;

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 3;	-- Coaseguro Minoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod4
  FROM emitipro
 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

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

--SET DEBUG FILE TO "sp_cob03.trc";   
--TRACE ON;                                                                  

FOREACH 
 SELECT p.no_documento
   INTO	_doc_poliza
   FROM emipomae p, emipoagt a
  WHERE p.cod_compania       = a_compania		   -- Seleccion por Compania
    AND p.actualizado        = 1
    and p.no_poliza          = a.no_poliza
	and a.cod_agente         = a_cod_agente
--	and p.no_documento       = "0103-00115-01"
  GROUP BY p.no_documento		

	-- Determina la Ultima Vigencia del Documento

	let _no_poliza = sp_sis21(_doc_poliza);

	 SELECT	cod_contratante,
		   	vigencia_inic,
		    vigencia_final,
		    cod_ramo,
			cod_tipoprod
	   INTO	_cod_cliente,   
		    _vigencia_inic, 
		    _vigencia_final,
		    _cod_ramo,
			_cod_tipo_pol
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;

	-- Si la Ultima Vigencia es Reaseguro Asumido no Evalua el Registro
	IF _cod_tipo_pol = _cod_tipoprod4 THEN
    	CONTINUE FOREACH;
  	END IF

	-- Si la Ultima Vigencia es Coas. Minoritario no Evalua el Registro
	IF _cod_tipo_pol = _cod_tipoprod THEN
    	CONTINUE FOREACH;
  	END IF

	-- Procedimiento que genera la morosidad para una poliza

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
    				 
	--Cliente de la poliza
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
	SELECT nombre
	  INTO _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	INSERT INTO tmp_moros(
	doc_poliza,     
	nombre_cliente, 
	vigencia_inic,  
	vigencia_final, 
	saldo,
	ramo
	)
	VALUES(
	_doc_poliza,     
	_nombre_cliente, 
	_vigencia_inic,  
	_vigencia_final, 
	_saldo_tot,
	_nombre_ramo          
	);

END FOREACH

END PROCEDURE;
