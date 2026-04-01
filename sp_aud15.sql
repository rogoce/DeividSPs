-- POLIZAS VIGENTES POR RAMO
--
-- Creado    : 03/03/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

   DROP procedure sp_aud15;

   CREATE procedure "informix".sp_aud15(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE, a_codramo char(255) default "*")
   RETURNING CHAR(20),
             CHAR(50),
             DECIMAL(16,2),
             DECIMAL(16,2);


    DEFINE v_cod_ramo,v_cod_sucursal  			 CHAR(3);
    DEFINE v_saber					  			 CHAR(2);
    DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
    DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
    DEFINE v_asegurado                			 CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente CHAR(50);
    DEFINE v_desc_grupo               			 CHAR(40);
    DEFINE no_documento               			 CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   	 DATE;
    DEFINE v_cant_polizas             			 INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE _tipo              					 CHAR(1);
	define _no_poliza							 char(10);
	define _porc_comision						 dec(16,2);

    DEFINE v_filtros          					 CHAR(255);

    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET no_documento     = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo            = NULL;

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    FOREACH
       SELECT y.no_documento,
              y.cod_ramo,
              y.cod_contratante,
              y.vigencia_inic,
              y.vigencia_final,
              y.cod_grupo,
              y.suma_asegurada,
              y.prima_suscrita,
			  y.no_poliza
         INTO no_documento,
              v_cod_ramo,
              v_contratante,
              v_vigencia_inic,
              v_vigencia_final,
              v_cod_grupo,
              v_suma_asegurada,
              v_prima_suscrita,
			  _no_poliza
         FROM temp_perfil y
        WHERE y.seleccionado = 1
     ORDER BY y.no_documento

       SELECT nombre
         INTO v_asegurado
         FROM cliclien
        WHERE cod_cliente = v_contratante;

		foreach
		 select porc_comis_agt
		   into _porc_comision
		   from emipoagt
		  where no_poliza = _no_poliza
			exit foreach;
		end foreach
		 
       RETURN no_documento,
              v_asegurado,
              v_prima_suscrita,
			  _porc_comision
              WITH RESUME;

    END FOREACH

DROP TABLE temp_perfil;

END PROCEDURE;
