DROP procedure sp_rec06b;
CREATE procedure "informix".sp_rec06b(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*",a_codtipoveh CHAR(255) DEFAULT "*")
RETURNING CHAR(50),CHAR(5),CHAR(50),CHAR(3),CHAR(50),CHAR(3),CHAR(50),
          CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),INT,
          INT,INT,CHAR(255),DECIMAL(16,2);

---------------------------------------------
---ANALISIS DE RECLAMOS POR GRUPO/SUBRAMO ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_rec06b
---------------------------------------------
BEGIN

    DEFINE v_nopoliza,v_noreclamo           CHAR(10);
    DEFINE v_cod_ramo,v_cod_subramo,v_cod_tipoveh  CHAR(3);
    DEFINE v_cod_grupo                      CHAR(5);
    DEFINE v_rec_abierto,v_rec_cerrado INT;
	DEFINE no_trans,v_tranreclamo INT;
    DEFINE v_incurrido_bruto,v_incurrido_neto,v_incurrido_abierto DECIMAL(16,2);
    DEFINE v_descr_cia                      CHAR(50);
    DEFINE v_desc_grupo,v_desc_ramo,v_desc_subramo,v_desc_tipveh  CHAR(50);
    DEFINE v_filtros                        CHAR(255);
    DEFINE a_codagente                      CHAR(255);

    LET a_codagente = "*";
    LET v_descr_cia = sp_sis01(a_compania);   
    CALL sp_rec06(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,
                  a_codgrupo,a_codramo,a_codagente,a_codsubramo,a_codtipoveh)
                  RETURNING v_filtros;

    LET v_cod_grupo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_cod_subramo    = NULL;
    LET v_desc_subramo    = NULL;
    LET v_incurrido_bruto = 0;
    LET v_incurrido_neto  = 0;
    LET v_rec_abierto     = 0;
    LET v_rec_cerrado     = 0;
    LET v_tranreclamo     = 0;

 FOREACH
       SELECT cod_ramo,
       		  cod_subramo,
       		  cod_grupo,
       		  cod_tipoveh,
              SUM(incurrido_bruto),
              SUM(incurrido_neto),
              SUM(rec_abierto),
              SUM(rec_cerrado),
              SUM(no_tranreclamo),
              SUM(incurrido_abierto)
         INTO v_cod_ramo,
         	  v_cod_subramo,
         	  v_cod_grupo,
         	  v_cod_tipoveh,
              v_incurrido_bruto,
              v_incurrido_neto,
              v_rec_abierto,
              v_rec_cerrado,
              v_tranreclamo,
              v_incurrido_abierto
         FROM temp_reclamo
        WHERE seleccionado = 1
     GROUP BY cod_ramo,cod_grupo,cod_subramo,cod_tipoveh
     ORDER BY cod_ramo,cod_grupo,cod_subramo,cod_tipoveh

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = v_cod_ramo
          AND cod_subramo = v_cod_subramo;

       SELECT nombre
         INTO v_desc_grupo
         FROM cligrupo
        WHERE cod_grupo = v_cod_grupo;

       SELECT nombre
         INTO v_desc_tipveh
         FROM emitiveh
        WHERE cod_tipoveh = v_cod_tipoveh;

      RETURN v_descr_cia,v_cod_grupo,v_desc_grupo,v_cod_ramo,v_desc_ramo,
             v_cod_subramo,v_desc_subramo,v_cod_tipoveh,v_desc_tipveh,
             v_incurrido_bruto,v_incurrido_neto,v_rec_abierto,v_rec_cerrado,
             v_tranreclamo,v_filtros,v_incurrido_abierto WITH RESUME;

    LET v_cod_grupo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_cod_subramo    = NULL;
    LET v_desc_subramo   = NULL;
    LET v_cod_tipoveh    = NULL;
    LET v_desc_tipveh    = NULL;
    LET v_incurrido_bruto = 0;
    LET v_incurrido_neto  = 0;
    LET v_incurrido_abierto = 0;
    LET v_rec_abierto     = 0;
    LET v_rec_cerrado     = 0;
    LET v_tranreclamo     = 0;

 END FOREACH
    DROP TABLE temp_reclamo;
    DROP TABLE tmp_sinis;
END
END PROCEDURE
