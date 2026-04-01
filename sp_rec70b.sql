-- Reporte de Incurrido Neto por Ramo para Salud
-- 
-- Creado    : 19/04/2002 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - d_sp_rec70b_dw2 - DEIVID, S.A.

--DROP PROCEDURE sp_rec70b;

CREATE PROCEDURE "informix".sp_rec70b(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*"
) RETURNING CHAR(18),
  		    CHAR(20),
			CHAR(10),
  		    CHAR(100), 
  		    DECIMAL(16,2),
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(255),
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
DEFINE v_filtros,_nombre_icd CHAR(255);

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

DEFINE _pagado_bruto      		DECIMAL(16,2);
DEFINE _reserva_bruto     		DECIMAL(16,2);
DEFINE _incurrido_bruto   		DECIMAL(16,2);

CREATE TEMP TABLE tmp_reclamante(
        no_reclamo      CHAR(18),
		no_poliza   	CHAR(20),
		cod_cliente 	CHAR(10),
		cliente_nombre	CHAR(50), 
		pagado_bruto    DEC(16,2),
		ramo_nombre     CHAR(50),
		subramo_nombre  CHAR(50),
		cod_icd			CHAR(10),
        PRIMARY KEY(cod_cliente)) WITH NO LOG;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Cargar el Incurrido

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

LET _cod_ramo = trim(_cod_ramo) || ';';

LET v_filtros = sp_rec01(
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


FOREACH 
 SELECT no_reclamo,		
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
  ORDER BY cod_ramo,numrecla
--  ORDER BY cod_ramo, periodo, numrecla

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

--     IF _cod_subramo NOT IN ('010','006','007','008','009') THEN
--	    CONTINUE FOREACH;
--	 END IF


    SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	   BEGIN
	      ON EXCEPTION IN(-239)
	         UPDATE tmp_reclamante
	            SET pagado_bruto = pagado_bruto + _pagado_bruto	          
	          WHERE cod_cliente  = _cod_cliente;

	      END EXCEPTION
	      INSERT INTO tmp_reclamante
	          VALUES(v_doc_reclamo,
	                 v_doc_poliza,
					 _cod_cliente,
	                 v_cliente_nombre,
	                 _pagado_bruto,
	                 v_ramo_nombre,
	                 v_subramo_nombre,
					 _cod_icd
	                 );
	   END

 END FOREACH

 FOREACH WITH HOLD
	SELECT no_reclamo,     
		   no_poliza,   	
		   cod_cliente, 	
		   cliente_nombre,	
		   pagado_bruto,   
		   ramo_nombre,    
		   subramo_nombre,
		   cod_icd 
	  INTO v_doc_reclamo,
		   v_doc_poliza,
		   _cod_cliente,
		   v_cliente_nombre,
		   _pagado_bruto,
		   v_ramo_nombre,
		   v_subramo_nombre,
		   _cod_icd
	  FROM tmp_reclamante
	ORDER BY subramo_nombre, pagado_bruto DESC

	SELECT nombre
	  INTO _nombre_icd
	  FROM recicd
	 WHERE cod_icd = _cod_icd;

	RETURN v_doc_reclamo,
	       v_doc_poliza,
		   _cod_cliente,
	 	   v_cliente_nombre, 
		   _pagado_bruto,
		   v_ramo_nombre,
		   v_subramo_nombre,
		   v_compania_nombre,
		   v_filtros,
		   _nombre_icd
		   WITH RESUME;
 END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_reclamante;


END PROCEDURE;
