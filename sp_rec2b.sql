-- Reporte de Reclamos Pendientes Total por Ramo
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Se incluye filtro de agente)
--
-- SIS v.2.0 - d_sp_rec02b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_rec02b;

CREATE PROCEDURE "informix".sp_rec02b(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo   CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(50),		 -- Ramo
			DECIMAL(16,2),   -- Pagado Bruto
			DECIMAL(16,2),   -- Pagado Neto
			DECIMAL(16,2),   -- Reserva Bruto
			DECIMAL(16,2),   -- Reserva Neto
			DECIMAL(16,2),   -- Incurrido Bruto
			DECIMAL(16,2),   -- Incurrido Neto
			CHAR(50),		 -- Compania
			INTEGER,		 -- Cantidad
			CHAR(255);		 -- Filtros

DEFINE v_filtros         CHAR(255);

DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_cantidad		 INTEGER;

DEFINE _cod_ramo         CHAR(3);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec02(
a_compania, 
a_agencia, 
a_periodo,
a_sucursal,
a_ajustador,
'*',
'*',
a_agente
) RETURNING v_filtros;  


SET ISOLATION TO DIRTY READ;
FOREACH 
 SELECT cod_ramo,		
        COUNT(*),
		SUM(pagado_bruto), 		
 		SUM(pagado_neto), 
	    SUM(reserva_bruto), 	
	    SUM(reserva_neto),		
	    SUM(incurrido_bruto),	
	    SUM(incurrido_neto)
   INTO	_cod_ramo,
        v_cantidad,			
		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto
   FROM tmp_sinis
  WHERE seleccionado = 1
  GROUP BY cod_ramo  
  ORDER BY cod_ramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	RETURN v_ramo_nombre,
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
