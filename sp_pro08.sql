   DROP procedure sp_pro08;
   CREATE procedure "informix".sp_pro08(a_compania CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_periodo1 CHAR(7),a_periodo2 CHAR(7))
   RETURNING DEC(16,2),DEC(16,2),INT,DEC(16,2),CHAR(03),
             CHAR(45),CHAR(7),CHAR(7),CHAR(255),CHAR(45);

----------------------------------------------
---  RANGOS DE SUMA ASEGURADA - TRANSPORTE ---
---            POLIZAS SUSCRITA            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro08
----------------------------------------------

BEGIN

  DEFINE v_codramo,v_codsucursal,v_cod_tipo     CHAR(3);
  DEFINE v_desc_ramo,descr_cia                  CHAR(45);
  DEFINE v_cant_polizas                         SMALLINT;
  DEFINE v_prima_suscrita, v_rango_inicial,v_rango_final,
         v_suma_asegurada,rango_max,rango_min  DECIMAL(16,2);
  DEFINE no_documento               CHAR(10);
  DEFINE v_filtros                  CHAR(255);
  DEFINE _tipo                      CHAR(01);

     CREATE TEMP TABLE temp_polizasus
           (cod_sucursal       CHAR(3),
            cod_ramo           CHAR(3),
            rango_inicial      DEC(16,2),
            rango_final        DEC(16,2),
            prima_suscrita     DEC(16,2),
            seleccionado       SMALLINT DEFAULT 1) WITH NO LOG;

       CREATE INDEX i_tsus1 ON temp_polizasus(cod_ramo,rango_inicial);
       CREATE INDEX i_tsus2 ON temp_polizasus(cod_ramo);
       CREATE INDEX i_tsus3 ON temp_polizasus(cod_sucursal);

     CREATE TEMP TABLE tmp_cantpoli
           (no_documento       CHAR(20),
            cod_sucursal       CHAR(3),
            cod_ramo           CHAR(3),
            rango_inicial      DEC(16,2),
            rango_final        DEC(16,2),
            cant_polizas       INTEGER,
            seleccionado       SMALLINT DEFAULT 1, 
            PRIMARY KEY (no_documento,cod_sucursal,cod_ramo,rango_inicial)) WITH NO LOG;
 
	 CREATE INDEX i_tcant1 ON tmp_cantpoli(cod_ramo,rango_inicial);
     CREATE INDEX i_tcant2 ON tmp_cantpoli(cod_ramo);
     CREATE INDEX i_tcant3 ON tmp_cantpoli(cod_sucursal);



  LET v_codramo        = NULL;
  LET v_codsucursal    = NULL;
  LET v_desc_ramo      = NULL;
  LET v_rango_inicial  = 0;
  LET v_rango_final    = 0;
  LET descr_cia        = NULL;
  LET v_prima_suscrita = 0;
  LET v_suma_asegurada = 0;
  LET v_cant_polizas   = 0;
  LET rango_max        = 0;

  LET descr_cia = sp_sis01(a_compania);

  SET ISOLATION TO DIRTY READ;

  {SELECT cod_tipoprod
    INTO v_cod_tipo
    FROM emitipro
   WHERE tipo_produccion = 2;}

  FOREACH
     SELECT emipomae.cod_sucursal,
     		emipomae.cod_ramo,
     		emipomae.no_documento,
            endedmae.prima_suscrita,
            emipomae.suma_asegurada
       INTO v_codsucursal,
    	    v_codramo,
    	    no_documento,
    	    v_prima_suscrita,
            v_suma_asegurada
       FROM emipomae,endedmae
      WHERE emipomae.no_poliza = endedmae.no_poliza
        AND (endedmae.periodo BETWEEN a_periodo1 AND a_periodo2)
        --AND emipomae.cod_tipoprod = v_cod_tipo
        AND endedmae.actualizado  = 1
           
       SELECT parinfra.rango1,parinfra.rango2
         INTO v_rango_inicial,v_rango_final
         FROM parinfra
        WHERE parinfra.cod_ramo = v_codramo
          AND (v_suma_asegurada >= parinfra.rango1  
          AND  v_suma_asegurada <= parinfra.rango2);
			    
       IF v_rango_inicial IS NULL THEN
	      CONTINUE FOREACH;
	   END IF
	       
       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_polizasus
                    SET prima_suscrita = prima_suscrita + v_prima_suscrita
                  WHERE cod_ramo       = v_codramo
                    AND rango_inicial  = v_rango_inicial
                    AND rango_final    = v_rango_final;

          END EXCEPTION

          INSERT INTO temp_polizasus
                  VALUES(v_codsucursal,
                         v_codramo,
                         v_rango_inicial,
                         v_rango_final,
                         v_prima_suscrita,
                         1);

       END;
	   BEGIN
               ON EXCEPTION IN (-239)
                 -- No carga nada

               END EXCEPTION

               INSERT INTO tmp_cantpoli
                     VALUES(no_documento,
                            v_codsucursal,
                            v_codramo,
                            v_rango_inicial,
					        v_rango_final, 
                            1,
                            1);
	   END;

     END FOREACH
	
      -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_polizasus
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
 
            UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);

	     ELSE
            UPDATE temp_polizasus
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);

			UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
 
 
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_polizasus
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);

		  	UPDATE tmp_cantpoli
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);

         ELSE
            UPDATE temp_polizasus
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

      FOREACH
           SELECT cod_ramo,
           		  rango_inicial,
           		  rango_final,
           		  SUM(prima_suscrita)
             INTO v_codramo,
             	  v_rango_inicial,
             	  v_rango_final,
                  v_prima_suscrita
             FROM temp_polizasus
            WHERE seleccionado = 1
         GROUP BY cod_ramo,rango_inicial,rango_final
         ORDER BY cod_ramo,rango_inicial

		   SELECT SUM(cant_polizas)
		     INTO v_cant_polizas
		     FROM tmp_cantpoli
		    WHERE cod_ramo      = v_codramo
		      AND rango_inicial = v_rango_inicial
		      AND seleccionado  = 1;

		   SELECT MAX(rango1)
             INTO rango_max
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

            IF rango_max = v_rango_inicial THEN
               LET v_rango_final = -1;
            END IF;

		   SELECT MIN(rango1)
             INTO rango_min
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

            IF rango_min = v_rango_inicial THEN
               LET v_rango_inicial = -1;
            END IF;

            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_codramo;

            RETURN v_rango_inicial,v_rango_final,v_cant_polizas,
                   v_prima_suscrita,v_codramo,v_desc_ramo,
                   a_periodo1,a_periodo2,v_filtros,descr_cia WITH RESUME;
         END FOREACH
DROP TABLE temp_polizasus;
   END
END PROCEDURE;
