-- Reporte de Incurrido Neto por Tipo de Evento
-- 
-- Creado    : 08/06/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_sp_rec01f_dw6 - DEIVID, S.A.

--DROP PROCEDURE sp_rec01P;

CREATE PROCEDURE "informix".sp_rec01P(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*", 
a_evento    CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*"
) RETURNING CHAR(50), 
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			INTEGER,
  		    CHAR(255);

DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_evento_nombre	 CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);
DEFINE v_cantidad        INTEGER;

DEFINE _cod_evento		 CHAR(3);      

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
a_evento, 
'*'
); 

FOREACH 
 SELECT cod_evento,		
 		SUM(pagado_bruto), 		
 		SUM(pagado_neto), 
	    SUM(reserva_bruto), 	
	    SUM(reserva_neto),		
	    SUM(incurrido_bruto),	
	    SUM(incurrido_neto),
		COUNT(*)
   INTO	_cod_evento,
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		v_cantidad
   FROM tmp_sinis 
  WHERE seleccionado = 1
  GROUP BY cod_evento
  ORDER BY cod_evento

  	SELECT nombre
	  INTO v_evento_nombre
	  FROM recevent
	 WHERE cod_evento = _cod_evento;

  	RETURN v_evento_nombre, 	
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
           v_compania_nombre,
		   v_cantidad,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;

