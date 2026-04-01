DROP procedure sp_pro09;
CREATE procedure "informix".sp_pro09(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codramo CHAR(255) DEFAULT "*",a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*",a_useradd CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(45),CHAR(3),CHAR(45),
                   DECIMAL(16,2),DECIMAL(9,2),DECIMAL(9,2),
                   DECIMAL(16,2),CHAR(255),CHAR(07),CHAR(07),
                   CHAR(50);

--------------------------------------------
---  TOTALES PRODUCCION REASEGURO DETALLE ---
---  Yinia M. Zamora - julio 2000 - YMZM
---  Ref. Power Builder - d_sp_pro09
--------------------------------------------

   BEGIN
      DEFINE s_nopoliza,s_contratante         CHAR(10);
      DEFINE s_cia,s_codsucursal,s_codramo,s_codasegur,
             s_tipopro,v_tipopro              CHAR(3);
      DEFINE s_codgrupo                       CHAR(5);
      DEFINE s_usuario                        CHAR(8);
      DEFINE v_descrea                        CHAR(45);
      DEFINE v_descramo                       CHAR(45);
      DEFINE porc_comis,porc_impuesto         DECIMAL(5,2);
      DEFINE periodo1,periodo2                CHAR(7);
      DEFINE v_prima_suscrita                 DECIMAL(16,2);
      DEFINE v_comision                       DECIMAL(9,2);
      DEFINE v_impuesto                       DECIMAL(9,2);
      DEFINE v_saldo                          DECIMAL(16,2);
      DEFINE v_filtros                        CHAR(255);
      DEFINE w_cuenta                         SMALLINT;
      DEFINE _tipo                            CHAR(01);
      DEFINE v_descr_cia                      CHAR(50);

         CREATE TEMP TABLE temp_endoso
               (no_poliza        CHAR(10),
                cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_ramo         CHAR(3),
                cod_contratante  CHAR(10),
                cod_coasegur     CHAR(3),
                usuario          CHAR(8),
                prima_suscrita   DEC(16,2),
                comision         DEC(9,2),
                impuesto         DEC(9,2),
                seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;

      CREATE INDEX iend1_temp_endoso ON temp_endoso(cod_grupo);
      CREATE INDEX iend2_temp_endoso ON temp_endoso(cod_ramo);
      CREATE INDEX iend3_temp_endoso ON temp_endoso(cod_coasegur);
      CREATE INDEX iend4_temp_endoso ON temp_endoso(cod_sucursal);

      LET v_descrea  = NULL;
      LET v_descramo = NULL;
      LET v_prima_suscrita = 0;
      LET v_impuesto = 0;
      LET v_comision = 0;
      LET v_saldo = 0;
      LET porc_comis = 0;
      LET porc_impuesto = 0;

      SET ISOLATION TO DIRTY READ;

      LET v_descr_cia = sp_sis01(a_compania);

      FOREACH
         SELECT endedmae.no_poliza,endedmae.cod_compania,endedmae.cod_sucursal,
                endedmae.prima_suscrita
                INTO s_nopoliza,s_cia,s_codsucursal,v_prima_suscrita
                FROM endedmae
               WHERE endedmae.actualizado = 1
                 AND endedmae.periodo BETWEEN a_periodo1 AND a_periodo2
                 AND endedmae.prima_suscrita <> 0

         SELECT emipomae.cod_sucursal,emipomae.cod_grupo,emipomae.cod_ramo,
                emipomae.cod_contratante,emipomae.cod_tipoprod,
                emipomae.user_added
                INTO s_codsucursal,s_codgrupo,s_codramo,s_contratante,
                     s_tipopro,s_usuario
                FROM emipomae
               WHERE emipomae.no_poliza = s_nopoliza;

         SELECT emiciara.cod_coasegur,emiciara.porc_comis_ra,
                emiciara.porc_impuesto
                INTO s_codasegur,porc_comis,porc_impuesto
                FROM emiciara
               WHERE emiciara.no_poliza = s_nopoliza;

         SELECT emitipro.cod_tipoprod
                INTO v_tipopro
                FROM emitipro
               WHERE emitipro.cod_tipoprod = s_tipopro
                 AND emitipro.tipo_produccion = 4;

          IF porc_comis IS NULL THEN
             LET porc_comis = 0;
          END IF;
          IF porc_impuesto IS NULL THEN
             LET porc_impuesto = 0;
          END IF;

          IF v_tipopro IS NOT NULL THEN
            LET v_comision = (v_prima_suscrita*porc_comis/100);
            LET v_impuesto = (v_prima_suscrita*porc_impuesto/100);

            INSERT INTO temp_endoso
                   VALUES(s_nopoliza,
                          s_codsucursal,
                          s_codgrupo,
                          s_codramo,
                          s_contratante,
                          s_codasegur,
                          s_usuario,
                          v_prima_suscrita,
                          v_comision,
                          v_impuesto,
                          1);

         END IF
      END FOREACH
           -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo: "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codcoasegur <> "*" THEN
        LET v_filtros = TRIM(v_filtros) ||"Coaseguradora "||TRIM(a_codcoasegur);
         LET _tipo = sp_sis04(a_codcoasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_useradd <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_useradd);
         LET _tipo = sp_sis04(a_useradd); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      FOREACH
         SELECT x.cod_ramo,SUM(x.prima_suscrita),SUM(x.comision),
                SUM(x.impuesto)
                INTO s_codramo,v_prima_suscrita,v_comision,
                     v_impuesto
                FROM temp_endoso x
               WHERE x.seleccionado = 1
               GROUP BY x.cod_ramo
               ORDER BY x.cod_ramo

         SELECT emicoase.nombre
                INTO v_descrea
                FROM emicoase
               WHERE emicoase.cod_coasegur = s_codasegur;

         SELECT prdramo.nombre
                INTO v_descramo
                FROM prdramo
               WHERE prdramo.cod_ramo = s_codramo;

         LET v_saldo = v_prima_suscrita - v_comision - v_impuesto;

         RETURN s_codasegur,v_descrea,s_codramo,v_descramo,
                v_prima_suscrita,v_comision,v_impuesto,
                v_saldo,v_filtros,a_periodo1,a_periodo2,
                v_descr_cia  WITH RESUME;

      END FOREACH

   DROP TABLE temp_endoso;
   END
END PROCEDURE;
