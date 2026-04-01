-- Reporte de Reclamos Pendientes por Ramo
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Se incluye filtro de agente)
--
-- SIS v.2.0 - d_sp_rec02a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec134;

CREATE PROCEDURE "informix".sp_rec134(a_periodo CHAR(7)) RETURNING CHAR(18),CHAR(100),CHAR(20),DATE,DATE,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(255);	

DEFINE v_filtros         CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);				 
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_ultima_fecha    DATE;
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);

DEFINE _nombre_ajust    CHAR(50);
DEFINE _ajust_interno   CHAR(50);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);
define _estatus_reclamo	char(1);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01("001");

-- Cargar el Incurrido

CALL sp_rec02(
"001", 
"001", 
a_periodo,
'*',
'*',
'*',
'*',
'*'
) RETURNING v_filtros; 


SET ISOLATION TO DIRTY READ;
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
		ultima_fecha
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
		v_ultima_fecha
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla

	SELECT cod_reclamante, 
		   fecha_siniestro,
		   estatus_reclamo
	  INTO _cod_cliente,   
	  	   v_fecha_siniestro,
		   _estatus_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	if _estatus_reclamo <> "C" then
		continue foreach;
	end if

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
		   v_ultima_fecha,
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
