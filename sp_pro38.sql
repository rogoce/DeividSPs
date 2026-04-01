DROP procedure sp_pro38;
CREATE procedure "informix".sp_pro38(
a_compania    CHAR(03),
a_agencia     CHAR(03),
a_periodo1    CHAR(07),
a_periodo2    CHAR(07),
a_codsucursal CHAR(255) DEFAULT "*",
a_codgrupo    CHAR(255) DEFAULT "*",
a_codagente   CHAR(255) DEFAULT "*",
a_codusuario  CHAR(255) DEFAULT "*",
a_codramo     CHAR(255) DEFAULT "*",
a_reaseguro   CHAR(255) DEFAULT "*"
)

RETURNING CHAR(3),
		  CHAR(50),
		  DEC(16,2),
		  DEC(10,2),
          DEC(10,2),
          CHAR(50),
          CHAR(255);

--------------------------------------------
---    COMISION DE CORREDOR POR RAMO     ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro38
--------------------------------------------

BEGIN
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_agente                    CHAR(5);
      DEFINE v_prima_suscrita                DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(10,2);
      DEFINE v_porc_comision                 DECIMAL(10,2);
      DEFINE v_filtros                       CHAR(255);
      DEFINE v_desc_ramo,v_descr_cia         CHAR(50);

      LET v_prima_suscrita  = 0;
      LET v_comision        = 0;
      LET v_porc_comision   = 0;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro34(a_compania,
      				a_agencia,
      				a_periodo1,
                    a_periodo2,
                    a_codsucursal,
                    a_codgrupo,
                    a_codagente,
                    a_codusuario,
                    a_codramo,
                    a_reaseguro)
                    RETURNING v_filtros;

	  SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT cod_ramo,
            	SUM(prima),
         		SUM(comision)
           INTO v_cod_ramo,
           		v_prima_suscrita,
           		v_comision
           FROM temp_det
          WHERE seleccionado = 1
       GROUP BY cod_ramo
       ORDER BY cod_ramo

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         IF v_prima_suscrita <> 0 THEN
            LET v_porc_comision = ((v_comision/v_prima_suscrita)*100);
         END IF
         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_prima_suscrita,
         		v_comision,
                v_porc_comision,
                v_descr_cia,
                v_filtros  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
END
END PROCEDURE;