DROP procedure sp_pro59a;
CREATE procedure "informix".sp_pro59a(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

         RETURNING CHAR(50),CHAR(5),CHAR(50),CHAR(10),CHAR(20),
                   CHAR(50),DEC(16,2),DEC(16,2),CHAR(50),
                   CHAR(255);

--------------------------------------------
---  DETALLE DE PRODUCCION POR GRUPO ---
---  Amado Perez - abril 2001 - 
---  Ref. Power Builder - d_sp_pro59a
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo        CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_porc_comis                    DEC(5,2);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_grupo                    CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago,_cod_no_renov      CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia,v_no_renov_desc     CHAR(50);
      DEFINE s_tipopro                       CHAR(03);

      LET s_tipopro         = NULL;
      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_agente      = NULL;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro59(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;

--Filtro de Cliente
      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registroo

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--

	  SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT x.cod_no_renov,x.cod_grupo,x.no_factura,x.no_documento,x.cod_contratante,
                x.suma_asegurada,x.prima
                INTO _cod_no_renov,v_cod_grupo,v_nofactura,v_nodocumento,v_cod_contratante,
                     v_suma_asegurada,v_prima_suscrita
                FROM temp_det x
               WHERE x.seleccionado = 1
               ORDER BY x.cod_no_renov,x.cod_grupo,x.no_factura

         SELECT nombre
                INTO v_desc_grupo
                FROM cligrupo
               WHERE cod_grupo = v_cod_grupo;

         SELECT nombre
                INTO v_desc_nombre
                FROM cliclien
               WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
		        INTO v_no_renov_desc
				FROM eminoren
			   WHERE cod_no_renov = _cod_no_renov;

         RETURN v_no_renov_desc,v_cod_grupo,v_desc_grupo,v_nofactura,v_nodocumento,
                v_desc_nombre,v_suma_asegurada,v_prima_suscrita,
                v_descr_cia,v_filtros  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;
