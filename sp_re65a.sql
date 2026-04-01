DROP PROCEDURE sp_re65a;

CREATE PROCEDURE "informix".sp_re65a(
		a_compania      CHAR(3),
		a_agencia  		CHAR(3),
		a_fecha_desde 	DATE,
		a_fecha_hasta 	DATE,
		a_opcion 		CHAR(1) DEFAULT   "*",
		a_sucursal  	CHAR(255) DEFAULT "*",
		a_grupo    		CHAR(255) DEFAULT "*",
		a_reaseguro 	CHAR(255) DEFAULT "*",
		a_agente		CHAR(255) DEFAULT "*",
		a_cod_cliente   CHAR(255) DEFAULT "*",
		a_cod_subramo	CHAR(255) DEFAULT "*",
		a_no_documento	CHAR(255) DEFAULT "*"
        ) RETURNING CHAR(255);

DEFINE _sucursal_origen  CHAR(3);
DEFINE _cod_grupo  		 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_subramo,v_cod_ramo    	 CHAR(3);
DEFINE _no_documento     CHAR(20);
DEFINE _cod_contratante  CHAR(10);
DEFINE _no_poliza		 CHAR(10);
DEFINE v_desc_agente     CHAR(50);
DEFINE v_desc_subramo    CHAR(50);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo		     CHAR(1);
DEFINE v_saber 			 CHAR(3);
DEFINE v_codigo			 CHAR(5);


-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod(
		sucursal_origen CHAR(3)   NOT NULL,
		cod_subramo     CHAR(3)   NOT NULL,
		no_poliza	   	CHAR(10)  NOT NULL,
		cod_grupo	   	CHAR(5)   NOT NULL,
		cod_agente     	CHAR(5)   NOT NULL,
		cod_contratante CHAR(10)  NOT NULL,
		no_documento    CHAR(20)  NOT NULL,
		tipo_produccion CHAR(1),
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;


CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(sucursal_origen);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(cod_subramo);

SET ISOLATION TO DIRTY READ;

SELECT cod_ramo
  INTO v_cod_ramo
  FROM prdramo
 WHERE ramo_sis = 1;

-- Carga las Polizas

IF a_opcion = '*' THEN
  FOREACH	
	SELECT no_poliza,
		   sucursal_origen,
		   cod_grupo,
		   cod_tipoprod,
		   cod_subramo,
		   no_documento,
		   cod_contratante
	  INTO _no_poliza,
	  	   _sucursal_origen,
	  	   _cod_grupo,
	  	   _cod_tipoprod,
	  	   _cod_subramo,
		   _no_documento,
		   _cod_contratante
	  FROM emipomae
	 WHERE cod_compania   = a_compania
	   AND cod_ramo       = v_cod_ramo
	   AND actualizado    = 1

	   SELECT tipo_produccion
	     INTO _tipo_produccion
	     FROM emitipro
	    WHERE cod_tipoprod = _cod_tipoprod;

	   FOREACH WITH HOLD
		    SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			 EXIT FOREACH;
	   END FOREACH

	   -- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		sucursal_origen,
	 	cod_subramo,
		no_poliza,
		cod_grupo,
		cod_agente,
	 	cod_contratante,
		no_documento,
		tipo_produccion,
		seleccionado	
		)
		VALUES(
		_sucursal_origen,
		_cod_subramo,
		_no_poliza,
		_cod_grupo,
		_cod_agente,
		_cod_contratante,
		_no_documento,
		_tipo_produccion,
		1
		);
  END FOREACH
ELSE
  FOREACH	
	SELECT no_poliza,
		   sucursal_origen,
		   cod_grupo,
		   cod_tipoprod,
		   cod_subramo,
		   no_documento,
		   cod_contratante
	  INTO _no_poliza,
	  	   _sucursal_origen,
	  	   _cod_grupo,
	  	   _cod_tipoprod,
	  	   _cod_subramo,
		   _no_documento,
		   _cod_contratante
	  FROM emipomae
	 WHERE cod_compania   = a_compania
	   AND cod_ramo       = v_cod_ramo
	   AND actualizado    = 1
	   AND nueva_renov    = a_opcion

	   SELECT tipo_produccion
	     INTO _tipo_produccion
	     FROM emitipro
	    WHERE cod_tipoprod = _cod_tipoprod;

	   FOREACH WITH HOLD
		    SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			 EXIT FOREACH;
	   END FOREACH

		INSERT INTO tmp_prod(
		sucursal_origen,
	 	cod_subramo,
		no_poliza,
		cod_grupo,
		cod_agente,
	 	cod_contratante,
		no_documento,
		tipo_produccion,
		seleccionado	
		)
		VALUES(
		_sucursal_origen,
		_cod_subramo,
		_no_poliza,
		_cod_grupo,
		_cod_agente,
		_cod_contratante,
		_no_documento,
		_tipo_produccion,
		1
		);
  END FOREACH
END IF

-- Procesos para Filtros

LET v_filtros = "";

IF a_opcion = "N" THEN 
   	LET v_filtros = " Polizas Nuevas.;";
ELIF a_opcion = "R" THEN 
   	LET v_filtros = " Polizas Renovadas.;";
ELSE --TODO
   	LET v_filtros = " Todas las polizas;";
END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa lls Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND sucursal_origen NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND sucursal_origen IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_reaseguro <> "*" THEN

	LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

        LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excllir estos Registros

        LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cod_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cliente: " ||  TRIM(a_cod_cliente);

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--Filtro de Poliza
IF a_no_documento <> "*" AND a_no_documento <> "" THEN
 LET v_filtros = TRIM(v_filtros) ||"Poliza: "||TRIM(a_no_documento);
    UPDATE tmp_prod
       SET seleccionado = 0
     WHERE seleccionado = 1
       AND no_documento <> a_no_documento;
END IF

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; -- ||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_desc_agente,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || " " || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_cod_subramo <> "*" THEN

	LET _tipo = sp_sis04(a_cod_subramo);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Subramo: "; -- ||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT prdsubra.nombre,tmp_codigos.codigo
          INTO v_desc_subramo,v_codigo
          FROM prdsubra,tmp_codigos
         WHERE prdsubra.cod_ramo    = v_cod_ramo
		   AND prdsubra.cod_subramo = codigo

         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_subramo) || " " || TRIM(v_saber);

	 END FOREACH

	DROP TABLE tmp_codigos;

END IF

RETURN v_filtros;

END PROCEDURE;
