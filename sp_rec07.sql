DROP procedure sp_rec07;
CREATE procedure "informix".sp_rec07(a_cod_compania CHAR(3),a_periodo_desde CHAR(07),a_periodo_hasta CHAR(07))
     RETURNING CHAR(50),CHAR(18),CHAR(20),CHAR(50),DECIMAL(16,2),CHAR(7),CHAR(7);
--------------------------------------------
---    LISTADO DE SINIESTROS POR ROBO    ---
---           PARA AUTO
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_rec07
--------------------------------------------

 BEGIN
      DEFINE v_numrecla         CHAR(18);
      DEFINE v_nodocumento      CHAR(20);
      DEFINE v_nopoliza         CHAR(10);
      DEFINE v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_contratante      CHAR(10);
      DEFINE v_descr_cia        CHAR(50);
      DEFINE v_desc_cliente     CHAR(50);


    LET v_descr_cia    = NULL;
    LET v_numrecla     = NULL;
    LET v_contratante  = NULL;
    LET v_desc_cliente = NULL;
    LET v_suma_asegurada = 0;


    LET v_descr_cia = sp_sis01(a_cod_compania);
    FOREACH

       SELECT no_poliza,numrecla,suma_asegurada
              INTO v_nopoliza,v_numrecla,v_suma_asegurada
              FROM recrcmae
             WHERE cod_compania = a_cod_compania 
               AND (periodo BETWEEN a_periodo_desde AND a_periodo_hasta)
               AND cod_evento IN (SELECT cod_evento FROM recevent
                                          WHERE tipo_evento = "02")
            ORDER BY numrecla

       SELECT no_documento,cod_contratante
              INTO v_nodocumento,v_contratante
              FROM emipomae
             WHERE no_poliza = v_nopoliza;

       SELECT nombre
              INTO v_desc_cliente
              FROM cliclien
             WHERE cod_compania = a_cod_compania
               AND cod_cliente = v_contratante;

       RETURN v_descr_cia,v_numrecla,v_nodocumento,v_desc_cliente,
              v_suma_asegurada,a_periodo_desde,a_periodo_hasta
              WITH RESUME;

      END FOREACH
   END
END PROCEDURE;
