 DROP procedure sp_pro12;
CREATE procedure "informix".sp_pro12(a_cia CHAR(3),a_agencia char(3),a_periodo1 CHAR(7))
         RETURNING CHAR(45),CHAR(3),CHAR(30),DEC(16,2),DEC(16,2),
                   DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),
                   DEC(16,2),DEC(10,2),DEC(10,2),DEC(10,2),
                   DEC(10,2),CHAR(7);

--------------------------------------------
---    INFORME DE CUMULOS POR UBICACION  ---
---       INCENDIO Y COMBINADO HOGAR     ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro12
--------------------------------------------

 BEGIN

    DEFINE v_nopoliza                  CHAR(10);
    DEFINE v_desc_ubica,v_descr_cia    CHAR(50);
    DEFINE mes,ano,v_tipo_contrato     SMALLINT;
    DEFINE fecha                       DATE;
    DEFINE v_prima_suscrita            DEC(16,2);
    DEFINE v_nounidad,v_cod_contrato   CHAR(5);
    DEFINE cant_poliza1,cant_retencion,cant_facultativo,cant_excedente
                                       INTEGER;
    DEFINE v_cod_ubica,y_cod_ubica,y_cod_ramo      CHAR(3);
    DEFINE v_suma_incendio,v_suma_retencion,v_prima_retencion,
           v_suma_facultativo,v_prima_incendio,v_prima_facult,
           v_suma_excedente,v_prima_excedente,v_suma_retenida      DEC(16,2);
    DEFINE v_porc_suma,v_porc_prima                                DEC(9,6);
    DEFINE prom_incendio,prom_retencion,prom_facultativo,prom_excedente
           DEC(10,2);

    LET v_nopoliza       = NULL;
    LET v_desc_ubica     = NULL;
    LET v_descr_cia      = NULL;
    LET mes              = 0;
    LET ano              = 0;
    LET fecha            = NULL;
    LET v_prima_suscrita = 0;
    LET v_nounidad       = NULL;
    LET v_cod_ubica      = NULL;

    LET v_descr_cia = sp_sis01(a_cia);
    CREATE TEMP TABLE tmp_cumulos
                (cod_ubica        CHAR(3),
                 suma_incendio    DEC(16,2),
                 suma_retencion   DEC(16,2),
                 suma_facultativo DEC(16,2),
                 suma_excedente   DEC(16,2),
                 prima_incendio   DEC(16,2),
                 prima_retencion  DEC(16,2),
                 prima_facult     DEC(16,2),
                 prima_excedente  DEC(16,2),
                 PRIMARY KEY(cod_ubica)) WITH NO LOG;

    CREATE TEMP TABLE tmp_cantpoliza
                (cod_ubica        CHAR(3),
                 no_poliza        CHAR(10)) WITH NO LOG;

    CREATE INDEX i2_tmp_cantpoliza ON tmp_cantpoliza(cod_ubica);

    CREATE TEMP TABLE tmp_cantpolubica
                (cod_ubica        CHAR(3),
                 no_poliza        CHAR(10),
                 tipo_contrato    SMALLINT ) WITH NO LOG;

    CREATE INDEX i3_cantpolubic ON tmp_cantpolubica(cod_ubica);

       LET mes = a_periodo1[6,7];
       LET ano = a_periodo1[1,4];

       IF mes = 12 THEN
          LET ano = ano + 1;
       ELSE
          LET mes = mes + 1;
       END IF;
       LET fecha = (MDY(mes,1,ano) -1);


    SET ISOLATION TO DIRTY READ;
    SELECT cod_ramo
           INTO y_cod_ramo
           FROM prdramo
          WHERE ramo_sis = 2;

    FOREACH
       SELECT a.no_poliza,a.prima_suscrita
              INTO v_nopoliza,v_prima_suscrita
              FROM emipomae a
             WHERE a.cod_compania = a_cia
               AND a.cod_sucursal = a_agencia
               AND a.vigencia_final >= fecha
               AND (a.fecha_cancelacion IS NULL OR
                    a.fecha_cancelacion > fecha)
               AND a.cod_ramo = y_cod_ramo

       FOREACH
          SELECT b.no_unidad
                 INTO v_nounidad
                 FROM emipouni b
                WHERE b.no_poliza = v_nopoliza

          FOREACH
             SELECT c.cod_ubica,c.suma_incendio,c.prima_incendio
                    INTO v_cod_ubica,v_suma_incendio,v_prima_incendio
                    FROM emicupol c
                   WHERE c.no_poliza = v_nopoliza
                     AND c.no_unidad = v_nounidad

             FOREACH

             --Suma Asegurada Retencion
                SELECT d.porc_partic_suma,d.porc_partic_prima,d.cod_contrato
                       INTO v_porc_suma,v_porc_prima,v_cod_contrato
                       FROM emifacon d
                      WHERE d.no_poliza = v_nopoliza
                        AND d.no_unidad = v_nounidad
                        AND d.cod_cober_reas = "01"

                LET v_suma_incendio = 0;
                LET v_suma_retencion = 0;
                LET v_suma_facultativo = 0;
                LET v_suma_excedente   = 0;
                LET v_prima_incendio  = 0;
                LET v_prima_retencion = 0;
                LET v_prima_facult     = 0;
                LET v_prima_excedente  = 0;

                SELECT tipo_contrato
                       INTO v_tipo_contrato
                       FROM reacomae
                      WHERE cod_contrato = v_cod_contrato;

                  -- Retencion
                  IF v_tipo_contrato = 1 THEN
                      LET v_suma_retencion = v_suma_incendio*v_porc_suma;
                      LET v_prima_retencion = v_suma_incendio*v_porc_prima;
                  END IF;

                  --Suma Asegurada Facultativo
                  IF v_tipo_contrato = 3 THEN
                      LET v_suma_facultativo = v_suma_incendio*v_porc_suma;
                      LET v_prima_facult = v_suma_incendio*v_porc_prima;
                  END IF;

                  -- Excedente
                  IF v_tipo_contrato <>  1 THEN
                     IF v_tipo_contrato <> 3 THEN
                      LET v_suma_excedente  = v_suma_incendio*v_porc_suma;
                      LET v_prima_excedente = v_suma_incendio*v_porc_prima;
                     END IF;
                  END IF;

                BEGIN
                  ON EXCEPTION IN (-239)
                    UPDATE tmp_cumulo
                      SET suma_incendio = suma_incendio + v_suma_incendio,
                          prima_incendio = prima_incendio + v_prima_incendio,
                          suma_retencion  = suma_retencion + v_suma_retencion,
                          prima_retencion = prima_retencion + v_prima_retencion,
                          suma_facultativo = suma_facultativo +
                                              v_suma_facultativo,
                          prima_facult     = prima_facult + v_prima_facult,
                          suma_excedente   = suma_excedente + v_suma_excedente,
                          prima_excedente  = prima_excedente +
                                             v_prima_excedente
                     WHERE cod_ubica = v_cod_ubica;
                  END EXCEPTION

                  INSERT INTO tmp_cumulos
                        VALUES(v_cod_ubica,
                               v_suma_incendio,
                               v_suma_retencion,
                               v_suma_facultativo,
                               v_suma_excedente,
                               v_prima_incendio,
                               v_prima_retencion,
                               v_prima_facult,
                               v_prima_excedente);

               END;
               BEGIN
                  ON EXCEPTION IN (-239)
                   --
                  END EXCEPTION
                  INSERT INTO tmp_cantpoliza
                         VALUES(v_cod_ubica,
                                v_nopoliza);
               END;
               BEGIN
                  ON EXCEPTION IN (-239)
                   --
                  END EXCEPTION
                  INSERT INTO tmp_cantpolubica
                         VALUES(v_cod_ubica,
                                v_nopoliza,
                                v_tipo_contrato);
               END;
             END FOREACH
          END FOREACH
       END FOREACH;
    END FOREACH;
    FOREACH WITH HOLD

       SELECT x.cod_ubica,SUM(x.suma_incendio)/1000,
              SUM(x.suma_retencion)/1000,
              SUM(x.suma_facultativo)/1000,SUM(x.suma_excedente)/1000,
              SUM(x.prima_incendio)/1000,SUM(x.prima_retencion)/1000,
              SUM(x.prima_facult)/1000,SUM(x.prima_excedente)/1000
              INTO v_cod_ubica,v_suma_incendio,v_suma_retenida,
                   v_suma_facultativo,v_suma_excedente,v_prima_incendio,
                   v_prima_retencion,v_prima_facult,v_prima_excedente
              FROM tmp_cumulos x
             GROUP BY x.cod_ubica
             ORDER BY x.cod_ubica

        SELECT cod_ubica,COUNT(*)
              INTO y_cod_ubica,cant_poliza1
              FROM tmp_cantpoliza
             WHERE cod_ubica = v_cod_ubica
             GROUP BY cod_ubica;

       SELECT cod_ubica,COUNT(*)
              INTO y_cod_ubica,cant_retencion
              FROM tmp_cantpolubica
             WHERE cod_ubica = v_cod_ubica
               AND tipo_contrato = 1
             GROUP BY cod_ubica;

       SELECT cod_ubica,COUNT(*)
              INTO y_cod_ubica,cant_facultativo
              FROM tmp_cantpolubica
             WHERE cod_ubica = v_cod_ubica
               AND tipo_contrato = 3
             GROUP BY cod_ubica;

       SELECT cod_ubica,COUNT(*)
              INTO y_cod_ubica,cant_excedente
              FROM tmp_cantpolubica;

       LET prom_incendio   = v_suma_incendio/cant_poliza1;
       LET prom_retencion   = v_suma_retenida/cant_retencion;
       LET prom_facultativo = v_suma_facultativo/cant_facultativo;
       LET prom_excedente   = v_suma_excedente/cant_excedente;

       SELECT z.nombre
              INTO v_desc_ubica
              FROM emiubica z
             WHERE z.cod_ubica = v_cod_ubica;

         RETURN v_descr_cia,v_cod_ubica,v_desc_ubica,v_suma_incendio,
                v_suma_retenida,v_suma_facultativo,v_suma_excedente,
                v_prima_incendio,v_prima_retencion,v_prima_facult,
                v_prima_excedente,prom_incendio,prom_retencion,
                prom_facultativo,prom_excedente,a_periodo1
                WITH RESUME;

    END FOREACH
    DROP TABLE tmp_cumulos;
    DROP TABLE tmp_cantpoliza;
    DROP TABLE tmp_cantpolubica;
   END
END PROCEDURE;
