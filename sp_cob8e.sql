-- Cobros Totales por Ramo

-- Creado    : 14/02/2003 - Autor: Amado Perez
-- Modificado: 
--
-- SIS v.2.0 - d_cobr_sp_cob08e_dw5 - DEIVID, S.A.

--DROP PROCEDURE sp_cob08e;

CREATE PROCEDURE "informix".sp_cob08e(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255) DEFAULT '*',
a_cobrador CHAR(255) DEFAULT '*',
a_agente   CHAR(255) DEFAULT '*',
a_ramo     CHAR(255) DEFAULT '*',
a_formapago CHAR(255) DEFAULT '*'
) RETURNING INTEGER,   -- Cantidad	
			DEC(16,2), -- Prima Neto Pagada
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Compania
			CHAR(255), -- Filtros
			CHAR(50);  -- nombre_ramo

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE _nombre_agente      CHAR(50);
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
DEFINE v_nombre_ramo       CHAR(50);
DEFINE _cod_ramo           CHAR(3);
DEFINE v_agente_nombre     CHAR(50);     
DEFINE v_codigo       	   CHAR(10);
DEFINE v_saber		       CHAR(3);

--DEFINE _cod_agente         CHAR(5);
DEFINE _cod_cobrador       CHAR(3);

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

	LET v_filtros = TRIM(v_filtros) || " Corredor: ";-- ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
	      INTO v_agente_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.cod_agente = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_agente_nombre) || (v_saber);
    END FOREACH

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
 SELECT	cod_ramo,
		COUNT(*),
		SUM(prima_neta),    
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90)
   INTO	_cod_ramo,
		v_cantidad,
   		v_monto_pagado,    
		v_por_vencer,     
		v_exigible,        
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  WHERE seleccionado = 1
GROUP BY cod_ramo
ORDER BY cod_ramo
	
	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	RETURN 	v_cantidad,
			v_monto_pagado,    
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
		    v_compania_nombre,
		    v_filtros,
			v_nombre_ramo
			WITH RESUME;

END FOREACH		 
DROP TABLE tmp_moros;
END PROCEDURE;

