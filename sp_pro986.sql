DROP procedure sp_pro986;
CREATE procedure "informix".sp_pro986(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*")

         RETURNING CHAR(03),CHAR(50),DEC(16,2),DEC(10,2),
                   DEC(10,2),DEC(10,2),DEC(10,2),DEC(10,2),
                   CHAR(50),CHAR(255),DEC(10,2),DEC(10,2),DEC(10,2),DEC(10,2);
--------------------------------------------
--- TOTALES DE DETALLE DE REASEGURO POR RAMO y FACULTATIVO FRONTING
--- Ref. Power Builder - d_sp_pro986
--- Modificado por HENRY GIRON 04/12/2009; 
--------------------------------------------
   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_prima_suscrita                DECIMAL(16,2);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_facul_terre,v_facul_otros,v_comi_terre,
             v_comi_otros,v_prima                  DEC(10,2);
      DEFINE v_tipo_contrato,sta_terremoto,_fronting     SMALLINT;
	  define v_retencion,v_m_comision		 DEC(16,2);
	  define v_faculf_terre,v_faculf_otros	 DEC(10,2);
	  define v_comisionff,v_comisionfo       DEC(10,2);

      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro)
                    RETURNING v_filtros;

      CREATE TEMP TABLE temp_reaseguro
               (cod_ramo         CHAR(3),
			    desc_ramo        CHAR(50),
                retencion        DEC(16,2),
                facul_terre      DEC(10,2),
                facul_otros      DEC(10,2),
                comi_terre       DEC(10,2),
                comi_otros       DEC(10,2),
                faculf_terre     DEC(10,2),
                faculf_otros     DEC(10,2),
				comisionff       DEC(10,2),
				comisionfo       DEC(10,2),
            PRIMARY KEY(cod_ramo)) WITH NO LOG;

      CREATE TEMP TABLE temp_reaseguro1
               (cod_ramo         CHAR(3),
                prima            DEC(16,2),
            PRIMARY KEY(cod_ramo)) WITH NO LOG;

      LET v_prima_suscrita  = 0;
      LET v_descr_cia = sp_sis01(a_compania);

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
		  group by 1, 2

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

            SELECT tipo_contrato, fronting
              INTO v_tipo_contrato, _fronting
              FROM reacomae
             WHERE cod_contrato = v_cod_contrato;

            LET v_retencion    = 0;
            LET v_facul_terre  = 0;
            LET v_facul_otros  = 0;
            LET v_faculf_terre = 0;
            LET v_faculf_otros = 0;
            LET v_comi_terre   = 0;
            LET v_comi_otros   = 0;
			LET v_m_comision   = 0;
			LET v_comisionff   = 0;
			LET v_comisionfo   = 0;

            IF v_tipo_contrato = 1 THEN	  --Retencion
               LET v_retencion = v_prima;
            ELIF v_tipo_contrato = 3 THEN --facult.


             SELECT sum(monto_comision)
               INTO v_m_comision
               FROM emifafac
              WHERE no_poliza = v_nopoliza
                AND no_endoso = v_noendoso
	 	        and cod_contrato   = v_cod_contrato
	 	        and cod_cober_reas = v_cobertura ;

               SELECT es_terremoto
                 INTO sta_terremoto
                 FROM reacobre
                WHERE cod_cober_reas = v_cobertura;

				if _fronting = 1 then 
	               IF sta_terremoto = 1 THEN
	                  LET v_faculf_terre = v_prima;
	               ELSE
	                  LET v_faculf_otros = v_prima;
	               END IF
				   LET v_comisionff = v_m_comision;
				else
	               IF sta_terremoto = 1 THEN
	                  LET v_facul_terre = v_prima;
	               ELSE
	                  LET v_facul_otros = v_prima;
	               END IF
				   LET v_comisionfo = v_m_comision;
				end if

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
                      SET retencion     = retencion   + v_retencion,
                          facul_terre   = facul_terre + v_facul_terre,
                          facul_otros   = facul_otros + v_facul_otros,
                          comi_terre    = comi_terre  + v_comi_terre,
                          comi_otros    = comi_otros  + v_comi_otros,
                          faculf_terre   = faculf_terre + v_faculf_terre,
                          faculf_otros   = faculf_otros + v_faculf_otros,
						  comisionff    =  comisionff + v_comisionff,
						  comisionfo    =  comisionfo + v_comisionfo
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
                         v_comi_otros,
                         v_faculf_terre,
                         v_faculf_otros,
						 v_comisionff,
						 v_comisionfo
                         );
           END
         END FOREACH
      END FOREACH
      FOREACH
         SELECT cod_ramo,
                desc_ramo,
                retencion,
                facul_terre,
                facul_otros,
                comi_terre,
                comi_otros,
                faculf_terre,
                faculf_otros,
			    comisionff,
				comisionfo
           INTO v_cod_ramo,
           		v_desc_ramo,
           		v_retencion,
           		v_facul_terre,
                v_facul_otros,
                v_comi_terre,
                v_comi_otros,
                v_faculf_terre,
                v_faculf_otros,
			    v_comisionff,
				v_comisionfo
           FROM temp_reaseguro
       ORDER BY cod_ramo

        SELECT prima
          INTO v_prima_suscrita
          FROM temp_reaseguro1
         WHERE cod_ramo = v_cod_ramo;

		if v_faculf_otros is null then
		   LET v_faculf_otros =	0 ;
		end if

		if v_facul_otros is null then
		   LET v_facul_otros =	0 ;
		end if

		if v_faculf_terre is null then
		   LET v_faculf_terre =	0 ;
		end if

		if v_facul_terre is null then
		   LET v_facul_terre =	0 ;
		end if

		if v_comisionff is null then
		   LET v_comisionff =	0 ;
		end if

		if v_comisionfo is null then
		   LET v_comisionfo =	0 ;
		end if

        
         RETURN v_cod_ramo,v_desc_ramo,v_prima_suscrita,v_retencion,
                v_facul_terre,v_facul_otros,v_comi_terre,v_comi_otros,
                v_descr_cia,v_filtros,v_faculf_terre,v_faculf_otros,v_comisionff,v_comisionfo
                WITH RESUME;
      END FOREACH

      DROP TABLE temp_reaseguro;
      DROP TABLE temp_reaseguro1;
      DROP TABLE temp_det;
   END
END PROCEDURE
