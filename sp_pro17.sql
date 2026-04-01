--  Polizas Vigentes por Agente para Auto

--  Creado    : 08/2000    - Autor: Yinia M. Zamora 
--  Modificado:	22/08/2001 - Autor: Marquelda Valdelamar (inclusion del filtro de cliente)
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_pro17;
CREATE PROCEDURE sp_pro17(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_corredor char(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_periodo1 DATE, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*") 
     RETURNING CHAR(50),CHAR(50),CHAR(03),CHAR(50),CHAR(03),CHAR(50),
                   CHAR(45),CHAR(20),DATE,DATE,DATE,DECIMAL(16,2),DATE,
                   CHAR(255);



 BEGIN

    DEFINE v_nopoliza,v_contratante         CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente                      CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo                            CHAR(01);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);

    LET v_prima_suscrita = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_periodo1,a_codramo)
                  RETURNING v_filtros;

    -- Filtro de Sucursal
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
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
    -- Filtro de Subramo
      IF a_subramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
         LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_corredor <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_corredor);
         LET _tipo = sp_sis04(a_corredor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

    SET ISOLATION TO DIRTY READ;
    FOREACH

       SELECT y.no_poliza,y.no_documento,y.cod_ramo,y.cod_subramo,
              y.cod_contratante,y.fecha_suscripcion,y.vigencia_inic,
              y.vigencia_final,y.prima_suscrita,y.cod_agente
              INTO v_nopoliza,v_documento,v_codramo,v_codsubramo,
                   v_contratante,v_fecha_suscripc,v_vigencia_inic,
                   v_vigencia_final,v_prima_suscrita,v_codagente
              FROM temp_perfil y
             WHERE seleccionado = 1
           
       SELECT a.nombre
              INTO v_desc_agente
              FROM agtagent a
             WHERE a.cod_agente = v_codagente;

       SELECT b.nombre
              INTO v_desc_cliente
              FROM cliclien b
             WHERE b.cod_cliente = v_contratante;

       SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE prdramo.cod_ramo = v_codramo;

       SELECT nombre
              INTO v_desc_subr
              FROM prdsubra
             WHERE cod_ramo    = v_codramo
               AND cod_subramo = v_codsubramo;

         RETURN v_descr_cia,v_desc_agente,v_codramo,v_desc_ramo,
                v_codsubramo,v_desc_subr,v_desc_cliente,v_documento,
                v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,
                v_prima_suscrita,a_periodo1,v_filtros
                 WITH RESUME;

    LET v_prima_suscrita = 0;
      END FOREACH
    DROP TABLE temp_perfil;
   END
END PROCEDURE;
