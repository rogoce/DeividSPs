-- Morosidad Total por Ramo
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/01/2002 -adicion de filtro Subramo - Autor: Amado Perez
-- Modificado: 21/01/2003 -adicion de filtro polizas vencidas - Autor: Armando Moreno
-- SIS v.2.0 - d_cobr_sp_cob05a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob142;

CREATE PROCEDURE "informix".sp_cob142(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255) DEFAULT '*',
a_coasegur   CHAR(255) DEFAULT '*',
a_ramo       CHAR(255) DEFAULT '*',
a_formapago  CHAR(255) DEFAULT '*',
a_acreedor   CHAR(255) DEFAULT '*',
a_agente     CHAR(255) DEFAULT '*',
a_cobrador   CHAR(255) DEFAULT '*',
a_incobrable INT       DEFAULT 1,
a_grupo      CHAR(255) DEFAULT '*',
a_gestion    CHAR(255) DEFAULT '*',
a_polizas_vencidas    CHAR(1) DEFAULT '0',
a_tipo_moros CHAR(1) DEFAULT '1'
) RETURNING CHAR(50),  -- Nombre Ramo
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
			CHAR(255); -- Filtros

DEFINE v_tipo_produccion,v_codigo   CHAR(10);
DEFINE v_nombre_ramo,v_desc   CHAR(50);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE _accionista         SMALLINT;	


DEFINE _cod_ramo,v_saber   CHAR(3); 

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03b.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 
let a_incobrable = 2;

CALL sp_cob143(
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

IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: ";-- ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago IN (SELECT codigo FROM tmp_codigos);

       LET v_saber = " Ex";
	END IF
	FOREACH
		SELECT cobforpa.nombre,tmp_codigos.codigo
          INTO v_desc,v_codigo
          FROM cobforpa,tmp_codigos
         WHERE cobforpa.cod_formapag = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc) || " " || TRIM(v_saber);
	 END FOREACH

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

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_incobrable <> 1 THEN

    LET v_filtros = TRIM(v_filtros) || " Incobrable: " ;-- ||  TRIM(a_incobrable);

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
 SELECT	cod_ramo,
		COUNT(*),
 		SUM(prima_orig),
		SUM(saldo),          
		SUM(por_vencer),
		SUM(exigible),
		SUM(corriente),
		SUM(monto_30),
		SUM(monto_60),
		SUM(monto_90)
   INTO	_cod_ramo,
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
  GROUP BY cod_ramo
  ORDER BY cod_ramo

 SELECT nombre
   INTO v_nombre_ramo
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;

	RETURN 	v_nombre_ramo,
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
			v_filtros        
			WITH RESUME;

END FOREACH
DROP TABLE tmp_moros;
END PROCEDURE;