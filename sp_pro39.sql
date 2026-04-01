DROP procedure sp_pro39;
CREATE procedure "informix".sp_pro39(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(50),DEC(16,2),
                   DEC(9,2),DEC(9,2),CHAR(50),
                   CHAR(255);

--------------------------------------------
---  COMISION DE FACULTATIVO POR RAMO    ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro39
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_ramo                      CHAR(03);
      DEFINE v_porc_comis,v_porc_impuesto    DEC(5,2);
      DEFINE v_prima_cedida                  DECIMAL(16,2);
      DEFINE v_comision,v_impuesto           DECIMAL(9,2);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia,v_desc_ramo         CHAR(50);

      LET v_prima_cedida  = 0;
      LET v_comision      = 0;
      LET v_impuesto      = 0;

      CREATE TEMP TABLE temp_comision
               (cod_ramo         CHAR(3),
                prima_cedida     DEC(16,2),
                comision         DEC(9,2),
                impuesto         DEC(9,2),
                PRIMARY KEY(cod_ramo)) WITH NO LOG;

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

			select cod_ramo
			  into v_cod_ramo
			  from emipomae
			 where no_poliza = v_nopoliza;

         FOREACH
            SELECT prima,
            	   porc_comis_fac,
            	   porc_impuesto
              INTO v_prima_cedida,
              	   v_porc_comis,
              	   v_porc_impuesto
              FROM emifafac
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso

            IF v_porc_comis IS NULL THEN
              LET v_porc_comis = 0;
            END IF;
            IF v_porc_impuesto IS NULL THEN
              LET v_porc_impuesto = 0;
            END IF;
            LET v_comision = (v_prima_cedida*v_porc_comis/100);
            LET v_impuesto = (v_prima_cedida*v_porc_impuesto/100);

            BEGIN
             ON EXCEPTION IN(-239)
                UPDATE temp_comision
                     SET prima_cedida = prima_cedida + v_prima_cedida,
                         comision     = comision + v_comision,
                         impuesto     = impuesto + v_impuesto
                   WHERE cod_ramo     = v_cod_ramo;

            END EXCEPTION;
            INSERT INTO temp_comision
                 VALUES(v_cod_ramo,
                        v_prima_cedida,
                        v_comision,
                        v_impuesto);
            END
         END FOREACH
      END FOREACH
         FOREACH
            SELECT cod_ramo,
            	   prima_cedida,
            	   comision,
            	   impuesto
              INTO v_cod_ramo,
              	   v_prima_cedida,
              	   v_comision,
                   v_impuesto
              FROM temp_comision
          ORDER BY cod_ramo

            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;

            RETURN v_cod_ramo,
            	   v_desc_ramo,
            	   v_prima_cedida,
                   v_comision,
                   v_impuesto,
                   v_descr_cia,
                   v_filtros
                   WITH RESUME;
         END FOREACH

   DROP TABLE temp_det;
   DROP TABLE temp_comision;
   END
END PROCEDURE;
