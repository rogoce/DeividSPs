--  Analisis de Primaje de Auto

--  Creado: 08/2000  - Creado: Yinia M. Zamora 
--  SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_pro18;
CREATE PROCEDURE "informix".sp_pro18(a_compania CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7))
         RETURNING CHAR(255);

   BEGIN
      DEFINE v_nopoliza,poliza_nueva,v_nopolizas  CHAR(10);
      DEFINE v_cod_ramo,v_cod_subramo,v_codsucursal,
             w_codramo,v_cod_compania CHAR(3);
	  DEFINE v_cod_grupo,v_noendoso,v_noendosos     CHAR(05);
      DEFINE v_prima_suscrita            DECIMAL(16,2);
      DEFINE contador,v_cantidad,v_total_unidades,
             v_cant_facturas             SMALLINT;
      DEFINE v_desc_subra,v_desc_grupo,v_descr_cia   CHAR(50);
      DEFINE v_prima_prom1,v_prima_prom2 DECIMAL(16,2);
      DEFINE v_filtros                   CHAR(255);
      DEFINE v_seleccionado,v_tipo_mov   SMALLINT;
      DEFINE _tipo                       CHAR(01);
	  DEFINE v_periodo   				 CHAR(07);
      DEFINE v_codmov                    CHAR(03);
      DEFINE v_nodocumento               CHAR(20);

      LET v_prima_suscrita = NULL;
      LET v_cantidad       = 0;
      LET v_total_unidades = 0;
      LET v_cant_facturas  = 0;
      LET v_desc_subra     = NULL;
      LET v_desc_grupo     = NULL;
      LET v_descr_cia      = NULL;
      LET v_prima_prom1    = 0;
      LET v_prima_prom2    = 0;
      LET v_filtros        = " ";
      LET contador         = 0;

      SELECT cod_ramo
        INTO w_codramo
        FROM prdramo
       WHERE ramo_sis = 1;

      CREATE TEMP TABLE tmp_primaje
               (cod_sucursal    CHAR(3),
                cod_ramo        CHAR(3),
                cod_subramo     CHAR(3),
                cod_grupo       CHAR(5),
                prima_suscrita  DECIMAl(16,2),
                total_unidades  SMALLINT,
                cant_facturas   SMALLINT,
                seleccionado    SMALLINT DEFAULT 1,
                PRIMARY KEY (cod_ramo,cod_subramo,cod_grupo)) WITH NO LOG;

      CREATE INDEX i1_tmp_primaje ON tmp_primaje(cod_sucursal);
      CREATE INDEX i2_tmp_primaje ON tmp_primaje(cod_subramo);
      CREATE INDEX i3_tmp_primaje ON tmp_primaje(cod_grupo);
	  CREATE INDEX i4_tmp_primaje ON tmp_primaje(cod_subramo,cod_grupo);


      CREATE TEMP TABLE tmp_cantpoli
               (no_documento    CHAR(20),
                cod_sucursal    CHAR(3),
                cod_ramo        CHAR(3),
                cod_subramo     CHAR(3),
                cod_grupo       CHAR(5),
                cant_polizas    SMALLINT,
                seleccionado    SMALLINT DEFAULT 1,
                PRIMARY KEY (no_documento,cod_sucursal,cod_ramo,cod_subramo,cod_grupo)) WITH NO LOG;

      CREATE INDEX i1_tmp_cantpoli ON tmp_cantpoli(cod_sucursal);
      CREATE INDEX i2_tmp_cantpoli ON tmp_cantpoli(cod_subramo);
      CREATE INDEX i3_tmp_cantpoli ON tmp_cantpoli(cod_grupo);


      SET ISOLATION TO DIRTY READ;
       FOREACH WITH HOLD
         	SELECT cod_sucursal,
         		   no_poliza,
         		   no_endoso,
         		   cod_endomov,
         		   prima_suscrita
              INTO v_codsucursal,
              	   v_nopoliza,
              	   v_noendoso,
              	   v_codmov,
              	   v_prima_suscrita
              FROM endedmae
             WHERE periodo >= a_periodo_desde  
               AND periodo <= a_periodo_hasta 
               AND actualizado = 1

            SELECT x.no_documento,
            	   x.cod_ramo,
            	   x.cod_subramo,
            	   x.cod_grupo,
            	   x.periodo
              INTO v_nodocumento,
              	   v_cod_ramo,
              	   v_cod_subramo,
              	   v_cod_grupo,
              	   v_periodo
              FROM emipomae x
             WHERE x.no_poliza    = v_nopoliza
               AND x.cod_ramo     = '002'
			   AND actualizado    = 1;

		   IF v_cod_ramo IS NULL THEN
              CONTINUE FOREACH;
           END IF;

           SELECT tipo_mov
             INTO v_tipo_mov
             FROM endtimov
            WHERE cod_endomov = v_codmov; 

		   FOREACH
       		  SELECT no_poliza,
       		  		 no_endoso
                INTO v_nopolizas,
                	 v_noendosos
                FROM endeduni
               WHERE no_poliza = v_nopoliza
                 AND no_endoso = v_noendoso
	
              IF v_tipo_mov = 4 OR	  --incl.
			     v_tipo_mov = 11 OR	  --poliza orig.
			     v_tipo_mov = 3 THEN  --rehab.
			     LET v_total_unidades = v_total_unidades + 1;
			  END IF;
			  IF v_tipo_mov = 5 OR	   --eliminacion	
			     v_tipo_mov = 2 OR	   --cancelacion
			     v_tipo_mov = 20 THEN  --cancelacion manual
			     LET v_total_unidades = v_total_unidades - 1;
			  END IF;
		   END FOREACH;

           IF v_total_unidades IS NULL THEN
              LET v_total_unidades = 0;
           END IF;

            BEGIN
              ON EXCEPTION IN (-239)
                  UPDATE tmp_primaje
                     SET prima_suscrita = prima_suscrita + v_prima_suscrita,
                         total_unidades = total_unidades + v_total_unidades,
                         cant_facturas  = cant_facturas  + 1
                   WHERE cod_ramo       = v_cod_ramo
                     AND cod_subramo    = v_cod_subramo
                     AND cod_grupo      = v_cod_grupo;
              END EXCEPTION

              INSERT INTO tmp_primaje
              VALUES(v_codsucursal,
              		 v_cod_ramo,
		             v_cod_subramo,
        		     v_cod_grupo,
              		 v_prima_suscrita,
		             v_total_unidades,
		             1,
		             1);
            END;
            BEGIN
				ON EXCEPTION IN (-239)
				 -- No carga nada
				END EXCEPTION

				INSERT INTO tmp_cantpoli
				VALUES(v_nodocumento,
				       v_codsucursal,
				       v_cod_ramo,
				       v_cod_subramo,
				       v_cod_grupo,
				       1,
				       1);
            END

	    LET v_total_unidades = 0;

       END FOREACH

	  --FILTROS
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codsubramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_codsubramo);
         LET _tipo = sp_sis04(a_codsubramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_primaje
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);

            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;

      END IF;   

   RETURN v_filtros;
  END
END PROCEDURE;
