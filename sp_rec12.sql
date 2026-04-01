--DROP procedure sp_rec12;
CREATE PROCEDURE "informix".sp_rec12(a_cia CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*")
RETURNING CHAR(50),CHAR(3),CHAR(50),CHAR(3),CHAR(50),DECIMAL(16,2),CHAR(255);

---------------------------------------------
---ANALISIS DE RECLAMOS POR SUBRAMO/GRUPO ---
---           SINIESTROS PAGADOS          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - dw_rec12
---------------------------------------------
BEGIN

    DEFINE v_nopoliza                       CHAR(10);
    DEFINE v_cod_ramo,v_cod_subramo         CHAR(3);
    DEFINE v_cod_grupo                      CHAR(5);
    DEFINE v_pagado_total                   DECIMAL(16,2);
    DEFINE v_descr_cia                      CHAR(50);
    DEFINE v_desc_ramo,v_desc_grupo,v_desc_subramo  CHAR(50);
    DEFINE v_sucursal                       CHAR(3);
    DEFINE v_filtros                        CHAR(255);


    LET v_sucursal = "*";
    LET v_filtros = sp_rec01(a_cia,a_agencia,a_periodo1,a_periodo2,
                    a_codsucursal,a_codgrupo,a_codramo,"*",a_codsubramo);

    LET v_descr_cia      = NULL;
    LET v_cod_grupo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_cod_subramo    = NULL;
    LET v_desc_subramo   = NULL;
    LET v_pagado_total   = 0;

    LET v_descr_cia = sp_sis01(a_cia);

    FOREACH WITH HOLD

       SELECT cod_ramo,cod_subramo,SUM(pagado_total)
              INTO v_cod_ramo,v_cod_subramo,v_pagado_total
              FROM tmp_sinis
             WHERE seleccionado = 1
              GROUP BY cod_ramo,cod_subramo
             HAVING SUM(pagado_total) <> 0

       SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;

       SELECT nombre
              INTO v_desc_subramo
              FROM prdsubra
             WHERE cod_ramo    = v_cod_ramo
               AND cod_subramo = v_cod_subramo;

      RETURN v_descr_cia,v_cod_ramo,v_desc_ramo,v_cod_subramo,
             v_desc_subramo,v_pagado_total,v_filtros WITH RESUME;

    LET v_pagado_total   = 0;

      END FOREACH
    DROP TABLE tmp_sinis;
 END
END PROCEDURE
