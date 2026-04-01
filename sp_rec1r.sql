-- Reporte de Incurrido Neto por Acreedor
-- 
-- Creado    : 11/06/2001 - Autor: Marquelda Vadelamar

--
-- SIS v.2.0 - d_sp_rec01a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec01r;

CREATE PROCEDURE "informix".sp_rec01r(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_acreedor  CHAR(255) DEFAULT "*",
a_ramo      CHAR(255) DEFAULT "*",
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
DEFINE v_acreedor_nombre CHAR(50);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo       CHAR(10);     
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);      
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7); 
DEFINE _tipo             CHAR(1);
DEFINE _cod_acreedor     CHAR(5);      
DEFINE _no_unidad         CHAR(5); 
     

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
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,
		cod_acreedor,		
		periodo,
		numrecla
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,	
        _cod_acreedor,		
  		_periodo,
		v_doc_reclamo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_acreedor, cod_ramo,numrecla


SELECT cod_reclamante,
  	   fecha_siniestro
  INTO _cod_cliente,		
       v_fecha_siniestro
  FROM recrcmae
 WHERE no_reclamo = _no_reclamo;

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

-- Selecciona el Primer Acreedor de la Poliza

	LET v_acreedor_nombre= '... SIN ACREEDOR ...';
	LET _cod_acreedor    = '';

	FOREACH
	 SELECT	cod_acreedor, no_unidad
	   INTO	_cod_acreedor, _no_unidad
	   FROM emipoacr
	  WHERE	no_poliza = _no_poliza
	  ORDER BY no_unidad

		IF _cod_acreedor IS NOT NULL THEN

			SELECT nombre
			  INTO v_acreedor_nombre
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			EXIT FOREACH;

		END IF

	END FOREACH

	IF _cod_acreedor IS NULL THEN
		LET _cod_acreedor = '';
	END	IF

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
 	   v_acreedor_nombre,
 	   v_compania_nombre,
 	   v_filtros
 	   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;
