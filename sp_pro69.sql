DROP procedure sp_pro69;

CREATE procedure "informix".sp_pro69(
a_compania     CHAR(03),
a_agencia      CHAR(03),
a_periodo1     CHAR(07),
a_periodo2     CHAR(07),
a_codsucursal  CHAR(255) DEFAULT "*",
a_codgrupo     CHAR(255) DEFAULT "*",
a_codagente    CHAR(255) DEFAULT "*",
a_codusuario   CHAR(255) DEFAULT "*",
a_codramo      CHAR(255) DEFAULT "*",
a_cliente      CHAR(255) DEFAULT "*",
a_no_documento CHAR(255) DEFAULT "*"
) RETURNING    CHAR(255);

--------------------------------------------
---  DETALLE DE POLIZAS DECLARATIVAS    ----
---  Armando Moreno M.  - Julio 2001    ---- AMM
---  Ref. Power Builder - d_sp_pro34
--------------------------------------------

      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo CHAR(03);
      DEFINE v_saber						 CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo        CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante,v_codigo      CHAR(10);
      DEFINE v_prima_suscrita,v_prima_neta,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_nombre_cte                    CHAR(100);
      DEFINE v_desc_grupo                    CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_vigencia_inic                 DATE;
	  DEFINE v_vigencia_final                DATE;

      CREATE TEMP TABLE temp_det
               (cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_agente       CHAR(5),
                cod_usuario      CHAR(8),
                cod_ramo         CHAR(3),
                no_poliza        CHAR(10),
                no_endoso        CHAR(5),
                no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                suma_asegurada   DEC(16,2),
                prima            DEC(16,2),
				prima_neta       DEC(16,2),
				vigencia_inic    DATE,
				vigencia_final   DATE,
                seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;

      CREATE INDEX id1_temp_det ON temp_det(cod_sucursal);
      CREATE INDEX id2_temp_det ON temp_det(cod_grupo);
      CREATE INDEX id3_temp_det ON temp_det(cod_agente);
      CREATE INDEX id4_temp_det ON temp_det(cod_usuario);
      CREATE INDEX id5_temp_det ON temp_det(cod_ramo);

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cod_agente      = NULL;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);

	  SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT no_poliza,
         		no_endoso,
                no_factura,
                prima_suscrita,
                prima_neta,
                suma_asegurada
           INTO v_nopoliza,
                v_noendoso,
                v_nofactura,
                v_prima_suscrita,
                v_prima_neta,
                v_suma_asegurada
           FROM endedmae
          WHERE (periodo >= a_periodo1 AND 
                 periodo <= a_periodo2)
			AND  actualizado = 1
			AND  cod_compania = a_compania
				
		 SELECT cod_grupo,
		 		cod_ramo,
		 		user_added,
                no_documento,
                cod_contratante,
                sucursal_origen,
                vigencia_inic,
				vigencia_final
           INTO v_cod_grupo,
           		v_cod_ramo,
           		v_cod_usuario,
                v_nodocumento,
                v_cod_contratante,
                v_cod_sucursal,
                v_vigencia_inic,
				v_vigencia_final
           FROM emipomae
          WHERE no_poliza = v_nopoliza
            AND cod_compania = a_compania
            AND declarativa  = 1;

         IF v_cod_ramo IS NULL OR
            v_cod_ramo = " " THEN
            CONTINUE FOREACH;
         END IF;

         FOREACH
            SELECT cod_agente
              INTO v_cod_agente
              FROM emipoagt
             WHERE no_poliza = v_nopoliza

            EXIT FOREACH;
         END FOREACH;

           INSERT INTO temp_det
                  VALUES(v_cod_sucursal,
                         v_cod_grupo,
                         v_cod_agente,
                         v_cod_usuario,
                         v_cod_ramo,
                         v_nopoliza,
                         v_noendoso,
                         v_nofactura,
                         v_nodocumento,
                         v_cod_contratante,
                         v_suma_asegurada,
                         v_prima_suscrita,
						 v_prima_neta,
						 v_vigencia_inic,
						 v_vigencia_final,
                         1);

	  LET v_suma_asegurada  = 0;

      END FOREACH
           -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codsucursal <> "*" THEN			
         LET v_filtros = TRIM(v_filtros) ||" Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Inluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	IF a_cliente <> "*" THEN
		LET v_filtros = TRIM(v_filtros) || " Asegurado: "; --||  TRIM(a_asegurado);

		LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE temp_det
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
		ELSE		        -- Excluir estos Registros
			UPDATE temp_det
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
		END IF

		SELECT cliclien.nombre,tmp_codigos.codigo
          INTO v_nombre_cte,v_codigo
          FROM cliclien,tmp_codigos
         WHERE cliclien.cod_cliente = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_cte) || TRIM(v_saber);
         DROP TABLE tmp_codigos;
	END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||" Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codagente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||" Agente "||TRIM(a_codagente);
         LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codusuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||" Usuario "||TRIM(a_codusuario);
         LET _tipo = sp_sis04(a_codusuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registro

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||" Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
	  END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND trim(no_documento) <> trim(a_no_documento);
      END IF
       
      RETURN v_filtros;
END PROCEDURE;
