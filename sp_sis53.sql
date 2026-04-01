DROP procedure sp_sis53;
CREATE procedure "informix".sp_sis53()

         RETURNING CHAR(10),CHAR(50),DEC(16,2),DEC(10,2),
                   DEC(10,2),DEC(10,2),DEC(10,2),DEC(10,2),
                   CHAR(50),CHAR(255);

--------------------------------------------
--TOTALES DE DETALLE DE REASEGURO POR RAMO -
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro36
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo				         CHAR(10);
      DEFINE v_cobertura          			 CHAR(03);
      DEFINE v_prima_suscrita                DECIMAL(16,2);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_retencion,v_facul_terre,v_facul_otros,v_comi_terre,
             v_comi_otros,v_prima                  DEC(10,2);
      DEFINE v_tipo_contrato,sta_terremoto           SMALLINT;
      DEFINE _no_factura                      CHAR(10);

      CALL sp_pro34("001","001","2004-01",
                    "2004-01","*","*","*",
                    "*","*","*")
                    RETURNING v_filtros;

      CREATE TEMP TABLE temp_reaseguro
               (cod_ramo         CHAR(10),
			    desc_ramo        CHAR(50),
                retencion        DEC(10,2),
                facul_terre      DEC(10,2),
                facul_otros      DEC(10,2),
                comi_terre       DEC(10,2),
                comi_otros       DEC(10,2),
            PRIMARY KEY(cod_ramo)) WITH NO LOG;

      CREATE TEMP TABLE temp_reaseguro1
               (cod_ramo         CHAR(10),
                prima            DEC(16,2),
            PRIMARY KEY(cod_ramo)) WITH NO LOG;

      LET v_prima_suscrita  = 0;
      LET v_descr_cia = sp_sis01("001");

--set debug file to "sp_sis53.trc";
--trace on;

	  SET ISOLATION TO DIRTY READ;

      FOREACH
         SELECT no_poliza,
         		no_endoso,
         		sum(prima)
           INTO v_nopoliza,
              	v_noendoso,
                v_prima_suscrita
           FROM temp_det 
          WHERE seleccionado = 1
--		    and no_factura   = "01-258797"
	   group by 1, 2

{			select no_factura 
			  into v_cod_ramo
			  from endedmae
			 where no_poliza = v_nopoliza
			   and no_endoso = v_noendoso;
}
			select cod_ramo
			  into v_cod_ramo
			  from emipomae
			 where no_poliza = v_nopoliza;

          BEGIN
            ON EXCEPTION IN(-239)
               UPDATE temp_reaseguro1
                  SET prima    = prima + v_prima_suscrita
                WHERE cod_ramo = v_cod_ramo;
            END EXCEPTION

            INSERT INTO temp_reaseguro1
            VALUES(
            	  v_cod_ramo,
                  v_prima_suscrita
                  );
          END

         FOREACH
            SELECT cod_cober_reas,
            	   cod_contrato,
            	   prima
              INTO v_cobertura,
              	   v_cod_contrato,
              	   v_prima
              FROM emifacon
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso

            SELECT tipo_contrato
              INTO v_tipo_contrato
              FROM reacomae
             WHERE cod_contrato = v_cod_contrato;

            LET v_retencion   = 0;
            LET v_facul_terre = 0;
            LET v_facul_otros = 0;
            LET v_comi_terre  = 0;
            LET v_comi_otros  = 0;

            IF v_tipo_contrato = 1 THEN	  --Retencion
               LET v_retencion = v_prima;
            ELIF v_tipo_contrato = 3 THEN --facult.
               SELECT es_terremoto
                 INTO sta_terremoto
                 FROM reacobre
                WHERE cod_cober_reas = v_cobertura;

               IF sta_terremoto = 1 THEN
                  LET v_facul_terre = v_prima;
               ELSE
                  LET v_facul_otros = v_prima;
               END IF
            ELSE 
               SELECT es_terremoto
                 INTO sta_terremoto
                 FROM reacobre
                WHERE cod_cober_reas = v_cobertura;

               IF sta_terremoto = 1 THEN
                  LET v_comi_terre = v_prima;
               ELSE
                  LET v_comi_otros = v_prima;
               END IF
            END IF

            BEGIN
            ON EXCEPTION IN(-239)
               UPDATE temp_reaseguro
                      SET retencion     = retencion + v_retencion,
                          facul_terre   = facul_terre + v_facul_terre,
                          facul_otros   = facul_otros + v_facul_otros,
                          comi_terre    = comi_terre  + v_comi_terre,
                          comi_otros    = comi_otros  + v_comi_otros
                    WHERE cod_ramo      = v_cod_ramo;

            END EXCEPTION

			 SELECT nombre
                INTO v_desc_ramo
                FROM prdramo
               WHERE cod_ramo = v_cod_ramo;

            INSERT INTO temp_reaseguro
                  VALUES(v_cod_ramo,
				         v_desc_ramo,
                         v_retencion,
                         v_facul_terre,
                         v_facul_otros,
                         v_comi_terre,
                         v_comi_otros);
           END
         END FOREACH
      END FOREACH
      FOREACH
         SELECT cod_ramo,desc_ramo,retencion,facul_terre,facul_otros,
                comi_terre,comi_otros
                INTO v_cod_ramo,v_desc_ramo,v_retencion,v_facul_terre,
                     v_facul_otros,v_comi_terre,v_comi_otros
                FROM temp_reaseguro
               ORDER BY cod_ramo

        SELECT prima
               INTO v_prima_suscrita
               FROM temp_reaseguro1
              WHERE cod_ramo = v_cod_ramo;

--		if v_prima_suscrita <> (v_retencion + v_facul_terre + v_facul_otros + v_comi_terre + v_comi_otros) then
        
	         RETURN v_cod_ramo,v_desc_ramo,v_prima_suscrita,v_retencion,
	                v_facul_terre,v_facul_otros,v_comi_terre,v_comi_otros,
	                v_descr_cia,v_filtros
	                WITH RESUME;

--		end if

      END FOREACH

      DROP TABLE temp_reaseguro;
      DROP TABLE temp_reaseguro1;
      DROP TABLE temp_det;

   END

END PROCEDURE
