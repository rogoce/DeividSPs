-- Morosidad por Agente - Totales
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob03b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_cob03b;

CREATE PROCEDURE "informix".sp_cob03b(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255),
a_coasegur   CHAR(255) DEFAULT '*',
a_ramo       CHAR(255) DEFAULT '*',
a_formapago	 CHAR(255) DEFAULT '*',
a_acreedor   CHAR(255) DEFAULT '*',
a_agente     CHAR(255) DEFAULT '*',
a_cobrador   CHAR(255) DEFAULT '*',
a_tipo_moros CHAR(255) DEFAULT '1',
a_incobrable INT       DEFAULT 1,
a_producto	 CHAR(255) DEFAULT '*',
a_gestion    CHAR(255) DEFAULT '*'
) RETURNING CHAR(50),  -- Nombre Agente
			INTEGER,   -- Cantidad de Polizas	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Compania
			CHAR(100), -- nota
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_codigo			   CHAR(10);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nota              CHAR(100);
DEFINE v_compania_nombre,v_nombre_prod   CHAR(50);
DEFINE v_desc              CHAR(50);
DEFINE v_saber             CHAR(3);

SET ISOLATION TO DIRTY READ;
--DEFINE v_codigo            CHAR(10);


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03b.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob03(
a_compania,
a_agencia,
a_periodo,
a_tipo_moros
);

-- Procesos para Filtros

LET v_filtros = "";
LET v_nota    = "";

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

	LET v_filtros = TRIM(v_filtros) || " Ramo : " ||  TRIM(a_ramo);

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
		   AND cod_formapago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago IN (SELECT codigo FROM tmp_codigos);

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

IF a_producto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Producto: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_producto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
		   LET v_nota = " Nota: Se considera un solo producto para la poliza." ;
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
		   LET v_nota = " Nota: Se considera un solo producto para la poliza.";
	END IF
		SELECT prdprod.nombre,tmp_codigos.codigo
          INTO v_nombre_prod,v_codigo
          FROM prdprod,tmp_codigos
         WHERE prdprod.cod_producto = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_prod) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF
IF a_incobrable <> 1 THEN

	IF a_incobrable = 2 THEN  -- Sin Incobrables

		LET v_filtros = TRIM(v_filtros) || " Sin Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

	ELSE		        -- Solo Incobrables

		LET v_filtros = TRIM(v_filtros) || " Solo Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

	END IF

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
 SELECT	nombre_agente,       
		COUNT(*),
 		SUM(prima_orig),    
		SUM(saldo),          
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90)
   INTO	v_nombre_agente,
		v_cantidad,
   		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  WHERE seleccionado = 1
  GROUP BY nombre_agente
  ORDER BY nombre_agente

	RETURN 	v_nombre_agente,
			v_cantidad,
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
		    v_compania_nombre,
			v_nota,
		    v_filtros
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

