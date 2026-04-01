--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------

DROP procedure sp_pro02;
CREATE procedure "informix".sp_pro02(a_compania CHAR(3),a_agencia CHAR(03) DEFAULT "*",a_periodo DATE,a_codsucursal  CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")
   RETURNING DEC(16,2),DEC(16,2),SMALLINT,DEC(16,2),
             DEC(16,2),SMALLINT,SMALLINT,CHAR(03),CHAR(45),
             DATE,CHAR(45),CHAR(255);


 BEGIN

    DEFINE v_codramo,v_codsucursal      CHAR(3);
    DEFINE v_desc_ramo,descr_cia        CHAR(45);
    DEFINE v_cant_polizas,v_cant_coasegur1,v_cant_coasegur2,mes SMALLINT;
    DEFINE v_prima_suscrita,v_prima_retenida,
           v_rango_inicial,v_rango_final,v_suma_asegurada  DECIMAL(16,2);
    DEFINE codigo1          CHAR(3);
    DEFINE v_fecha_cancel   DATE;
    DEFINE no_poliza        CHAR(10);
    DEFINE v_filtros        CHAR(255);
    DEFINE _tipo            CHAR(1);
    DEFINE rango_max        INTEGER;
    DEFINE mes1             CHAR(02);
	DEFINE ano              CHAR(04);
    DEFINE periodo1         CHAR(07);
	DEFINE v_cod_tipoprod   CHAR(03);
	DEFINE v_cod_cliente    CHAR(10);

       LET descr_cia = sp_sis01(a_compania);
       CREATE TEMP TABLE temp_civil
             (cod_sucursal     CHAR(03),
              cod_ramo         CHAR(03),
              rango_inicial    DECIMAL(16,2),
              rango_final      DECIMAL(16,2),
              cant_polizas     SMALLINT,
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              cant_coasegur1   SMALLINT,
              cant_coasegur2   SMALLINT,
              seleccionado     SMALLINT DEFAULT 1,
              PRIMARY KEY (cod_sucursal,cod_ramo,rango_inicial)) WITH NO LOG;

      CREATE INDEX iend1_temp_civil ON temp_civil(cod_sucursal);
      CREATE INDEX iend2_temp_civil ON temp_civil(cod_ramo);
      CREATE INDEX iend3_temp_civil ON temp_civil(cod_ramo,rango_inicial);

    LET v_codramo        = NULL;
    LET v_desc_ramo      = NULL;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET v_cant_polizas   = 0;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_suma_asegurada = 0;
    LET no_poliza        = NULL;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET mes 			 = MONTH(a_periodo);

  	IF mes <= 9 THEN
	   LET mes1[1,1] = '0';
	   LET mes1[2,2] = mes;
	ELSE
	   LET mes1 = mes;
	END IF

    LET ano = YEAR(a_periodo);
	LET periodo1[1,4] = ano;
	LET periodo1[5] = "-";
	LET periodo1[6,7] = mes1;

       SET ISOLATION TO DIRTY READ;
       FOREACH

       SELECT  a.no_poliza,a.prima_suscrita,a.prima_retenida,
               a.fecha_cancelacion,a.cod_ramo,a.cod_sucursal,
               a.suma_asegurada,a.cod_tipoprod
               INTO  no_poliza,v_prima_suscrita,v_prima_retenida,
                     v_fecha_cancel,v_codramo,v_codsucursal,
                     v_suma_asegurada,v_cod_tipoprod
                FROM emipomae a
               WHERE a.cod_compania  = a_compania
                 AND a.vigencia_final >= a_periodo
                 AND a.fecha_suscripcion <= a_periodo
                 AND (a.fecha_cancelacion > a_periodo OR
                      a.fecha_cancelacion IS NULL)
				 AND a.actualizado = 1
				 AND a.periodo <= periodo1

    
	   SELECT emitipro.cod_tipoprod
              INTO codigo1
              FROM emitipro,emipomae
             WHERE (emitipro.tipo_produccion = 2  OR
                    emitipro.tipo_produccion = 3) AND
					emitipro.cod_tipoprod = emipomae.cod_tipoprod AND
					emipomae.no_poliza = no_poliza;
 
	   SELECT parinfra.rango1, parinfra.rango2
              INTO v_rango_inicial,v_rango_final
              FROM parinfra
             WHERE parinfra.cod_ramo = v_codramo
               AND(v_suma_asegurada BETWEEN  parinfra.rango1  AND
                    parinfra.rango2);

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
       END IF;

       IF codigo1 IS NOT NULL THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                    SET cant_polizas   = cant_polizas + 1,
                        prima_suscrita = v_prima_suscrita + prima_suscrita,
                        prima_retenida = v_prima_retenida + prima_retenida,
                        cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                        cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2
                  WHERE cod_sucursal   = v_codsucursal
                    AND cod_ramo       = v_codramo
                    AND rango_inicial  = v_rango_inicial
                    AND rango_final    = v_rango_final;

          END EXCEPTION

          INSERT INTO temp_civil
                VALUES(v_codsucursal,
                       v_codramo,
                       v_rango_inicial,
                       v_rango_final,
                       1,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_cant_coasegur1,
                       v_cant_coasegur2,
                       1);

       END
       LET v_prima_suscrita   = 0;
       LET v_prima_retenida   = 0;

	  	END FOREACH

     -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_civil
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

            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      FOREACH
         SELECT x.cod_ramo,x.rango_inicial,x.rango_final,x.cant_polizas,
                x.prima_suscrita,x.prima_retenida,x.cant_coasegur1,
                x.cant_coasegur2
                INTO v_codramo,v_rango_inicial,v_rango_final,v_cant_polizas,
                     v_prima_suscrita,v_prima_retenida,v_cant_coasegur1,
                     v_cant_coasegur2
                FROM temp_civil x
              WHERE  x.seleccionado = 1
               ORDER BY x.cod_ramo,x.rango_inicial

         SELECT MAX(rango1)
             INTO rango_max
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

         IF rango_max = v_rango_inicial THEN
               LET v_rango_final = -1;
         END IF;

         SELECT prdramo.nombre
                INTO v_desc_ramo
                FROM prdramo
               WHERE prdramo.cod_ramo = v_codramo;

         RETURN v_rango_inicial,v_rango_final,v_cant_polizas,
                v_prima_suscrita,v_prima_retenida,v_cant_coasegur1,
                v_cant_coasegur2,v_codramo,v_desc_ramo,a_periodo,
                descr_cia,v_filtros WITH RESUME;
      END FOREACH

DROP TABLE temp_civil;
   END
END PROCEDURE;
