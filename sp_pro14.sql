-- Polizas Vigentes por Grupo/Ramo     
-- 
-- Creado    : 08/08/2000 - Autor: Yinia M. Zamora
-- Modificado: 23/07/2001 - Autor: Marquelda Valdelamar (para incluir filtro de cliente)
--			   05/09/2001 - 							 filtro de poliza
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_pro14;
CREATE procedure "informix".sp_pro14(
a_cia 			CHAR(3),
a_agencia 		CHAR(3),
a_codsucursal 	CHAR(255) DEFAULT "*",
a_codgrupo 		CHAR(255) DEFAULT "*",
a_codramo 		CHAR(255) DEFAULT "*",
a_periodo 		DATE,
a_cod_cliente 	CHAR(255) DEFAULT "*",
a_no_documento  CHAR(255) DEFAULT "*",
a_agente 		CHAR(255) DEFAULT "*"
)
RETURNING CHAR(50),
		  CHAR(5),
		  CHAR(50),
		  CHAR(50),
		  CHAR(03),
          CHAR(50),
          CHAR(45),
          CHAR(20),
          DATE,
          DATE,
          DECIMAL(16,2),
          DATE,
          CHAR(100);

BEGIN
    DEFINE v_nopoliza,v_contratante,v_codigo CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsucursal,v_saber  CHAR(3);
    DEFINE v_vigencia_inic,v_vigencia_final DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente,v_codgrupo           CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_desc_agente,v_descr_cia,v_desc_grupo,
           v_desc_ramo CHAR(50);
    DEFINE v_filtros                        CHAR(100);
    DEFINE _tipo                            CHAR(1);

	SET ISOLATION TO DIRTY READ;

    LET v_prima_suscrita = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_descr_cia      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_filtros        = NULL;
    LET v_documento      = NULL;

    LET v_descr_cia = sp_sis01(a_cia);

    CREATE TEMP TABLE tmp_polizav
                (no_poliza        CHAR(10),
                 no_documento     CHAR(20),
                 cod_grupo        CHAR(05),
                 cod_ramo         CHAR(03),
                 cod_sucursal     CHAR(03),
                 cod_contratante  CHAR(10),
                 vigencia_inic    DATE,
                 vigencia_final    DATE,
                 prima_suscrita   DEC(16,2),
                 cod_agente       CHAR(05),
                 seleccionado     SMALLINT DEFAULT 1);

   CREATE INDEX i_poliza1 ON tmp_polizav(cod_grupo,cod_ramo);
   CREATE INDEX i_poliza2 ON tmp_polizav(cod_sucursal);
   CREATE INDEX i_poliza3 ON tmp_polizav(cod_grupo);

   LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_codramo);

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
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente "||TRIM(a_cod_cliente);
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

      IF a_agente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --||TRIM(a_agente);
         LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = "";
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = " Ex";
         END IF
		 FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
	          INTO v_desc_agente,v_codigo
	          FROM agtagent,tmp_codigos
	         WHERE agtagent.cod_agente = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
		 END FOREACH

         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
--         LET _tipo = sp_sis04(a_no_documento); -- Separa los valores del String

{         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE}
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
{         END IF
         DROP TABLE tmp_codigos;}
      END IF

    SET ISOLATION TO DIRTY READ; 

	FOREACH

       SELECT y.no_poliza,
       		  y.no_documento,
       		  y.cod_grupo,
       		  y.cod_ramo,
              y.cod_sucursal,
              y.cod_contratante,
              y.vigencia_inic,
              y.vigencia_final,
              y.prima_suscrita,
              y.cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codgrupo,
         	  v_codramo,
              v_codsucursal,
              v_contratante,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
	          v_codagente
         FROM temp_perfil y 
        WHERE y.seleccionado = 1
        ORDER BY y.cod_grupo,y.cod_ramo

          INSERT INTO tmp_polizav
                  VALUES(v_nopoliza,
                         v_documento,
                         v_codgrupo,
                         v_codramo,
                         v_codsucursal,
                         v_contratante,
                         v_vigencia_inic,
                         v_vigencia_final,
                         v_prima_suscrita,
                         v_codagente,
                         1);

    END FOREACH

    FOREACH
       SELECT y.no_poliza,
       		  y.no_documento,
       		  y.cod_grupo,
       		  y.cod_ramo,
              y.cod_contratante,
              y.vigencia_inic,
              y.vigencia_final,
              y.prima_suscrita,
              y.cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codgrupo,
         	  v_codramo,
              v_contratante,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
              v_codagente
         FROM tmp_polizav y
        WHERE seleccionado = 1
        ORDER BY y.cod_grupo,y.cod_ramo,y.vigencia_final

       SELECT a.nombre
	     INTO v_desc_agente
	     FROM agtagent a
	    WHERE a.cod_agente = v_codagente;

       SELECT b.nombre
         INTO v_desc_cliente
         FROM cliclien b
        WHERE b.cod_cliente = v_contratante;

       SELECT c.nombre
         INTO v_desc_ramo
         FROM prdramo c
        WHERE c.cod_ramo = v_codramo;

       SELECT d.nombre
         INTO v_desc_grupo
         FROM cligrupo d
        WHERE d.cod_grupo = v_codgrupo
          AND d.cod_compania = a_cia;

       RETURN v_descr_cia,v_codgrupo,v_desc_grupo,v_desc_agente,v_codramo,
              v_desc_ramo,v_desc_cliente,v_documento,v_vigencia_inic,
              v_vigencia_final,v_prima_suscrita,a_periodo,
              v_filtros WITH RESUME;

       LET v_prima_suscrita = 0;
    END FOREACH
  DROP TABLE tmp_polizav; 
  DROP TABLE temp_perfil;
END
END PROCEDURE;
