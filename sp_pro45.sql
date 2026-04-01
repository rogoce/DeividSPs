DROP procedure sp_pro45;
CREATE procedure "informix".sp_pro45(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*")

         RETURNING CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(9,2),
                   CHAR(50),CHAR(255);

--------------------------------------------
---  TOTALES DE COASEGURO ASUMIDO POR RAMO -
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro45
--------------------------------------------
BEGIN

  DEFINE s_nopoliza                       CHAR(10);
  DEFINE s_cia,s_codsucursal,s_codramo    CHAR(03);
  DEFINE v_descramo                       CHAR(45);
  DEFINE v_prima_suscrita                 DECIMAL(16,2);
  DEFINE v_coaseguro_asum                 DECIMAL(16,2);
  DEFINE v_porc_comi                      DECIMAL(5,2);
  DEFINE v_comision                       DECIMAL(9,2);
  DEFINE v_filtros                        CHAR(255);
  DEFINE _tipo                            CHAR(01);
  DEFINE v_descr_cia                      CHAR(50);
  DEFINE s_tipopro                        CHAR(03);
  DEFINE _estatus                         SMALLINT;
  	
  SET ISOLATION TO DIRTY READ;

  CREATE TEMP TABLE temp_coaseguro
           (cod_sucursal     CHAR(3),
            cod_ramo         CHAR(3),
            coaseguro_asum   DEC(16,2),
            comision         DEC(9,2),
            seleccionado     SMALLINT DEFAULT 1,
            PRIMARY KEY(cod_sucursal,cod_ramo)) WITH NO LOG;

  CREATE INDEX id1_temp_coaseguro ON temp_coaseguro(cod_sucursal);
  CREATE INDEX id2_temp_coaseguro ON temp_coaseguro(cod_ramo);

  LET s_tipopro        = NULL;
  LET v_descramo       = NULL;
  LET v_prima_suscrita = 0;
  LET v_porc_comi      = 0;

  LET v_descr_cia = sp_sis01(a_compania);

  SELECT emitipro.cod_tipoprod
    INTO s_tipopro
    FROM emitipro
   WHERE emitipro.tipo_produccion = 3;	--coaseguro minoritario

  FOREACH 
   SELECT endedmae.no_poliza,
          endedmae.cod_sucursal,
          endedmae.prima_neta
     INTO s_nopoliza,
          s_codsucursal,
          v_prima_suscrita
     FROM endedmae
    WHERE endedmae.actualizado = 1
      AND endedmae.periodo BETWEEN a_periodo1 AND a_periodo2

     SELECT cod_ramo,
	        estatus_poliza
       INTO s_codramo,
	        _estatus
       FROM emipomae
      WHERE emipomae.no_poliza    = s_nopoliza
        AND emipomae.cod_tipoprod = s_tipopro ;

    IF s_codramo IS NULL OR
       s_codramo = " "   THEN
      CONTINUE FOREACH;
    END IF;

    IF v_prima_suscrita = 0  OR
       v_prima_suscrita IS NULL THEN
       CONTINUE FOREACH;
    END IF

--    IF _estatus <> 1 THEN
--       CONTINUE FOREACH;
--    END IF

    LET v_comision       = 0;

    FOREACH
     SELECT porc_comis_agt
       INTO v_porc_comi
       FROM emipoagt
      WHERE no_poliza = s_nopoliza
        LET v_comision = v_comision + (v_prima_suscrita*v_porc_comi/100);
   END FOREACH

    BEGIN
        ON EXCEPTION IN(-239)
           UPDATE temp_coaseguro
                  SET coaseguro_asum = coaseguro_asum + v_prima_suscrita,
                      comision      = comision + v_comision
                WHERE cod_sucursal  = s_codsucursal
                  AND cod_ramo      = s_codramo;

        END EXCEPTION

        INSERT INTO temp_coaseguro
               VALUES(s_codsucursal,
                      s_codramo,
                      v_prima_suscrita,
                      v_comision,
                      1);
    END

  END FOREACH
       -- Procesos v_filtros
  LET v_filtros ="";
  IF a_codsucursal <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
     LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE temp_coaseguro
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_coaseguro
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
  END IF
  FOREACH
     SELECT a.cod_ramo,a.coaseguro_asum,a.comision
            INTO s_codramo,v_coaseguro_asum,v_comision
            FROM temp_coaseguro a
           WHERE a.seleccionado = 1
           ORDER BY a.cod_ramo

     SELECT prdramo.nombre
            INTO v_descramo
            FROM prdramo
           WHERE prdramo.cod_ramo = s_codramo;

     RETURN s_codramo,v_descramo,v_coaseguro_asum,v_comision,
            v_descr_cia,v_filtros  WITH RESUME;

  END FOREACH

DROP TABLE temp_coaseguro;

END

END PROCEDURE;
