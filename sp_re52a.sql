-- Siniestralidad por Grupo - Detalle Ramo - Poliza
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 12/07/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - d_recl_sp_rec52a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec52a;
CREATE PROCEDURE "informix".sp_rec52a(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255) DEFAULT '*',
a_grupo    CHAR(255) DEFAULT '*',
a_ramo     CHAR(255) DEFAULT '*',
a_cliente  CHAR(255) DEFAULT '*',
a_producto CHAR(255) DEFAULT '*',
a_agente   CHAR(255) DEFAULT '*'
, a_poliza char(20) default '*'
) RETURNING CHAR(20),		-- Poliza
			CHAR(100),		-- Asegurado	
			DECIMAL(16,2), 	-- Prima Suscrita
			DECIMAL(16,2), 	-- Incurrido Bruto
			DECIMAL(16,2), 	-- % Siniestralidad 
			DECIMAL(16,2), 	-- Prima Pagada
			DECIMAL(16,2), 	-- Sinestros Pagados
			DECIMAL(16,2), 	-- % Pagado/Cobrado
			CHAR(50),	   	-- Ramo
			CHAR(50),	   	-- Grupo
			CHAR(50),	    -- Compania
			DATE,			-- Vigencia Inicial
			DATE,			-- Vigencia Final
			CHAR(50),	    -- Producto
			CHAR(255);	    -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);
DEFINE v_saber			  CHAR(2);
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_asegurado        CHAR(100);     
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_ramo_nombre,v_nombre_prod,v_nombre_agt CHAR(50);     
DEFINE v_grupo_nombre,v_desc_grupo,v_desc_ramo  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     
DEFINE v_vigencia_inic    DATE;
DEFINE v_vigencia_final   DATE;

DEFINE _no_poliza,v_codigo		  CHAR(10);	
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_grupo,_cod_producto   CHAR(5);      
DEFINE _cod_cliente		  CHAR(10);	

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Siniestralidad

--DROP TABLE tmp_siniest;

CALL sp_rec52(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		SELECT cligrupo.nombre,tmp_codigos.codigo
          INTO v_desc_grupo,v_codigo
          FROM cligrupo,tmp_codigos
         WHERE cligrupo.cod_grupo = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: "; --||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		SELECT prdramo.nombre,tmp_codigos.codigo
          INTO v_desc_ramo,v_codigo
          FROM prdramo,tmp_codigos
         WHERE prdramo.cod_ramo = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_nombre_agt,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_agt) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_producto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Producto: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_producto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		SELECT prdprod.nombre,tmp_codigos.codigo
          INTO v_nombre_prod,v_codigo
          FROM prdprod,tmp_codigos
         WHERE prdprod.cod_producto = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_prod) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_poliza <> "*" THEN
	LET v_filtros = TRIM(v_filtros)|| " Poliza: "|| TRIM(a_poliza);
	UPDATE tmp_siniest
	   SET seleccionado = 0
	 WHERE seleccionado = 1
	   AND doc_poliza NOT IN (a_poliza);       
END IF

-- Seleccion de Registros
FOREACH
 SELECT no_poliza,
		doc_poliza,
 		cod_ramo,
        cod_grupo, 
        prima_suscrita,   
		incurrido_bruto,  
		siniestro_pagado, 
		prima_pagada,
		cod_cliente,
		cod_producto
   INTO	_no_poliza,
		v_doc_poliza,
   		_cod_ramo,
        _cod_grupo, 
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_siniestro_pagado, 
		v_prima_pagada,     
		_cod_cliente,
		_cod_producto     
   FROM	tmp_siniest
  WHERE seleccionado = 1
  ORDER BY cod_producto, doc_poliza

	SELECT vigencia_inic,
		   vigencia_final	
	  INTO v_vigencia_inic,
		   v_vigencia_final	
	  FROM emipomae 
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_nombre_prod
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;
	
	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_grupo_nombre
	  FROM cligrupo
	 WHERE cod_grupo = _cod_grupo;

	-- Porcentaje de Siniestralidad

	IF v_prima_suscrita = 0 THEN
		IF v_incurrido_bruto = 0 THEN
			LET v_porc_siniest = 0;
		ELSE
			LET v_porc_siniest = 100;
		END IF
	ELSE
	    IF v_incurrido_bruto < 0 THEN
			LET v_porc_siniest = 0;
		ELSE
	   		LET	v_porc_siniest = (v_incurrido_bruto / v_prima_suscrita)*100;
		END IF
	END IF

	-- Porcentaje de Pagado

	IF v_prima_pagada = 0 THEN
		IF v_siniestro_pagado = 0 THEN
			LET v_porc_pagado = 0;
		ELSE
			LET v_porc_pagado = 100;
		END IF
	ELSE
	    IF v_siniestro_pagado < 0 THEN
			LET v_porc_pagado = 0;
		ELSE
		 	LET	v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
		END IF
	END IF

	RETURN v_doc_poliza,
		   v_asegurado,
		   v_prima_suscrita,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_ramo_nombre,
		   v_grupo_nombre,
	       v_compania_nombre,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_nombre_prod,
		   v_filtros
		   WITH RESUME;

END FOREACH

END PROCEDURE;
