-- Reporte de Incurrido Neto Total por Acreedor

-- Creado    : 11/06/2001 - Autor: Marquelda Valdelamar 
--
-- SIS v.2.0 - d_sp_rec01j_dw10 - DEIVID, S.A.

DROP PROCEDURE sp_rec01j;

CREATE PROCEDURE "informix".sp_rec01j(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_acreedor  CHAR(255) DEFAULT "*",
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
DEFINE v_acreedor_nombre CHAR(50);     
DEFINE v_cantidad        INTEGER;
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);
DEFINE _cod_acreedor     CHAR(5);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Cargar el Incurrido

--DROP TABLE tmp_sinis;

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
'*'
); 

--LET v_filtros = "";
IF a_acreedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Acreedor: " ||  TRIM(a_acreedor);

	LET _tipo = sp_sis04(a_acreedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT cod_acreedor,		
 		SUM(pagado_bruto), 		
 		SUM(pagado_neto), 
	    SUM(reserva_bruto), 	
	    SUM(reserva_neto),		
	    SUM(incurrido_bruto),	
	    SUM(incurrido_neto),
		COUNT(*)
   INTO	_cod_acreedor,
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		v_cantidad
   FROM tmp_sinis 
  WHERE seleccionado = 1
  GROUP BY cod_acreedor
  ORDER BY cod_acreedor

	SELECT nombre
	  INTO v_acreedor_nombre
	  FROM emiacre
	 WHERE cod_acreedor = _cod_acreedor;


RETURN v_acreedor_nombre,
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
