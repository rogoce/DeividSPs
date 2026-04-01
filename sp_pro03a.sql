   DROP procedure sp_pro03;
   CREATE procedure "informix".sp_pro03(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),INT,DECIMAL(16,2),DECIMAL(16,2),DATE,
             CHAR(3),CHAR(50),CHAR(255);

--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - dw_pro03
--------------------------------------------

 BEGIN

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE unidades2          SMALLINT;
    DEFINE no_poliza          CHAR(10);
    DEFINE v_cant_polizas          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           w_prima_suscrita,w_prima_retenida   DECIMAL(16,2);
    DEFINE v_filtros          CHAR(255);
    DEFINE _tipo              CHAR(01);


 --  SET DEBUG FILE TO "sp_pro01z.sql";
 --  TRACE ON;
       CREATE TEMP TABLE temp_perfil
             (cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cod_sucursal   CHAR(3),
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              cant_polizas     SMALLINT,
              seleccionado     SMALLINT DEFAULT 1,
              PRIMARY KEY(cod_ramo,cod_subramo,cod_sucursal)) WITH NO LOG;

       CREATE INDEX i_perfil1 ON temp_perfil(cod_ramo);
       CREATE INDEX i_perfil2 ON temp_perfil(cod_subramo);
       CREATE INDEX i_perfil3 ON temp_perfil(cod_sucursal);

    LET v_cod_ramo  = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_desc_subramo = NULL;
    LET v_cant_polizas = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET w_prima_suscrita = 0;
    LET w_prima_retenida = 0;
    LET v_filtros = NULL;
    LET _tipo     = NULL;


    SET ISOLATION TO DIRTY READ;
    FOREACH

       SELECT   emipomae.no_poliza,emipomae.cod_sucursal,emipomae.cod_ramo,
                emipomae.cod_subramo,emipomae.prima_suscrita,
                emipomae.prima_retenida
                INTO no_poliza,v_cod_sucursal,v_cod_ramo,v_cod_subramo,
                     w_prima_suscrita,w_prima_retenida
                FROM emipomae
               WHERE emipomae.vigencia_final >= a_periodo
                 AND (emipomae.fecha_cancelacion IS NULL
                 OR  emipomae.fecha_cancelacion > a_periodo)

         BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil
                    SET prima_suscrita = prima_suscrita + w_prima_suscrita,
                        prima_retenida = prima_retenida + w_prima_retenida,
                        cant_polizas   = cant_polizas + 1
                  WHERE cod_ramo = v_cod_ramo
                    AND cod_subramo = v_cod_subramo
                    AND cod_sucursal = v_cod_sucursal;

          END EXCEPTION
          INSERT INTO temp_perfil
              VALUES(v_cod_ramo,
                     v_cod_subramo,
                     v_cod_sucursal,
                     w_prima_suscrita,
                     w_prima_retenida,
                     1,
                     1);
    END
    END FOREACH

       -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agencia "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

   -- Filtro para Ramos
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--  Seleccion Final

    FOREACH
       SELECT x.cod_ramo,x.cod_subramo,cant_polizas,x.prima_suscrita,
              x.prima_retenida
              INTO v_cod_ramo,v_cod_subramo,v_cant_polizas,
                   v_prima_suscrita,v_prima_retenida
              FROM temp_perfil x
             WHERE x.seleccionado = 1
             ORDER BY x.cod_ramo,x.cod_subramo

       SELECT a.nombre
              INTO v_desc_ramo
              FROM prdramo a
             WHERE a.cod_ramo  = v_cod_ramo;

       SELECT prdsubra.nombre
              INTO v_desc_subramo
              FROM prdsubra
             WHERE prdsubra.cod_ramo    = v_cod_ramo
               AND prdsubra.cod_subramo = v_cod_subramo;

       RETURN  v_cod_subramo,v_desc_subramo,v_cant_polizas,
               v_prima_suscrita,v_prima_retenida,a_periodo,
               v_cod_ramo,v_desc_ramo,v_filtros WITH RESUME;

      END FOREACH

DROP TABLE temp_perfil;
   END
END PROCEDURE;
