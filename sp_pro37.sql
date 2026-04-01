-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   06/09/2001                         inclusion de filtro de poliza

DROP procedure sp_pro37;
CREATE procedure "informix".sp_pro37(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(50),CHAR(10),CHAR(20),
                   CHAR(40),DEC(16,2),DEC(5,2),DEC(5,2),
                   DEC(9,2),CHAR(50),CHAR(255);

--------------------------------------------
---       COMISION POR FACULTATIVO       ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro37
--------------------------------------------
-- Modificado por Amado Perez el 16/5/2001--

   BEGIN
      DEFINE v_nopoliza,v_nofactura,v_cod_contratante  CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,v_nounidad           CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_porc_comis,v_porc_impuesto    DEC(5,2);
      DEFINE v_cod_coasegur,v_cod_cobertura  CHAR(3);
      DEFINE v_prima_suscrita                DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus,v_seleccionado        SMALLINT;
      DEFINE v_desc_nombre                   CHAR(40);
      DEFINE v_descr_cia,v_desc_ramo,v_desc_coasegur   CHAR(50);

      LET v_prima_suscrita  = 0;
      LET v_comision        = 0;
      LET v_porc_comis      = 0;
      LET v_porc_impuesto   = 0;
      LET v_cod_contratante = NULL;

      CREATE TEMP TABLE temp_facultativo
               (cod_coasegur     CHAR(3),
                no_factura       CHAR(10),
                no_documento     CHAR(20),
                no_unidad        CHAR(05),
                cod_cobertura    CHAR(03),
                no_poliza        CHAR(10),
                cod_contratante  CHAR(10),
                prima_suscrita   DEC(16,2),
                comision         DEC(5,2),
                impuesto         DEC(5,2),
			    seleccionado     SMALLINT DEFAULT 1,
            PRIMARY KEY(cod_coasegur,no_factura)) WITH NO LOG;

      CREATE INDEX i1_facul ON temp_facultativo(cod_coasegur);

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,"*",
                    a_codusuario,a_codramo,a_reaseguro)
                    RETURNING v_filtros;

      SET ISOLATION TO DIRTY READ;

        FOREACH WITH HOLD
         SELECT x.no_poliza,
                x.no_endoso
           INTO v_nopoliza,
                v_noendoso
           FROM temp_det x
          WHERE x.seleccionado = 1
		  group by 1, 2

		 select no_factura
		   into v_nofactura
		   from endedmae
		  where no_poliza = v_nopoliza
		    and no_endoso = v_noendoso;

		 select no_documento,
		        cod_contratante
		   into v_nodocumento,
		        v_cod_contratante
		   from emipomae
		  where no_poliza = v_nopoliza;

         FOREACH
            SELECT no_unidad,cod_cober_reas,cod_coasegur,
                   porc_comis_fac,porc_impuesto,prima
                   INTO v_nounidad,v_cod_cobertura,v_cod_coasegur,
                        v_porc_comis,v_porc_impuesto,v_prima_suscrita
                   FROM emifafac
                  WHERE no_poliza = v_nopoliza
                    AND no_endoso = v_noendoso

             BEGIN
             ON EXCEPTION IN(-239)
                UPDATE temp_facultativo
                     SET prima_suscrita = prima_suscrita + v_prima_suscrita
                   WHERE cod_coasegur  = v_cod_coasegur
                     AND no_factura    = v_nofactura;
                    
            END EXCEPTION;
            INSERT INTO temp_facultativo
                 VALUES(v_cod_coasegur,
                        v_nofactura,
                        v_nodocumento,
                        v_nounidad,
                        v_cod_cobertura,
                        v_nopoliza,
                        v_cod_contratante,
                        v_prima_suscrita,
                        v_porc_comis,
                        v_porc_impuesto,
                        1);
            END
         END FOREACH
       END FOREACH
      IF a_codcoasegur <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Coaseguradora"||TRIM(a_codcoasegur);
         LET _tipo = sp_sis04(a_codcoasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_facultativo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_facultativo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

-- Filtro de cliente
		IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Clientes"||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_facultativo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_facultativo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF 

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_facultativo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

--
      FOREACH
         SELECT *
                INTO v_cod_coasegur,v_nofactura,v_nodocumento,v_nounidad,
                     v_cod_cobertura,v_nopoliza,v_cod_contratante,
                     v_prima_suscrita,v_porc_comis,v_porc_impuesto,
                     v_seleccionado
                FROM temp_facultativo
               WHERE seleccionado = 1
               ORDER BY cod_coasegur

         LET v_comision = (v_prima_suscrita*v_porc_comis+
                         v_prima_suscrita*v_porc_impuesto)/100;
         SELECT nombre
                INTO v_desc_nombre
                FROM cliclien
               WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
                INTO v_desc_coasegur
                FROM emicoase
               WHERE cod_coasegur = v_cod_coasegur;

         RETURN v_cod_coasegur,v_desc_coasegur,v_nofactura,v_nodocumento,
                v_desc_nombre,v_prima_suscrita,v_porc_comis,v_porc_impuesto,
                v_comision,v_descr_cia,v_filtros  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   DROP TABLE temp_facultativo;
   END
END PROCEDURE;
