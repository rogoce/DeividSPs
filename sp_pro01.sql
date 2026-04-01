-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   05/09/2001                         inclusion de filtro de poliza

--------------------------------------------
---  TOTALES PRODUCCION REASEGURO DETALLE 
---  Yinia M. Zamora - julio 2000 - YMZM
---  Ref. Power Builder - d_sp_pro01
--------------------------------------------

DROP procedure sp_pro01;
CREATE procedure "informix".sp_pro01(a_compania CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(07),a_periodo2 CHAR(7),a_codramo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*",a_useradd CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
         RETURNING CHAR(35),CHAR(35),CHAR(45),CHAR(20),CHAR(10),
                   DECIMAL(16,2),DECIMAL(9,2),DECIMAL(9,2),
                   DECIMAL(16,2),CHAR(07),CHAR(07),CHAR(255),
                   CHAR(50);

BEGIN

      DEFINE s_nopoliza,s_contratante,v_factura           CHAR(10);
      DEFINE s_cia,s_codsucursal,s_codramo,s_codasegur,
             s_tipopro                                    CHAR(3);
      DEFINE s_codgrupo,s_codagente                       CHAR(5);
      DEFINE v_documento                      CHAR(20);
      DEFINE s_user                           CHAR(8);
      DEFINE v_descrea                        CHAR(35);
      DEFINE v_descr_cia                      CHAR(50);
      DEFINE v_descramo                       CHAR(35);
      DEFINE v_descclte                       CHAR(45);
      DEFINE porc_comis,porc_impuesto         DECIMAL(5,2);
      DEFINE periodo1,periodo2                CHAR(7);
      DEFINE v_prima_suscrita                 DECIMAL(16,2);
      DEFINE v_comision                       DECIMAL(9,2);
      DEFINE v_impuesto                       DECIMAL(9,2);
      DEFINE v_saldo                          DECIMAL(16,2);
      DEFINE w_cuenta,v_seleccionado          SMALLINT;
      DEFINE v_filtros                        CHAR(255);
      DEFINE _tipo,_tipo_produccion           CHAR(1);

        LET v_descr_cia = sp_sis01(a_compania);
         CREATE TEMP TABLE temp_endoso
               (no_poliza        CHAR(10),
                cod_compania     CHAR(3),
                cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_ramo         CHAR(3),
                cod_contratante  CHAR(10),
                cod_coasegur     CHAR(3),
				tipo_produccion  CHAR(01),
                no_documento     CHAR(20),
                no_factura       CHAR(10),
                prima_suscrita   DEC(16,2),
                comision         DEC(9,2),
                impuesto         DEC(9,2),
                seleccionado     SMALLINT DEFAULT 1 NOT NULL) WITH NO LOG;

      CREATE INDEX iend1_temp_endoso ON temp_endoso(cod_grupo);
      CREATE INDEX iend2_temp_endoso ON temp_endoso(cod_ramo);
      CREATE INDEX iend3_temp_endoso ON temp_endoso(cod_coasegur);
      CREATE INDEX iend4_temp_endoso ON temp_endoso(cod_sucursal);
	  CREATE INDEX iend5_temp_endoso ON temp_endoso(tipo_produccion);
      CREATE INDEX iend6_temp_endoso ON temp_endoso(cod_coasegur,cod_ramo);
	  CREATE INDEX iend7_temp_endoso ON temp_endoso(cod_contratante);

      LET v_descrea    		= NULL;
      LET v_descramo  		= NULL;
      LET v_descclte  		= NULL;
      LET v_documento 		= NULL;
      LET v_factura   		= NULL;
      LET v_prima_suscrita  = 0;
      LET v_impuesto 		= 0;
      LET v_comision 		= 0;
      LET v_saldo 			= 0;
      LET v_seleccionado 	= 1;
      LET porc_comis 		= 0;
      LET porc_impuesto 	= 0;

      SET ISOLATION TO DIRTY READ;
      FOREACH

         SELECT no_poliza,
         		cod_compania,
         		cod_sucursal,
                prima_suscrita,
                no_factura
           INTO s_nopoliza,
           		s_cia,
           		s_codsucursal,
           		v_prima_suscrita,
                v_factura
           FROM endedmae
          WHERE actualizado = 1
            AND periodo BETWEEN a_periodo1 AND a_periodo2
            AND prima_suscrita <> 0

         SELECT cod_sucursal,
         		cod_grupo,
         		cod_ramo,
                cod_contratante,
                no_documento,
                cod_tipoprod
           INTO s_codsucursal,
           		s_codgrupo,
           		s_codramo,
           		s_contratante,
                v_documento,
                s_tipopro
           FROM emipomae
          WHERE no_poliza = s_nopoliza;

		  SELECT tipo_produccion
            INTO _tipo_produccion
            FROM emitipro
           WHERE cod_tipoprod = s_tipopro;

         IF _tipo_produccion <> 4 THEN
		    CONTINUE FOREACH;
		 END IF
		  
         SELECT cod_coasegur,
         		porc_comis_ra,
                porc_impuesto
           INTO s_codasegur,
           		porc_comis,
           		porc_impuesto
           FROM emiciara
          WHERE no_poliza = s_nopoliza;

      {   IF s_codasegur IS NULL THEN
            CONTINUE FOREACH;
         END IF;} 

       
          IF porc_comis IS NULL THEN
             LET porc_comis = 0;
          END IF;
          IF porc_impuesto IS NULL THEN
             LET porc_impuesto = 0;
          END IF;

        IF s_tipopro IS NOT NULL THEN
            LET v_comision = (v_prima_suscrita*porc_comis/100);
            LET v_impuesto = (v_prima_suscrita*porc_impuesto/100);

            INSERT INTO temp_endoso
                   VALUES(s_nopoliza,
                          s_cia,
                          s_codsucursal,
                          s_codgrupo,
                          s_codramo,
                          s_contratante,
                          s_codasegur,
						  _tipo_produccion,
                          v_documento,
                          v_factura,
                          v_prima_suscrita,
                          v_comision,
                          v_impuesto,
                          v_seleccionado);

         END IF
      END FOREACH

      -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo"||TRIM(a_codramo);
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
         LET v_filtros = TRIM(v_filtros) ||"Grupo"||TRIM(a_codgrupo);
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
         LET v_filtros = TRIM(v_filtros) ||"Reasegurador: "||TRIM(a_codcoasegur);
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

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Clientes: "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
--         LET _tipo = sp_sis04(a_no_documento); -- Separa los valores del String

{         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE}
            UPDATE temp_endoso
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
{         END IF
         DROP TABLE tmp_codigos;}
      END IF

      FOREACH
         SELECT no_poliza,
         		cod_grupo,
         		cod_ramo,
         		cod_contratante,
                cod_coasegur,
                no_documento,
                no_factura,
                prima_suscrita,
                comision,
                impuesto
           INTO s_nopoliza,
           		s_codgrupo,
           		s_codramo,
           		s_contratante,
                s_codasegur,
                v_documento,
                v_factura,
                v_prima_suscrita,
                v_comision,
                v_impuesto
                FROM temp_endoso
               WHERE seleccionado = 1
               ORDER BY cod_coasegur,cod_ramo

         SELECT nombre
           INTO v_descrea
           FROM emicoase
          WHERE cod_coasegur = s_codasegur;

         SELECT prdramo.nombre
           INTO v_descramo
           FROM prdramo
          WHERE cod_ramo = s_codramo;

         SELECT nombre
           INTO v_descclte
           FROM cliclien
          WHERE cod_cliente = s_contratante;

         LET v_saldo = v_prima_suscrita - v_comision - v_impuesto;

         RETURN v_descrea,v_descramo,v_descclte,v_documento,
                v_factura,v_prima_suscrita,v_comision,
                v_impuesto,v_saldo,a_periodo1,a_periodo2,v_filtros,
                v_descr_cia
                WITH RESUME;
      END FOREACH

DROP TABLE temp_endoso;
END
END PROCEDURE;
