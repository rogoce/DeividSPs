-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   06/09/2001                         inclusion de filtro de poliza


--DROP procedure sp_pro34d;
CREATE procedure "informix".sp_pro34d(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(50),CHAR(10),CHAR(20),
                   CHAR(50),DEC(16,2),DEC(16,2),
                   DEC(9,2),CHAR(3),SMALLINT,CHAR(50),
                   CHAR(255),SMALLINT,char(5),char(50);

--------------------------------------------
---  DETALLE DE FACTURACION POR RAMO     ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro34b
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
	  define v_desc_agente					 CHAR(50);
      DEFINE _cod_agente                     CHAR(5);

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
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

      FOREACH WITH HOLD
         SELECT cod_ramo,
         		no_factura,
         		no_documento,
         		cod_contratante,
                estatus,
                forma_pago,
                cant_pagos,
                suma_asegurada,
                prima,
                comision,
				cod_agente
                INTO
                v_cod_ramo,
                v_nofactura,
                v_nodocumento,
                v_cod_contratante,
                v_estatus,
                v_forma_pago,
                v_cant_pagos,
                v_suma_asegurada,
                v_prima_suscrita,
                v_comision,
				_cod_agente
                FROM temp_det x
               WHERE seleccionado = 1
               ORDER BY cod_agente,cod_ramo,no_factura

         SELECT nombre
                INTO v_desc_ramo
                FROM prdramo
               WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
                INTO v_desc_nombre
                FROM cliclien
               WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
                INTO v_desc_agente
                FROM agtagent
               WHERE cod_agente = _cod_agente;

         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_nofactura,
         		v_nodocumento,
                v_desc_nombre,
                v_suma_asegurada,
                v_prima_suscrita,
                v_comision,
                v_forma_pago,
                v_cant_pagos,
                v_descr_cia,
                v_filtros,
                v_estatus,
                _cod_agente,
                v_desc_agente  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;
