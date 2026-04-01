-- Polizas a Renovar con Saldo por Cobrador - Detallado
-- 
-- Creado    : 12/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 30/04/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_cobr_sp_cob13a_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_cob13a;

CREATE PROCEDURE "informix".sp_cob13a(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    CHAR(7),
a_sucursal   CHAR(255),
a_cobrador 	 CHAR(255),
a_ramo       CHAR(255)  DEFAULT '*',
a_formapago	 CHAR(255)  DEFAULT '*',
a_agente     CHAR(255)
) RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			CHAR(50),  -- Nombre Agente
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania,
			CHAR(50),  -- Nombre de la Forma de Pago
			DEC(16,2), -- Letra mensual
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE _cod_formapago      CHAR(3);
DEFINE _nombre_formapag    CHAR(50);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_nombre_cobrador   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);
DEFINE _prima_bruta		   DEC(16,2);
DEFINE _no_pagos           SMALLINT;
DEFINE _letra_mensual	   DEC(16,2);
DEFINE _cod_cobrador       CHAR(3);
DEFINE _no_poliza          CHAR(10);

LET _letra_mensual = 0.00;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_renov;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob13(
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

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_renov
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

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_renov
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

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo : " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_renov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
		vigencia_inic,  
		vigencia_final, 
		prima_orig,    
		saldo,          
		nombre_agente,
		cod_cobrador,
		cod_formapago,
		prima_bruta,
		no_pagos,
		no_poliza
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_prima_bruta,    
		v_saldo,          
		v_nombre_agente,
		_cod_cobrador,
		_cod_formapago,
		_prima_bruta,
		_no_pagos,
		_no_poliza
   FROM	tmp_renov
  WHERE seleccionado = 1
  ORDER BY cod_cobrador, nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	SELECT nombre
	  INTO _nombre_formapag
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapago;

LET _letra_mensual = _prima_bruta / _no_pagos;

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_vigencia_inic,  
			v_vigencia_final, 
			v_prima_bruta,    
			v_saldo,          
			v_nombre_agente,
			v_nombre_cobrador,
		    v_compania_nombre,
			_nombre_formapag,
			_letra_mensual,
		    v_filtros
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_renov;

END PROCEDURE;

