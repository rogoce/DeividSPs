-- Reporte de Incurrido Neto por Ramo por Transaccion
-- 
-- Creado    : 09/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec04a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec43a;

CREATE PROCEDURE "informix".sp_rec43a(
a_compania 	CHAR(3), 
a_agencia 	CHAR(3), 
a_periodo1 	CHAR(7), 
a_periodo2	CHAR(7), 
a_sucursal	CHAR(255) DEFAULT "*", 
a_ramo 		CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 
			CHAR(100), 
			CHAR(20),
			DATE,
			DATE,
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(10),
			CHAR(255);		-- Filtros

DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_fecha           DATE;
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre,v_desc_suc,v_desc_ramo CHAR(50);
DEFINE v_transaccion,v_codigo     CHAR(10);
DEFINE v_saber             		  CHAR(2);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob43a.trc";

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_sinis;

-- Cargar el Incurrido

CALL sp_rec43(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2
); 

--trace on;

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: "; -- ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	FOREACH
		SELECT insagen.descripcion,tmp_codigos.codigo
		  INTO v_desc_suc,v_codigo
	      FROM insagen,tmp_codigos
	     WHERE insagen.codigo_compania = a_compania
		   AND insagen.codigo_agencia  = tmp_codigos.codigo	
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_suc) || (v_saber);
    END FOREACH
	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: "; --||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	FOREACH
		SELECT prdramo.nombre,tmp_codigos.codigo
	      INTO v_desc_ramo,v_codigo
	      FROM prdramo,tmp_codigos
	     WHERE prdramo.cod_ramo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || TRIM(v_saber);
    END FOREACH
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
		periodo,
		numrecla,
		fecha,
		transaccion
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
		v_fecha,
		v_transaccion
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY fecha,transaccion

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
		   v_fecha,
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_transaccion,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;

