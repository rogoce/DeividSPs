-- Procedimiento que Genera las Polizas a renovar con Saldo
-- 
-- Creado    : 12/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 30/04/2001 - Autor: Marquelda Valdelamar--
-- Modificado: 01/04/2002 - Autor: Armando Moreno, Sacar el saldo del proc. sp_cob85 y no de emipomae.--
-- Modificado: 09/09/2002 - Autor: Marquelda Valdelamar.(excluir coaseguro minoritario y reaseguro asumido)

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob13;

CREATE PROCEDURE "informix".sp_cob13(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo  CHAR(7)
)

DEFINE _cod_agente        CHAR(5); 
DEFINE _cod_ramo          CHAR(3); 
DEFINE _cod_formapago     CHAR(3); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE v_referencia       CHAR(20);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _nombre_agente	  CHAR(50);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_sucursal      CHAR(3);
DEFINE _cod_cliente       CHAR(10); 

DEFINE _vigencia_inic      DATE;     
DEFINE _vigencia_final     DATE; 
DEFINE _prima_orig,v_saldo DEC(16,2);
DEFINE _saldo              DEC(16,2);
DEFINE _prima_bruta		   DEC(16,2);
DEFINE _porcentaje         DEC(16,2);
DEFINE _prima_agente       DEC(16,2);
DEFINE _saldo_agente       DEC(16,2);

DEFINE _no_pagos          SMALLINT;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";
-- Tabla Temporal 
--DROP TABLE tmp_renov;

CREATE TEMP TABLE tmp_renov(
		cod_agente		CHAR(5)		NOT NULL,
		cod_ramo        CHAR(3)     NOT NULL,
		cod_formapago   CHAR(3)     NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		vigencia_inic   DATE,
		vigencia_final  DATE,
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		nombre_agente   CHAR(50)	NOT NULL,
		cod_cobrador    CHAR(3)     NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		prima_bruta	    DEC(16,2),
		no_pagos		SMALLINT,
		seleccionado    SMALLINT	DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_renov ON tmp_renov(cod_sucursal);
CREATE INDEX xie02_tmp_renov ON tmp_renov(cod_cobrador);

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

-- Seleccion de la Polizas
FOREACH 
 SELECT no_poliza,
		cod_contratante,
		no_documento,
		vigencia_inic,
		vigencia_final,
		prima_bruta,
		cod_sucursal,
		cod_ramo,
		cod_formapag,
		prima_bruta,
		no_pagos
   INTO	_no_poliza,     
		_cod_cliente,   
		_doc_poliza,    
		_vigencia_inic, 
		_vigencia_final,
		_prima_orig,
		_cod_sucursal,
		_cod_ramo,
		_cod_formapago,
		_prima_bruta,
		_no_pagos
   FROM emipomae 
  WHERE cod_compania          = a_compania		   -- Seleccion por Compania
    AND actualizado           = 1			   	   -- Poliza este actualizada
	AND YEAR(vigencia_final)  = a_periodo[1,4]
	AND MONTH(vigencia_final) = a_periodo[6,7]
	AND saldo                <> 0
	AND estatus_poliza        IN(1,3)
    AND (cod_tipoprod         = _cod_tipoprod1 OR -- Coaseguro Mayoritario
   	     cod_tipoprod         = _cod_tipoprod2)   -- Sin Coaseguro
	AND renovada              = 0
	AND no_renovar            = 0

	-- Lectura de Tablas Relacionadas

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 

	-- Determina el saldo por documento
	CALL sp_cob85(
		 	a_compania,
		 	a_agencia,	
		 	_doc_poliza
		    ) RETURNING v_saldo;
				
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

		LET _prima_agente = _prima_orig / 100 * _porcentaje;
		LET _saldo_agente = v_saldo     / 100 * _porcentaje;
		 	   	
		-- Actualizacion de la Tabla Temporal

		INSERT INTO tmp_renov(
		cod_agente,
		cod_ramo,
		cod_formapago,
		no_poliza,      
		nombre_cliente, 
		doc_poliza,     
		vigencia_inic,  
		vigencia_final, 
		prima_orig,    
		saldo,          
		nombre_agente,
		cod_cobrador,
		cod_sucursal,
		prima_bruta,
		no_pagos
		)
		VALUES(
		_cod_agente,
		_cod_ramo,
		_cod_formapago,      
		_no_poliza,
		_nombre_cliente, 
		_doc_poliza,     
		_vigencia_inic,  
		_vigencia_final, 
		_prima_orig,    
		v_saldo,          
		_nombre_agente,
		_cod_cobrador,
		_cod_sucursal,
		_prima_bruta,
		_no_pagos
	);

	END FOREACH

END FOREACH

END PROCEDURE;

