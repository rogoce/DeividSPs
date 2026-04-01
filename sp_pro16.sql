-- Borderau de Reaseguro Facultativo Asumido
--                               ---
-- Creado : 08/2000  -  Autor: Yinia M. Zamora 
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_pro16;
CREATE PROCEDURE "informix".sp_pro16(a_compania CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_coasegur CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
         RETURNING CHAR(3),CHAR(3),CHAR(10),DATE,CHAR(20),CHAR(10),
                   DECIMAL(16,2),DECIMAL(9,2),DECIMAL(9,2),DECIMAL(16,2),
                   CHAR(50),CHAR(50),CHAR(50),CHAR(7),CHAR(7),CHAR(100),
                   CHAR(50);

   BEGIN

      DEFINE v_nopoliza,v_contratante,v_nofactura    CHAR(10);
      DEFINE v_noendoso,v_nounidad                   CHAR(5);
      DEFINE v_fecha_emision                         DATE;
      DEFINE v_nodocumento                           CHAR(20);
      DEFINE v_coaseguradora                         CHAR(3);
      DEFINE v_codramo                               CHAR(3);
      DEFINE w_porc_comis,w_porc_impuesto            DECIMAL(9,6);
      DEFINE w_prima,v_prima_bruta,v_prima_neta,v_prima_neta1   DECIMAL(16,2);
      DEFINE v_comision                              DECIMAL(9,2);
      DEFINE v_impuesto                              DECIMAL(9,2);
      DEFINE v_descramo,v_descclte,v_desccoa,v_descr_cia  CHAR(50);
      DEFINE v_filtros                        CHAR(100);
      DEFINE v_seleccionado                   SMALLINT;
      DEFINE _tipo                            CHAR(01);
      DEFINE v_cod_tipoprod                   CHAR(03);

         CREATE TEMP TABLE temp_asegfacul
               (no_poliza        CHAR(10),
                cod_coasegur     CHAR(3),
                cod_ramo         CHAR(3),
                no_factura       CHAR(10),
                fecha_emision    DATE,
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                prima_neta       DEC(16,2),
                comision         DEC(10,2),
                impuesto         DEC(10,2),
                seleccionado     SMALLINT DEFAULT 1,
                PRIMARY KEY(cod_coasegur,cod_ramo,no_factura))WITH NO LOG;

      CREATE INDEX i1_temp_asegfacul ON temp_asegfacul(cod_coasegur,cod_ramo);
      CREATE INDEX i2_temp_asegfacul ON temp_asegfacul(cod_ramo);
      CREATE INDEX i3_temp_asegfacul ON temp_asegfacul(cod_coasegur);

      LET v_desccoa        = NULL;
      LET v_descramo       = NULL;
      LET v_descclte       = NULL;
      LET v_nopoliza       = NULL;
      LET v_codramo        = NULL;
      LET v_coaseguradora  = NULL;
      LET v_contratante    = NULL;
      LET v_nofactura      = NULL;
      LET v_nopoliza       = NULL;
      LET v_noendoso       = NULL;
      LET v_fecha_emision  = NULL;
      LET v_cod_tipoprod   = NULL;
      LET v_nodocumento    = NULL;
      LET v_prima_neta     = 0;
	  LET v_prima_neta1    = 0;
	  LET v_seleccionado   = 0;
      LET v_impuesto 	   = 0;
      LET v_comision 	   = 0;
      LET w_porc_comis     = 0;
      LET w_porc_impuesto  = 0;

      LET v_descr_cia = sp_sis01(a_compania);
	  SET ISOLATION TO DIRTY READ;
      SELECT cod_tipoprod
             INTO v_cod_tipoprod
             FROM emitipro
            WHERE tipo_produccion = 4;

      FOREACH WITH HOLD
         SELECT x.no_poliza, x.no_endoso, x.no_factura, x.fecha_emision,
                x.prima_neta
           INTO v_nopoliza, v_noendoso, v_nofactura, v_fecha_emision,
                v_prima_neta
           FROM endedmae x
          WHERE x.cod_compania = a_compania
            AND x.periodo >= a_periodo_desde AND
                x.periodo <= a_periodo_hasta
			AND x.actualizado = 1

         SELECT cod_contratante,no_documento,cod_ramo
                INTO v_contratante,v_nodocumento,v_codramo
                FROM emipomae
               WHERE cod_compania = a_compania
                 AND no_poliza    = v_nopoliza
                 AND cod_tipoprod = v_cod_tipoprod;

         IF v_nodocumento IS NULL THEN
            CONTINUE FOREACH;
         END IF;
         SELECT cod_coasegur,porc_comis_ra,porc_impuesto
                INTO v_coaseguradora,w_porc_comis,w_porc_impuesto
                FROM emiciara
               WHERE no_poliza = v_nopoliza;
 
         IF w_porc_comis IS NULL THEN
            LET w_porc_comis = 0;
         END IF;
         IF w_porc_impuesto IS NULL THEN
            LET w_porc_impuesto = 0;
         END IF;
         LET v_comision = (v_prima_neta*w_porc_comis)/100;
         LET v_impuesto = (v_prima_neta*w_porc_impuesto)/100;

         IF v_nopoliza IS NULL OR
            v_coaseguradora IS NULL THEN
            CONTINUE FOREACH;
            LET v_prima_neta = 0;
            LET v_impuesto = 0;
            LET v_comision = 0;
            LET w_porc_comis = 0;
            LET w_porc_impuesto = 0;
 		 END IF 
         BEGIN
            ON EXCEPTION IN(-239)

            UPDATE temp_asegfacul
                   SET prima_neta     = prima_neta + v_prima_neta,
                       comision       = comision  + v_comision,
                       impuesto       = impuesto  + v_impuesto
                 WHERE no_factura     = v_nofactura
                   AND cod_coasegur   = v_coaseguradora
                   AND cod_ramo       = v_codramo;

         END EXCEPTION;
         INSERT INTO temp_asegfacul
              VALUES(v_nopoliza,
                     v_coaseguradora,
                     v_codramo,
                     v_nofactura,
                     v_fecha_emision,
                     v_nodocumento,
                     v_contratante,
                     v_prima_neta,
                     v_comision,
                     v_impuesto,
                     1);

            LET v_prima_neta = 0;
            LET v_impuesto   = 0;
            LET v_comision   = 0;
            LET w_porc_comis = 0;
            LET w_porc_impuesto = 0;
         END
      END FOREACH
      LET v_filtros = " ";
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
            -- Filtro de Coaseguradora
      IF a_coasegur <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Coaseguradora"||TRIM(a_coasegur);
         LET _tipo = sp_sis04(a_coasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente"||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_asegfacul
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF


      FOREACH
         SELECT temp_asegfacul.*
                INTO v_nopoliza,v_coaseguradora,v_codramo,v_nofactura,
                     v_fecha_emision,v_nodocumento,v_contratante,
                     v_prima_neta,v_comision,v_impuesto,v_seleccionado
                FROM temp_asegfacul
               WHERE seleccionado = 1
               ORDER BY cod_coasegur,cod_ramo,no_factura

         SELECT emicoase.nombre
                INTO v_desccoa
                FROM emicoase
               WHERE emicoase.cod_coasegur = v_coaseguradora;

         SELECT prdramo.nombre
                INTO v_descramo
                FROM prdramo
               WHERE prdramo.cod_ramo = v_codramo;

         SELECT cliclien.nombre
                INTO v_descclte
                FROM cliclien
               WHERE cliclien.cod_cliente = v_contratante;

         LET v_prima_neta1 = v_prima_neta - v_comision - v_impuesto;
         RETURN v_coaseguradora,v_codramo,v_nofactura,v_fecha_emision,
                v_nodocumento,v_contratante,v_prima_neta,
                v_comision,v_impuesto,v_prima_neta1,v_desccoa,
                v_descramo,v_descclte,a_periodo_desde,a_periodo_hasta,
                v_filtros,v_descr_cia
                WITH RESUME;
      END FOREACH

  DROP TABLE temp_asegfacul;
   END
END PROCEDURE;
