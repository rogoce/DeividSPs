-- Reporte de Incurrido Neto por Ramo para Salud
-- 
-- Creado    : 19/04/2002 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - d_sp_rec70_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec70c;

CREATE PROCEDURE "informix".sp_rec70c(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*"
) RETURNING CHAR(5),
            CHAR(18), 
  		    CHAR(20),
  		    CHAR(100), 
  		    DATE,
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
            CHAR(255),
			SMALLINT,
			DATE,
			DATE,
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(50),
			CHAR(50),
			CHAR(7),
  		    CHAR(255);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_fecha_siniestro, v_vigencia_inic_salud, v_vigencia_final_salud  DATE;    
DEFINE v_pagado_cedido    DECIMAL(16,2);
DEFINE v_reserva_cedido   DECIMAL(16,2);
DEFINE v_incurrido_cedido DECIMAL(16,2);     
DEFINE v_pagado_bruto     DECIMAL(16,2);
DEFINE v_pagado_neto      DECIMAL(16,2);
DEFINE v_reserva_bruto    DECIMAL(16,2);
DEFINE v_reserva_neto     DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_incurrido_neto   DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_subramo_nombre   CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     
DEFINE v_filtros          CHAR(255);

DEFINE _no_reclamo, _cod_icd    	CHAR(10);     
DEFINE _no_poliza        			CHAR(10); 
DEFINE _cod_sucursal, _cod_subramo	CHAR(3);          
DEFINE _cod_ramo,v_nombre_icd		CHAR(255);      
DEFINE _cod_cliente      			CHAR(10);     
DEFINE _periodo          			CHAR(7);      
DEFINE _cod_contrato     			CHAR(5);     
DEFINE _cod_contrato_salud  		CHAR(5);     
DEFINE _tipo_contrato, v_serie 		SMALLINT;      
DEFINE _porc_reas         			DECIMAL;   
DEFINE _vigencia_inic, _fecha	    DATE;   

DEFINE _pagado_bruto      		DECIMAL(16,2);
DEFINE _reserva_bruto     		DECIMAL(16,2);
DEFINE _incurrido_bruto   		DECIMAL(16,2);
DEFINE _porc_partic_prima       DECIMAL(9,6);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Tabla Temporal para los Contratos

CREATE TEMP TABLE tmp_contrato1(
		cod_contrato		 CHAR(5),
		no_reclamo           CHAR(10),
		no_poliza            CHAR(10),
		cod_ramo             CHAR(3),
		periodo              CHAR(7),
		numrecla             CHAR(18),
		ultima_fecha         DATE,
		incurrido_bruto      DEC(16,2),
		pagado_bruto         DEC(16,2),
		pagado_cedido        DEC(16,2),
		reserva_cedido       DEC(16,2),
		incurrido_cedido     DEC(16,2),
		cod_sucursal         CHAR(3),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_contrato, no_reclamo, periodo)
		) WITH NO LOG;


-- Cargar el Incurrido

--DROP TABLE tmp_sinis;
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_rec702(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
_cod_ramo, 
'*', 
a_ajustador, 
'*', 
'*'
); 

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

LET _cod_ramo = trim(_cod_ramo);

CALL sp_rec701(a_compania, a_agencia, a_periodo1, a_periodo2, _cod_ramo); 

--SET DEBUG FILE TO "sp_rec70.trc";      
--TRACE ON;                                                                     


FOREACH 
 SELECT no_reclamo,	
        fecha,	
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,		
		periodo,
		numrecla,
		cod_sucursal
   INTO	_no_reclamo, 		
        _fecha,
   		_no_poliza,	   	
   		_pagado_bruto, 		
   		v_pagado_neto, 
	    _reserva_bruto,		
	    v_reserva_neto, 	
	    _incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		_cod_sucursal
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla,periodo
--  ORDER BY cod_ramo, periodo, numrecla

	SELECT cod_reclamante,		fecha_siniestro
	  INTO _cod_cliente,		v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT vigencia_inic
	  INTO _vigencia_inic
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	IF _fecha < _vigencia_inic  THEN
	   LET _fecha = _vigencia_inic;
	END IF

	LET _cod_contrato_salud = NULL;

	SELECT cod_contrato,
		   porc_partic_prima
	  INTO _cod_contrato_salud,
	       _porc_partic_prima
	  FROM tmp_vigencias
	 WHERE no_poliza = _no_poliza
	   AND vigencia_inic <=	_fecha
	   AND vigencia_final >= _fecha;

    IF _cod_contrato_salud IS NULL THEN
	   let _cod_contrato = '00000';
	END IF

	LET v_pagado_cedido    = 0;
	LET v_reserva_cedido   = 0;
	LET v_incurrido_cedido = 0;

	LET v_pagado_cedido    = _pagado_bruto    * _porc_partic_prima / 100;
	LET v_reserva_cedido   = _reserva_bruto   * _porc_partic_prima / 100;
	LET v_incurrido_cedido = _incurrido_bruto * _porc_partic_prima / 100;

	BEGIN
	ON EXCEPTION IN (-239)
		UPDATE tmp_contrato1
		    SET incurrido_bruto  = incurrido_bruto + _incurrido_bruto,
				pagado_bruto  = pagado_bruto + _pagado_bruto,
				pagado_cedido = pagado_cedido + v_pagado_cedido,
				reserva_cedido = reserva_cedido + v_reserva_cedido,
				incurrido_cedido = incurrido_cedido+ v_incurrido_cedido
		  WHERE cod_contrato = _cod_contrato_salud
		    AND no_reclamo = _no_reclamo
		    AND periodo = _periodo;

	END EXCEPTION
		INSERT INTO tmp_contrato1(
		cod_contrato,
		no_reclamo,           
		no_poliza,           
		cod_ramo,            
		periodo,             
		numrecla,            
		incurrido_bruto,
		pagado_bruto,
		pagado_cedido,        
		reserva_cedido,       
		incurrido_cedido,
		cod_sucursal     
		)
		VALUES(
		_cod_contrato_salud,
		_no_reclamo,
		_no_poliza,           
		_cod_ramo,            
		_periodo,             
		v_doc_reclamo,            
		_incurrido_bruto,
		_pagado_bruto,
		v_pagado_cedido,        
		v_reserva_cedido,       
		v_incurrido_cedido,
		_cod_sucursal     
		);
	END

END FOREACH

FOREACH
 SELECT cod_contrato,
		no_reclamo,           
		no_poliza,           
		cod_ramo,            
		periodo,             
		numrecla,  
		incurrido_bruto,          
		pagado_bruto,
		pagado_cedido,        
		reserva_cedido,       
		incurrido_cedido     
   INTO _cod_contrato,
		_no_reclamo,
		_no_poliza,           
		_cod_ramo,            
		_periodo,             
		v_doc_reclamo, 
		_incurrido_bruto,           
		_pagado_bruto,
		v_pagado_cedido,        
		v_reserva_cedido,       
		v_incurrido_cedido     
	 FROM tmp_contrato1
	WHERE seleccionado = 1

	 SELECT nombre,
	        serie,
	        vigencia_inic,
			vigencia_final
	   INTO v_contrato_nombre,
	        v_serie,
	        v_vigencia_inic_salud,
			v_vigencia_final_salud
	   FROM reacomae
	  WHERE cod_contrato = _cod_contrato;

	SELECT cod_reclamante,
	       fecha_siniestro,
	       cod_icd
	  INTO _cod_cliente,
	       v_fecha_siniestro,
	       _cod_icd
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_subramo
	  INTO v_doc_poliza,
	       _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	SELECT nombre
	  INTO v_nombre_icd
	  FROM recicd
	 WHERE cod_icd = _cod_icd;

--	LET v_incurrido_neto = _incurrido_bruto - v_incurrido_cedido;

	RETURN _cod_contrato,
	       v_doc_reclamo,
	       v_doc_poliza,
	 	   v_cliente_nombre, 
	 	   v_fecha_siniestro, 
		   v_pagado_cedido,		
		   v_reserva_cedido,  
		   _incurrido_bruto,	
		   _pagado_bruto,
		   v_incurrido_cedido,	
	       v_nombre_icd,
		   v_serie,
		   v_vigencia_inic_salud,
		   v_vigencia_final_salud,
		   v_ramo_nombre,
		   v_subramo_nombre,
		   v_contrato_nombre,
		   v_compania_nombre,
		   _periodo,
		   v_filtros
		   WITH RESUME;
 END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;
DROP TABLE tmp_vigencias;

END PROCEDURE;
