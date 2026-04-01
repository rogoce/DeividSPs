-- Analisis de la Cartera de los Corredores a 90 Dias
-- 
-- Creado    : 20/03/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/03/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob45_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob45;		

CREATE PROCEDURE "informix".sp_cob45(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_periodo  CHAR(7)
) RETURNING CHAR(50),	-- Agente
			DEC(16,2),	-- Morosidad 90 Mes Anterior
			DEC(16,2),	-- Pagos Mes Actual
			DEC(16,2),	-- Morosidad Nueva a 90
			DEC(16,2),	-- Morosidad 90 Mes Actual
			DEC(16,2),	-- Saldo Total Mes Actual
			DEC(16,2),	-- Porcentaje de 90 Mes Actual contra Saldo Actual
			CHAR(50),	-- Cobrador
			CHAR(50);	-- Compania

DEFINE _cod_agente       CHAR(5);  
DEFINE _nombre           CHAR(50); 
DEFINE _cod_cobrador	 CHAR(3);
DEFINE _nombre_cobrador  CHAR(50);

DEFINE _saldo_90_ant     DEC(16,2);
DEFINE _pagos            DEC(16,2);
DEFINE _nuevos           DEC(16,2);
DEFINE _saldo_90_act     DEC(16,2);
DEFINE _saldo            DEC(16,2);
DEFINE _porcentaje 		 DEC(16,2);
	
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);  
DEFINE v_compania_nombre CHAR(50); 

-- Nombre de la Compania
set isolation to dirty read;

LET  v_compania_nombre = sp_sis01(a_compania); 

--DROP TABLE tmp_analisis90;

CREATE TEMP TABLE tmp_analisis90(
cod_agente		CHAR(5),
saldo_90_ant	DEC(16,2) DEFAULT 0,
pagos			DEC(16,2) DEFAULT 0,
saldo_90_act	DEC(16,2) DEFAULT 0,
saldo			DEC(16,2) DEFAULT 0
) WITH NO LOG;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob45.trc";   
--TRACE ON;                                                                  

-- Morosidad al Mes Anterior

CALL sp_cob51( 
a_compania,    
a_agencia,     
a_periodo
);             

FOREACH
 SELECT cod_agente,
		SUM(monto_90)
   INTO _cod_agente,
		_saldo_90_ant
   FROM tmp_moros
  GROUP BY cod_agente
                               
	INSERT INTO tmp_analisis90( 
 	cod_agente,                 
 	saldo_90_ant                
	)
 	VALUES(                     
 	_cod_agente,                
 	_saldo_90_ant               
 	);                          
                               
END FOREACH				

DROP TABLE tmp_moros;

-- Morosidad al Mes Actual

CALL sp_cob51( 
a_compania,    
a_agencia,     
a_periodo
);             

FOREACH
 SELECT cod_agente,
		SUM(monto_90),
		SUM(saldo)
   INTO _cod_agente,
		_saldo_90_act,
		_saldo
   FROM tmp_moros
  GROUP BY cod_agente
                               
	INSERT INTO tmp_analisis90( 
 	cod_agente,                 
 	saldo_90_act,
	saldo
	)
 	VALUES(                     
 	_cod_agente,                
 	_saldo_90_act,
	_saldo
 	);                          
	   
END FOREACH				

DROP TABLE tmp_moros;

-- Pagos del Mes Actual
                                                           
CALL sp_cob08(                                             
a_compania,                                                
a_agencia,                                                 
a_periodo,
a_periodo
);                                                         

FOREACH
 SELECT cod_agente,
		SUM(monto_90)
   INTO _cod_agente,
		_pagos
   FROM tmp_moros
  GROUP BY cod_agente
                               
	INSERT INTO tmp_analisis90( 
 	cod_agente,                 
 	pagos
	)
 	VALUES(                     
 	_cod_agente,                
 	_pagos
 	);                          
	   
END FOREACH				

DROP TABLE tmp_moros;

-- Retorna los Valores al DataWindow

FOREACH
 SELECT cod_agente,
		SUM(saldo_90_ant),
		SUM(pagos),		
		SUM(saldo_90_act),
		SUM(saldo)		
   INTO _cod_agente,
		_saldo_90_ant,
		_pagos,		
		_saldo_90_act,
		_saldo
   FROM tmp_analisis90
  GROUP BY cod_agente

	IF _saldo_90_ant = 0 AND 
	   _pagos        = 0 AND
	   _saldo_90_act = 0 AND 
	   _saldo        = 0 THEN
	   CONTINUE FOREACH;
	END IF

	SELECT nombre,
		   cod_cobrador	
	  INTO _nombre,
		   _cod_cobrador	
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO _nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	LET _nuevos = _saldo_90_act - _saldo_90_ant + _pagos; 
	
	IF _saldo = 0 THEN
		LET _porcentaje = 0;
	ELSE
		LET _porcentaje = _saldo_90_act / _saldo;
	END IF

	RETURN _nombre,
		   _saldo_90_ant,
		   _pagos,		
		   _nuevos,		
		   _saldo_90_act,
		   _saldo,
		   _porcentaje,
		   _nombre_cobrador,
		   v_compania_nombre
		   WITH RESUME;
			
END FOREACH				

DROP TABLE tmp_analisis90;

END PROCEDURE