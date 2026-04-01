-- Reporte de Incurrido Neto por Tipo de Suceso
-- 
-- Creado    : 11/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 14/08/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - d_sp_rec01g_dw7 - DEIVID, S.A.

DROP PROCEDURE sp_rec01g;

CREATE PROCEDURE "informix".sp_rec01g(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*", 
a_suceso    CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 
			CHAR(100), 
			CHAR(20),
			DATE,
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(50),
  		    CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);     
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);     
DEFINE v_suceso_nombre	 CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo       CHAR(10);     
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);      
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);      
DEFINE _cod_suceso		 CHAR(3);      

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
a_ramo, 
'*', 
a_ajustador, 
'*', 
a_suceso
); 

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
		cod_suceso
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		_cod_suceso
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_suceso, cod_ramo, periodo, numrecla

	SELECT cod_reclamante,		fecha_siniestro
	  INTO _cod_cliente,		v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_suceso_nombre
	  FROM recsuces
	 WHERE cod_suceso = _cod_suceso;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	RETURN v_doc_reclamo,
	 	   v_cliente_nombre, 	
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_suceso_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;

