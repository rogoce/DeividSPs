DROP PROCEDURE sp_pro99a;
CREATE PROCEDURE "informix".sp_pro99a(a_compania CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7))
         RETURNING CHAR(50),CHAR(3),CHAR(50),DEC(16,2),
                   SMALLINT,DEC(16,2),SMALLINT,DEC(16,2),SMALLINT,
                   CHAR(7),CHAR(7),CHAR(255);

--------------------------------------------
---  ANALISIS DE PRIMAJE PARA EL RAMO    ---
---             AUTOMOVIL                ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_prod_sp_pro18a
--------------------------------------------

BEGIN

      DEFINE v_cod_ramo,v_cod_subramo,v_codsucursal,w_codramo CHAR(3);
      DEFINE v_cod_grupo    CHAR(05);
      DEFINE v_prima_suscrita,v_prima_prom1,v_prima_prom2 DECIMAL(16,2);
      DEFINE v_cantidad,v_total_unidades,v_cantidad1,
             v_cant_facturas,v_seleccionado,v_cant_total  SMALLINT;
      DEFINE v_desc_subra,v_desc_grupo,v_descr_cia   CHAR(50);
      DEFINE v_filtros                               CHAR(255);
      DEFINE _tipo                                   CHAR(01);
	  DEFINE _no_documento							 CHAR(20);

      LET v_cod_subramo    = NULL;
      LET v_cod_grupo      = NULL;
      LET v_prima_suscrita = NULL;
      LET v_cantidad       = 0;
      LET v_total_unidades = 0;
      LET v_cant_facturas  = 0;
      LET v_cantidad1      = 0;
	  LET v_desc_subra     = NULL;
      LET v_desc_grupo     = NULL;
      LET v_descr_cia      = NULL;
      LET v_prima_prom1    = 0;
      LET v_prima_prom2    = 0;
      LET v_filtros        = " ";

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro18(a_compania,a_agencia,a_codsucursal,a_codsubramo,a_codgrupo,a_periodo_desde,a_periodo_hasta)
                    RETURNING v_filtros;

       SET ISOLATION TO DIRTY READ;
       FOREACH
          SELECT cod_subramo,
          		 SUM(prima_suscrita),
				 SUM(cant_facturas),
				 SUM(total_unidades)
            INTO v_cod_subramo,
                 v_prima_suscrita,
                 v_cant_facturas,
				 v_total_unidades
            FROM tmp_primaje
           WHERE seleccionado = 1
		   GROUP BY cod_subramo
           ORDER BY cod_subramo

          SELECT DISTINCT COUNT(no_documento)
            INTO v_cantidad
            FROM tmp_cantpoli
           WHERE seleccionado = 1
             AND cod_subramo  = v_cod_subramo;

	          IF v_cantidad is NULL THEN
	             LET v_cantidad = 0;
	          END IF;

          IF v_total_unidades IS NULL OR v_total_unidades = 0 THEN
             LET v_total_unidades = 0;
             LET v_prima_prom2    = v_prima_suscrita;
          ELSE
             LET v_prima_prom2 = v_prima_suscrita/v_total_unidades;
          END IF;

		  IF v_cantidad IS NULL OR v_cantidad = 0 THEN
			 LET v_cantidad = 0; 
			 LET v_prima_prom1 = v_prima_suscrita;
		  ELSE
             LET v_prima_prom1 = v_prima_suscrita/v_cantidad;
		  END IF;

          SELECT a.nombre
            INTO v_desc_subra
            FROM prdsubra a
           WHERE a.cod_ramo    = '002'
             AND a.cod_subramo = v_cod_subramo;

          RETURN v_descr_cia,v_cod_subramo,v_desc_subra,
                 v_prima_suscrita,v_cantidad,v_prima_prom1,
                 v_total_unidades,v_prima_prom2,v_cant_facturas,a_periodo_desde,
                 a_periodo_hasta,v_filtros WITH RESUME;

          LET v_cantidad = 0;
       END FOREACH
END
DROP TABLE tmp_primaje;
DROP TABLE tmp_cantpoli;
END PROCEDURE;
