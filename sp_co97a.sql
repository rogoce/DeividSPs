-- Polizas Vigentes sin Pagos por Cobrador - Detallado
-- 
-- Creado    : 01/11/2002 - Autor: Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob09a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_co97a;

CREATE PROCEDURE "informix".sp_co97a(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255)  DEFAULT '*',
a_cobrador   CHAR(255)  DEFAULT '*',
a_agente     CHAR(255)  DEFAULT '*',
a_acreedor	 CHAR(255)  DEFAULT '*',
a_formapago  CHAR(255)  DEFAULT '*',
a_cliente    CHAR(255)  DEFAULT '*',
a_coasegur   CHAR(255)  DEFAULT '*',
a_ramo       CHAR(255)  DEFAULT '*',
a_gestion	 CHAR(255)  DEFAULT '*'
) RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			CHAR(2),   -- Forma Pago
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DEC(16,2), -- Prima Original
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania
			CHAR(255), -- Filtros
			DEC(16,2), -- Prima Mensual
			SMALLINT,  -- No pagos
			DEC(16,2), -- Monto Pagado
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2); -- Dias 90

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE v_forma_pago        CHAR(2);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_prima_bruta       DEC(16,2);
DEFINE _prima_mensual      DEC(16,2);
DEFINE _monto_pagado       DEC(16,2);
DEFINE v_nombre_cobrador,v_desc   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);
DEFINE _no_poliza,v_codigo		   CHAR(10);
DEFINE _cod_sucursal       CHAR(3);
DEFINE _cod_acreedor       CHAR(5);
DEFINE _cod_formapag       CHAR(3);
DEFINE _nombre_acreedor    CHAR(50);
DEFINE _cod_cliente        CHAR(5);
DEFINE _cod_coasegur       CHAR(3);
DEFINE _cod_cobrador       CHAR(3);
DEFINE _cod_ramo           CHAR(3);
DEFINE _no_pagos		   SMALLINT;	
DEFINE v_saber             CHAR(3);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob97(
a_compania,
a_agencia,
a_periodo
);

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cobrador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_acreedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Acreedor: " ||  TRIM(a_acreedor);

	LET _tipo = sp_sis04(a_acreedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapag NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapag IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_coasegur <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_coasegur);

	LET _tipo = sp_sis04(a_coasegur);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_gestion <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Gestion:"; -- ||  TRIM(a_gestion);

	LET _tipo = sp_sis04(a_gestion);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion NOT IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT cobgemae.nombre,tmp_codigos.codigo
          INTO v_desc,v_codigo
          FROM cobgemae,tmp_codigos
         WHERE cobgemae.cod_gestion = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc) || " " || TRIM(v_saber);
	 END FOREACH
	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		prima_orig,    
		cod_cobrador,
		no_poliza,
		cod_sucursal,
		cod_acreedor,
		cod_formapag,
		cod_cliente,
		cod_coasegur,
		cod_ramo,
		prima_mensual,
		no_pagos,
		monto_pagado,
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90
   INTO	v_nombre_cliente,
		v_doc_poliza,     
		v_forma_pago,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_prima_bruta,    
		_cod_cobrador,
		_no_poliza,
		_cod_sucursal,
		_cod_acreedor,
		_cod_formapag,
		_cod_cliente,
		_cod_coasegur,
		_cod_ramo,
		_prima_mensual,
		_no_pagos,
		_monto_pagado,
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  WHERE seleccionado = 1
  ORDER BY cod_cobrador, nombre_cliente, doc_poliza

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_forma_pago,     
			v_vigencia_inic,  
			v_vigencia_final, 
			v_prima_bruta,    
			v_nombre_cobrador,
		    v_compania_nombre,
	        v_filtros,
			_prima_mensual,
			_no_pagos,
			_monto_pagado,
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90
			WITH RESUME;

END FOREACH

DROP TABLE tmp_moros;
END PROCEDURE;

