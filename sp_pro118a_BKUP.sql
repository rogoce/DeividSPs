--  DETALLE DE FACTURACION POR SUBRAMO  ---
-- Creado:     septiembre 2001 Autor: Lic.Amado Perez 
-- Modificado: 16/08/2001 -    Autor: Lic.Marquelda Valdelamar (inclusion de filtro de cliente)
--			   06/09/2001                                       inclusion de filtro de poliza


DROP procedure sp_pro118a;
CREATE procedure "informix".sp_pro118a(a_compania CHAR(03),a_agencia CHAR(03),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_cod_subramo CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(50),CHAR(3),CHAR(50),CHAR(10),CHAR(20),
                   CHAR(50),DEC(16,2),DEC(16,2),
                   DEC(9,2),CHAR(3),SMALLINT,CHAR(50),
                   CHAR(255),SMALLINT,CHAR(255);

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod,v_cod_subramo  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_ramo, v_desc_subramo     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_descripcion                   CHAR(255);
	  DEFINE _descrip                        CHAR(81);

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro118(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;

      SET ISOLATION TO DIRTY READ;

--Filtro de Subramo

      IF a_cod_subramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo: "||TRIM(a_cod_subramo);
         LET _tipo = sp_sis04(a_cod_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registroo

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

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
      FOREACH WITH HOLD
         SELECT x.cod_ramo,
                x.no_factura,
                x.no_documento,
                x.cod_contratante,
                x.estatus,
                x.forma_pago,
                x.cant_pagos, 
                x.suma_asegurada,
                x.prima,
                x.comision,
                x.cod_subramo,
                x.no_poliza,
                x.no_endoso
           INTO v_cod_ramo,
           		v_nofactura,
           		v_nodocumento,
           		v_cod_contratante,
                v_estatus,
                v_forma_pago,
                v_cant_pagos,
                v_suma_asegurada,
                v_prima_suscrita,
                v_comision,
                v_cod_subramo,
                v_nopoliza,
                v_noendoso
           FROM temp_det x
          WHERE x.seleccionado = 1
       ORDER BY x.cod_ramo,x.cod_subramo,x.no_factura

		 LET v_descripcion = "";

		 FOREACH
			SELECT TRIM(descripcion)
			  INTO _descrip
			  FROM blobuni
			 WHERE no_poliza = v_nopoliza
			   AND no_endoso = v_noendoso

			 LET v_descripcion = TRIM(v_descripcion)||" "||TRIM(_descrip); 

		 END FOREACH

         SELECT nombre
                INTO v_desc_ramo
                FROM prdramo
               WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
                INTO v_desc_subramo
                FROM prdsubra
               WHERE cod_ramo = v_cod_ramo
                 AND cod_subramo = v_cod_subramo;

         SELECT nombre
                INTO v_desc_nombre
                FROM cliclien
               WHERE cod_cliente = v_cod_contratante;

         RETURN v_cod_ramo,v_desc_ramo,v_cod_subramo,v_desc_subramo,
         		v_nofactura,v_nodocumento,v_desc_nombre,v_suma_asegurada,
         		v_prima_suscrita,v_comision,v_forma_pago,v_cant_pagos,v_descr_cia,
                v_filtros,v_estatus,v_descripcion  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;
