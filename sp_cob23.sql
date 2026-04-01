-- Reporte de Polizas con Avisos de Cancelacion sin Pagos
-- 
-- Creado    : 25/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/05/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_cobr_sp_cob23_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob23;

CREATE PROCEDURE "informix".sp_cob23(a_compania CHAR(3), a_cobrador CHAR(3) DEFAULT '*', a_fecha1 DATE, a_fecha2 DATE) 
RETURNING CHAR(20),	    -- Poliza 
		  DATE,     	-- Vigencia Inic	
		  DATE,     	-- Vigencia Final
		  CHAR(100),	-- Asegurado
		  DATE,     	-- Fecha Aviso	
		  INTEGER,      -- Dias sin Pagar
		  CHAR(50), 	-- Agente
		  CHAR(50), 	-- Cobrador
		  CHAR(50), 	-- Compania
		  DEC(16,2),	-- Prima Bruta
		  DEC(16,2);	-- Saldo

DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_vigencia_inic   DATE;     
DEFINE v_vigencia_final  DATE;     
DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_fecha_aviso	 DATE;
DEFINE v_dias            INTEGER;
DEFINE v_nombre_agente   CHAR(50); 
DEFINE v_nombre_cobrador CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 

DEFINE _cod_cliente      CHAR(10);
DEFINE _no_poliza        CHAR(20);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cobrador     CHAR(3);

DEFINE _prima_bruta		 DEC(16,2);
DEFINE _saldo		     DEC(16,2);

CREATE TEMP TABLE tmp_sin_pago(
	no_poliza		CHAR(10),
	doc_poliza		CHAR(20),
	vigencia_inic 	DATE,
	vigencia_final  DATE,
	nombre_cliente 	CHAR(100),
	fecha_aviso		DATE,
	dias_sin_pago	INTEGER,
	nombre_agente	CHAR(50),
	cod_cobrador    CHAR(3),
	nombre_cobrador CHAR(50),
	prima_bruta		DEC(16,2),
	saldo			DEC(16,2),
	PRIMARY KEY (no_poliza)
	);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 
SET ISOLATION TO DIRTY READ;
FOREACH 
 SELECT no_poliza,
		no_documento,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		fecha_aviso_canc,
		prima_bruta,
		saldo
   INTO _no_poliza,
		v_doc_poliza,
		v_vigencia_inic,
		v_vigencia_final,
		_cod_cliente,
		v_fecha_aviso,
		_prima_bruta,
		_saldo
   FROM emipomae
  WHERE carta_aviso_canc = 1
    AND actualizado      = 1
    AND fecha_aviso_canc >= a_fecha1
    AND fecha_aviso_canc <= a_fecha2
	AND estatus_poliza NOT IN (2, 4)  
	AND saldo           <> 0.00
    AND (TODAY - fecha_aviso_canc) > 15
	AND (fecha_ult_pago IS NULL OR 
	     fecha_aviso_canc > fecha_ult_pago)
	    
		FOREACH 
		 SELECT cod_agente
		   INTO	_cod_agente
		   FROM	emipoagt
		  WHERE	no_poliza = _no_poliza
			EXIT FOREACH;
		END FOREACH

		SELECT nombre,
			   cod_cobrador
		  INTO v_nombre_agente,
		  	   _cod_cobrador
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
		  	   		   	
		SELECT nombre
		  INTO v_nombre_cobrador
		  FROM cobcobra
		 WHERE cod_cobrador = _cod_cobrador;

		SELECT nombre
		  INTO v_nombre_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		LET v_dias = TODAY - v_fecha_aviso;

		INSERT INTO tmp_sin_pago(
		no_poliza,		
		doc_poliza,		
		vigencia_inic, 	
		vigencia_final,  
		nombre_cliente, 	
		fecha_aviso,		
		dias_sin_pago,	
		nombre_agente,	
		cod_cobrador,    
		nombre_cobrador,
		prima_bruta,
		saldo
		)
		VALUES(
		_no_poliza,		
		v_doc_poliza,		
		v_vigencia_inic, 	
		v_vigencia_final,  
		v_nombre_cliente, 	
		v_fecha_aviso,		
		v_dias,	
		v_nombre_agente,	
		_cod_cobrador,    
		v_nombre_cobrador,
		_prima_bruta,
		_saldo
		);		 

END FOREACH

FOREACH
 SELECT	doc_poliza,		
		vigencia_inic, 	
		vigencia_final,  
		nombre_cliente, 	
		fecha_aviso,		
		dias_sin_pago,	
		nombre_agente,	
		nombre_cobrador,
		cod_cobrador,
		prima_bruta,
		saldo
   INTO	v_doc_poliza,		
		v_vigencia_inic, 	
		v_vigencia_final,  
		v_nombre_cliente, 	
		v_fecha_aviso,		
		v_dias,	
		v_nombre_agente,	
		v_nombre_cobrador,
		_cod_cobrador,
		_prima_bruta,
		_saldo
   FROM	tmp_sin_pago
  WHERE cod_cobrador MATCHES a_cobrador
  ORDER BY cod_cobrador, nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	RETURN v_doc_poliza,      
		   v_vigencia_inic,   
		   v_vigencia_final,  
		   v_nombre_cliente,  
		   v_fecha_aviso,		
		   v_dias,	
		   v_nombre_agente,	
		   v_nombre_cobrador, 
		   v_compania_nombre,
		   _prima_bruta,
		   _saldo
		   WITH RESUME;	 		

END FOREACH

DROP TABLE tmp_sin_pago;

END PROCEDURE;

