--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro40
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--------------------------------------------
DROP PROCEDURE sp_pro146;
CREATE PROCEDURE sp_pro146(
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
RETURNING CHAR(03),CHAR(50),CHAR(50),CHAR(50),DECIMAL(16,2),CHAR(50),CHAR(255), smallint;


   BEGIN

      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo,v_desc_cobertura,
             v_desc_contrato                 CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima,v_prima1                DEC(10,2);
      DEFINE v_tipo_contrato                 SMALLINT;
	  define _serie							 smallint;
	
     CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro, "1") RETURNING v_filtros;

     CREATE TEMP TABLE temp_produccion
               (cod_ramo         CHAR(3),
			    serie			 smallint,
                cod_contrato     CHAR(5),
                cod_cobertura    CHAR(3),
				prima            DEC(16,2)
				) WITH NO LOG;

      LET v_prima     = 0;
      LET v_descr_cia = sp_sis01(a_compania);
    
      SET ISOLATION TO DIRTY READ;

      FOREACH WITH HOLD
	     SELECT z.no_poliza,
	     		z.no_endoso
           INTO v_nopoliza,
           		v_noendoso
           FROM temp_det z
          WHERE z.seleccionado = 1
		  group by 1, 2

			select cod_ramo
			  into v_cod_ramo
			  from emipomae
			 where no_poliza = v_nopoliza;

         FOREACH
		    SELECT cod_cober_reas,
		    	   cod_contrato,prima
              INTO v_cobertura,
              	   v_cod_contrato,
              	   v_prima
              FROM emifacon
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso
               AND prima     <> 0

	            SELECT tipo_contrato,
				       serie
	              INTO v_tipo_contrato,
				       _serie
	              FROM reacomae
	             WHERE cod_contrato = v_cod_contrato;

	            IF v_tipo_contrato = 1 OR
				   v_tipo_contrato = 3 THEN
	               CONTINUE FOREACH;
	            END IF

				INSERT INTO temp_produccion
                VALUES (v_cod_ramo,
				        _serie,
                        v_cod_contrato,
                        v_cobertura,
                        v_prima
                        );

         END FOREACH

      END FOREACH

      FOREACH
         SELECT cod_ramo,
         		serie,
				cod_contrato,
         		cod_cobertura,
         		SUM(prima)
           INTO v_cod_ramo,
           		_serie,
				v_cod_contrato,
           		v_cobertura,
           		v_prima
           FROM temp_produccion
		  where cod_ramo in ("008", "013", "014", "016")
       GROUP BY cod_ramo, cod_contrato, serie, cod_cobertura
	   ORDER BY cod_ramo, cod_contrato, serie, cod_cobertura

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_contrato
           FROM reacomae
          WHERE cod_contrato = v_cod_contrato;

         SELECT nombre
           INTO v_desc_cobertura
           FROM reacobre
          WHERE cod_cober_reas = v_cobertura;

         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_desc_contrato,
                v_desc_cobertura,
                v_prima,
                v_descr_cia,
                v_filtros,
                _serie 
                WITH RESUME;

      END FOREACH

      DROP TABLE temp_produccion;
      DROP TABLE temp_det;

   END

END PROCEDURE
