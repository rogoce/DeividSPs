 DROP PROCEDURE sp_pro18a;
CREATE PROCEDURE "informix".sp_pro18a(
a_compania CHAR(3),
a_agencia CHAR(3),
a_codsucursal CHAR(255) DEFAULT "*",
a_codsubramo CHAR(255) DEFAULT "*",
a_codgrupo CHAR(255) DEFAULT "*",
a_periodo_desde CHAR(7),
a_periodo_hasta CHAR(7)
)RETURNING CHAR(50),
		   CHAR(3),
		   CHAR(50),
		   CHAR(5),
		   CHAR(50),
		   DEC(16,2),
           SMALLINT,
           DEC(16,2),
           SMALLINT,
           DEC(16,2),
           SMALLINT,
           CHAR(7),
           CHAR(7),
           CHAR(255),
           CHAR(10);
--------------------------------------------
---  ANALISIS DE PRIMAJE PARA EL RAMO    ---
---             AUTOMOVIL                ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_prod_sp_pro18a
--	 Mod. por Armando Moreno 18/06/2002
--------------------------------------------
   BEGIN

      DEFINE v_cod_ramo,v_cod_subramo,v_codsucursal,w_codramo CHAR(3);
      DEFINE v_cod_grupo    CHAR(05);
      DEFINE v_prima_suscrita,v_prima_prom1,v_prima_prom2 DECIMAL(16,2);
      DEFINE v_cantidad,v_total_unidades,v_cantidad1,v_total_unidades1,
             v_cant_facturas,v_seleccionado,v_cant_total  SMALLINT;
      DEFINE v_desc_subra,v_desc_grupo,v_descr_cia   CHAR(50);
      DEFINE v_filtros,v_filtros2                    CHAR(255);
      DEFINE _tipo                                   CHAR(01);
	  DEFINE _no_documento							 CHAR(20);
	  DEFINE _fecha_char,v_nopo,v_nopo1       CHAR(10);
	  DEFINE _periodo	       CHAR(7);
	  DEFINE _mes								 SMALLINT;
	  DEFINE _ano2 			CHAR(4);
	  DEFINE _mes2 		    CHAR(2);
	  DEFINE _fecha									 DATE;
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

	  --Polizas vigentes al periodo final
      CALL sp_amm31a(a_compania,a_agencia,a_codsucursal,a_codsubramo,a_codgrupo,a_periodo_desde,a_periodo_hasta)
                    RETURNING v_filtros;

      SELECT cod_ramo
        INTO v_cod_ramo
        FROM prdramo
       WHERE ramo_sis = 1;

	   LET v_cod_ramo = v_cod_ramo || ";" ;

	LET _periodo = a_periodo_hasta;
	LET _mes     = _periodo[6,7];
	LET _ano2    = _periodo[1,4];

	IF _mes < 10 THEN
	   LET _mes2 = "0" || _mes;
	ELSE
	   LET _mes2 = _mes;
	END IF

	LET _periodo = _ano2 || "-" || _mes2;

	IF _periodo[6,7] = 2 THEN
		LET _fecha_char[1,2] = '28';
	ELIF _periodo[6,7] = 4  OR
		 _periodo[6,7] = 6  OR
		 _periodo[6,7] = 9  OR
		 _periodo[6,7] = 11 THEN
		LET _fecha_char[1,2] = '30';
	ELSE
		LET _fecha_char[1,2] = '31';
	END IF

	LET _fecha_char[3,3]  = '/';
	LET _fecha_char[4,5]  = _periodo[6,7];
	LET _fecha_char[6,6]  = '/';
	LET _fecha_char[7,10] = _periodo[1,4];

	LET _fecha = _fecha_char;

	  CALL sp_pro03(a_compania,a_agencia,_fecha,'002;') RETURNING v_filtros2;

       SET ISOLATION TO DIRTY READ;
--------
       FOREACH
          SELECT cod_ramo,
				 cod_subramo,
				 cod_grupo,
				 seleccionado,
				 cod_sucursal,
				 no_poliza
            INTO v_cod_ramo,
 		         v_cod_subramo,
 		         v_cod_grupo,
                 v_seleccionado,
				 v_codsucursal,
				 v_nopo
            FROM temp_perfil
           WHERE seleccionado = 1
           ORDER BY cod_subramo,cod_grupo

          SELECT cod_ramo
            INTO v_desc_subra
            FROM tmp_primaje
           WHERE seleccionado = 1
             AND cod_ramo    = v_cod_ramo
		     AND cod_subramo = v_cod_subramo
		     AND cod_grupo   = v_cod_grupo;

		  IF v_desc_subra IS NULL THEN
			BEGIN
			  ON EXCEPTION IN (-239)

              END EXCEPTION
              INSERT INTO tmp_primaje
              VALUES(v_codsucursal,
              		 v_cod_ramo,
		             v_cod_subramo,
        		     v_cod_grupo,
              		 0,
		             0,
		             1,
		             v_nopo);
            END;
		  END IF
	   END FOREACH
-------
       FOREACH
          SELECT y.*
            INTO v_codsucursal,
 		         v_cod_ramo,
 		         v_cod_subramo,
 		         v_cod_grupo,
                 v_prima_suscrita,
                 v_cant_facturas,
                 v_seleccionado,
				 v_nopo1
            FROM tmp_primaje y
           WHERE y.seleccionado = 1
           ORDER BY y.cod_subramo,y.cod_grupo

          SELECT DISTINCT COUNT(no_poliza)
            INTO v_cantidad
            FROM temp_perfil
           WHERE seleccionado = 1
             AND cod_ramo    = v_cod_ramo
		     AND cod_subramo = v_cod_subramo
		     AND cod_grupo   = v_cod_grupo;

		  LET v_total_unidades = 0;

		  FOREACH
		   SELECT no_poliza
             INTO v_nopo
             FROM temp_perfil
            WHERE seleccionado = 1
              AND cod_ramo    = v_cod_ramo
		      AND cod_subramo = v_cod_subramo
		      AND cod_grupo   = v_cod_grupo

		   SELECT COUNT(no_unidad)
			 INTO v_total_unidades1
			 FROM emipouni
			WHERE no_poliza = v_nopo;

          	LET v_total_unidades = v_total_unidades + v_total_unidades1;

		  END FOREACH

          IF v_cantidad IS NULL THEN
             LET v_cantidad = 0;
          END IF;

          --LET v_cantidad = v_cantidad + v_cantidad1;

          IF v_total_unidades IS NULL OR
             v_total_unidades = 0     THEN
             LET v_total_unidades = 0;
             LET v_prima_prom2    = v_prima_suscrita;
          ELSE
             LET v_prima_prom2 = v_prima_suscrita/v_total_unidades;
          END IF;

		  IF v_cantidad IS NULL OR
		     v_cantidad = 0     THEN
			 LET v_cantidad = 0; 
			 LET v_prima_prom1 = v_prima_suscrita;
		  ELSE
             LET v_prima_prom1 = v_prima_suscrita/v_cantidad;
		  END IF;

          SELECT a.nombre
            INTO v_desc_subra
            FROM prdsubra a
           WHERE a.cod_ramo    = v_cod_ramo
             AND a.cod_subramo = v_cod_subramo;

          SELECT b.nombre
            INTO v_desc_grupo
            FROM cligrupo b
           WHERE b.cod_grupo = v_cod_grupo;

          RETURN v_descr_cia,
          		 v_cod_subramo,
          		 v_desc_subra,
          		 v_cod_grupo,
                 v_desc_grupo,
                 v_prima_suscrita,
                 v_cantidad,
                 v_prima_prom1,
                 v_total_unidades,
                 v_prima_prom2,
                 v_cant_facturas,
                 a_periodo_desde,
                 a_periodo_hasta,
                 v_filtros,
				 v_nopo1
                  WITH RESUME;

          LET v_cantidad = 0;
       END FOREACH
   END
   DROP TABLE tmp_primaje;
   DROP TABLE temp_perfil;
END PROCEDURE;
