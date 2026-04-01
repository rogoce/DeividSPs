-- Reporte de Incurrido Neto por Ramo
-- 
-- Creado    : 26/01/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec42a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec42a;

CREATE PROCEDURE "informix".sp_rec42a(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 
  		    CHAR(100), 
  		    CHAR(20),
  		    DATE,
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(255),
  		    CHAR(10),
  		    DECIMAL(16,2),
  		    DATE;

--  		    DECIMAL(16,2),
--  		    DECIMAL(16,2),
--  		    DECIMAL(16,2),

DEFINE v_doc_reclamo     CHAR(18);     
DEFINE v_transaccion     CHAR(18);     
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_total    DECIMAL(16,2);
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_fecha_trans     DATE;         

DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

DEFINE _no_reclamo       CHAR(10);     
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);      
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);      

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Cargar el Incurrido

--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec42(
a_compania, 
a_agencia, 
a_periodo1
); 

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT no_reclamo,
 		transaccion,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
		cod_ramo,		
		periodo,
		numrecla,
		pagado_total,
		fecha
   INTO	_no_reclamo, 		
 		v_transaccion,		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_pagado_total,
		v_fecha_trans
   FROM tmp_sinis 
  WHERE seleccionado = 1
--  ORDER BY cod_ramo, numrecla
  ORDER BY cod_ramo, periodo, numrecla, transaccion

	SELECT cod_reclamante,		fecha_siniestro
	  INTO _cod_cliente,		v_fecha_siniestro
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

	RETURN v_doc_reclamo,
	 	   v_cliente_nombre, 	
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros,
	 	   v_transaccion,
		   v_pagado_total,
		   v_fecha_trans
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
