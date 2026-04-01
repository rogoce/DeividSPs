-- Procedimiento que Genera la Morosidad de Cartera para el Analisis 
-- de cartera de los corredores a 90 dias
-- 
-- Creado    : 20/03/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/03/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob51;		

CREATE PROCEDURE "informix".sp_cob51(
a_compania   CHAR(3),
a_agencia    CHAR(3),	
a_periodo	 CHAR(7)
) 

DEFINE _fecha      		  DATE;

DEFINE _cod_agente        CHAR(5); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _doc_poliza        CHAR(20); 
DEFINE _saldo             DEC(16,2);
DEFINE _monto_90          DEC(16,2);

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _mes_contable      SMALLINT;
DEFINE _ano_contable      SMALLINT;
DEFINE _porcentaje        DEC(16,2);

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

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
cod_agente		CHAR(5)		NOT NULL,
saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
monto_90        DEC(16,2)	DEFAULT 0 NOT NULL
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

LET _mes_contable = a_periodo[6,7];
LET _ano_contable = a_periodo[1,4];
LET _fecha        = MDY(_mes_contable, 1, _ano_contable);

-- Seleccion de la Polizas

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";   
--TRACE ON;                                                                  

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento		

{
 	LET _count = _count + 1;  
                            
  	IF _count > 500 THEN 
  		EXIT FOREACH;     
 	END IF                    
}

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo,
		 _fecha
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         

	IF _monto_90_tot = 0 THEN  				 
		CONTINUE FOREACH;
	END IF

	-- Determina todos los agentes de la poliza

	LET _no_poliza = sp_sis21(_doc_poliza);

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		LET _saldo      = _saldo_tot      / 100 * _porcentaje;
		LET _monto_90   = _monto_90_tot   / 100 * _porcentaje;
		 	   	
		-- Actualizacion de la Tabla Temporal

		INSERT INTO tmp_moros(
		cod_agente,
		saldo,          
		monto_90
		)
		VALUES(
		_cod_agente,
		_saldo,          
		_monto_90
		);

	END FOREACH

END FOREACH

END PROCEDURE;
