DROP procedure sp_pro69a;
CREATE procedure "informix".sp_pro69a(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(3),	   -- cod_ramo
 		  CHAR(50),    -- desc. ramo
 		  CHAR(10),    -- no_factura
 		  CHAR(20),    -- no_documento
          CHAR(50),    -- cliente
          DEC(16,2),   -- suma asegurada
          DEC(16,2),   -- prima suscrita
          CHAR(50),    -- desc. cia
          DATE,	  	   -- vig ini
		  DATE,	  	   -- vig fin
          CHAR(255),   -- filtros
		  CHAR(50);    -- corredor
--------------------------------------------
---  DETALLE DE POLIZAS DECLARATIVAS     ---
---  Armando Moreno - julio 2001 - AMM	 ---
---  Ref. Power Builder - d_sp_pro34b	 ---
--------------------------------------------
   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,_cod_corredor        CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(100);
      DEFINE v_desc_ramo,v_corredor          CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_vig_ini,v_vig_fin			 DATE;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro69(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_cliente, a_no_documento)
                    RETURNING v_filtros;

      SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT cod_ramo,
         		no_factura,
         		no_documento,
         		cod_contratante,
                suma_asegurada,
                prima,
				vigencia_inic,
				vigencia_final,
				cod_agente
           INTO v_cod_ramo,
           		v_nofactura,
           		v_nodocumento,
           		v_cod_contratante,
                v_suma_asegurada,
                v_prima_suscrita,
				v_vig_ini,
				v_vig_fin,
				_cod_corredor
                FROM temp_det
               WHERE seleccionado = 1
               ORDER BY cod_ramo,vigencia_final

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
           INTO v_corredor
           FROM agtagent
          WHERE cod_agente = _cod_corredor;

         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_nofactura,
         		v_nodocumento,
                v_desc_nombre,
                v_suma_asegurada,
                v_prima_suscrita,
                v_descr_cia,
				v_vig_ini,
				v_vig_fin,
                v_filtros,
				v_corredor
                WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;
