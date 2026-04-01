-- Reporte de Incurrido Neto Total por Tipo de Suceso
-- 
-- Creado    : 08/06/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_sp_rec01g_dw7 - DEIVID, S.A.

DROP PROCEDURE sp_rec01q;

CREATE PROCEDURE "informix".sp_rec01q(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*", 
a_suceso    CHAR(255) DEFAULT "*",
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
DEFINE v_cantidad        INTEGER;
DEFINE v_suceso_nombre	 CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

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
 SELECT cod_suceso,		
 		SUM(pagado_bruto), 		
 		SUM(pagado_neto), 
	    SUM(reserva_bruto), 	
	    SUM(reserva_neto),		
	    SUM(incurrido_bruto),	
	    SUM(incurrido_neto),
		COUNT(*)
   INTO	_cod_suceso,
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		v_cantidad
   FROM tmp_sinis 
  WHERE seleccionado = 1
  GROUP BY cod_suceso
  ORDER BY cod_suceso

	SELECT nombre
	  INTO v_suceso_nombre
	  FROM recsuces
	 WHERE cod_suceso = _cod_suceso;

	RETURN v_suceso_nombre, 	
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

