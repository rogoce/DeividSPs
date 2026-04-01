DROP procedure sp_rec13a;
CREATE procedure "informix".sp_rec13a(a_compania CHAR(3),a_agencia CHAR(3),periodo_desde CHAR(7),periodo_hasta CHAR(7),a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*")
RETURNING CHAR(50),DECIMAL(16,2),CHAR(2),CHAR(4),CHAR(255),CHAR(3),CHAR(50);

-----------------------------------------------
--ANALISIS DE RECLAMOS DE AUTOMOVIL POR MES -
---           SINIESTROS PAGADOS          ---
---  Yinia M. Zamora - septiembre 2000 - YMZM
---  Ref. Power Builder - d_sp_rec13a
-----------------------------------------------
BEGIN

    DEFINE v_cod_ramo                       CHAR(3);
    DEFINE v_cod_grupo                      CHAR(5);
    DEFINE v_pagado_total                   DECIMAL(16,2);
    DEFINE v_descr_cia                      CHAR(50);
    DEFINE v_desc_ramo                      CHAR(50);
    DEFINE v_periodo                        CHAR(7);
    DEFINE v_filtros                        CHAR(255);
    DEFINE periodo_mes                      CHAR(02);
    DEFINE ano                              CHAR(04);

    LET v_filtros = sp_rec13(a_compania,a_agencia,periodo_desde,periodo_hasta,a_codsucursal,a_codgrupo,a_codramo);

    LET v_descr_cia      = NULL;
    LET v_cod_ramo       = NULL;
    LET v_desc_ramo      = NULL;
    LET v_pagado_total   = 0;

    LET v_descr_cia = sp_sis01(a_compania);
    CREATE TEMP TABLE tmp_reclamos
               (cod_ramo        CHAR(03),
                periodo         CHAR(7),
                pagado_total    DECIMAL(16,2),
                PRIMARY KEY(cod_ramo,periodo)) WITH NO LOG;

    CREATE INDEX ie01_tmp_reclamos ON tmp_reclamos(cod_ramo);

    FOREACH WITH HOLD
       SELECT cod_ramo,
       		  cod_grupo,
       		  periodo,
       		  SUM(pagado_total)
         INTO v_cod_ramo,
         	  v_cod_grupo,
         	  v_periodo,
         	  v_pagado_total
         FROM tmp_sinis1
        WHERE seleccionado = 1
     GROUP BY cod_ramo,cod_grupo,periodo
     ORDER BY cod_ramo,cod_grupo,periodo

         BEGIN
               ON EXCEPTION IN(-239)
                  UPDATE tmp_reclamos
                         SET pagado_total   = pagado_total + v_pagado_total
                       WHERE cod_ramo       = v_cod_ramo
                         AND periodo        = v_periodo;

              END EXCEPTION
              INSERT INTO tmp_reclamos
                      VALUES(v_cod_ramo,
                             v_periodo,
                             v_pagado_total);

         END
    END FOREACH
    FOREACH WITH HOLD
       SELECT cod_ramo,
       		  periodo,
       		  pagado_total
         INTO v_cod_ramo,
         	  v_periodo,
         	  v_pagado_total
         FROM tmp_reclamos
     ORDER BY cod_ramo,periodo

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_cod_ramo;

       LET periodo_mes = v_periodo[6,7];
       LET ano         = v_periodo[1,4];

      RETURN v_descr_cia,v_pagado_total,periodo_mes,ano,v_filtros,v_cod_ramo,v_desc_ramo WITH RESUME;

      LET v_pagado_total   = 0;

    END FOREACH
    DROP TABLE tmp_sinis1;
    DROP TABLE tmp_reclamos;
END
END PROCEDURE
