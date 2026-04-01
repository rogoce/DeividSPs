-- Cobros por Cobrador - Totales
-- 
-- Creado    : 11/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 24/04/2002 - Autor: Armando Moreno M. poner las cant. a las columnas de morosidad
-- SIS v.2.0 - d_cobr_sp_cob08b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_cob08b;

CREATE PROCEDURE "informix".sp_cob08b(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7),
a_periodo2  CHAR(7),
a_sucursal  CHAR(255) DEFAULT '*',
a_cobrador  CHAR(255) DEFAULT '*',
a_agente    CHAR(255) DEFAULT '*',
a_ramo	    CHAR(255) DEFAULT '*',
a_formapago CHAR(255) DEFAULT '*'
) RETURNING CHAR(50),  -- Nombre Cobrador
			INTEGER,   -- Cantidad	
			DEC(16,2), -- Prima Pagada
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Compania
			CHAR(255), -- Filtros
			SMALLINT,  -- cnt. por vencer
			SMALLINT,  -- cnt. exigible
			SMALLINT,  -- cnt. corriente
			SMALLINT,  -- cnt. 30
			SMALLINT,  -- cnt. 60
			SMALLINT;  -- cnt. 90

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cobrador   CHAR(50);
DEFINE v_cantidad		   INTEGER;
DEFINE v_monto_pagado      DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE _cnt_por_vencer	   SMALLINT;
DEFINE _cnt_exigible	   SMALLINT;
DEFINE _cnt_corriente	   SMALLINT;
DEFINE _cnt_monto_30	   SMALLINT;
DEFINE _cnt_monto_60	   SMALLINT;
DEFINE _cnt_monto_90	   SMALLINT;
DEFINE _cod_cobrador       CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;
--DROP TABLE tmp_pagos;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob08(
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
IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapag
		   NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapag IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
FOREACH
 SELECT	cod_cobrador,
		COUNT(*),
		SUM(monto_pagado),    
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90),
		SUM(cnt_por_vencer),
		SUM(cnt_exigible),
		SUM(cnt_corriente),
		SUM(cnt_monto_30),
		SUM(cnt_monto_60),
		SUM(cnt_monto_90)
   INTO	_cod_cobrador,
		v_cantidad,
   		v_monto_pagado,    
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		_cnt_por_vencer,
		_cnt_exigible,
		_cnt_corriente,
		_cnt_monto_30,
		_cnt_monto_60,
		_cnt_monto_90
   FROM	tmp_moros
  WHERE seleccionado = 1
  GROUP BY cod_cobrador
  ORDER BY cod_cobrador

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	 LET _cnt_exigible = _cnt_corriente + _cnt_monto_30 + _cnt_monto_60 + _cnt_monto_90; 

	RETURN 	v_nombre_cobrador,
			v_cantidad,
			v_monto_pagado,    
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
		    v_compania_nombre,
		    v_filtros,
			_cnt_por_vencer,
			_cnt_exigible,
			_cnt_corriente,
			_cnt_monto_30,
			_cnt_monto_60,
			_cnt_monto_90
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

