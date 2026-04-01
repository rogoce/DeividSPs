--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro03
--------------------------------------------

--DROP procedure sp_pro981i;
CREATE procedure "informix".sp_pro981i(a_cia CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7), a_cod_ramo char(3))

RETURNING CHAR(255);

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal,v_cod_tipoprod  CHAR(3);
    DEFINE _no_poliza,_no_factura     CHAR(10);
    DEFINE _no_documento              CHAR(20);
    DEFINE v_cod_grupo, _no_endoso    CHAR(05);
    DEFINE v_contratante              CHAR(10);
    DEFINE v_prima_suscrita,v_prima_retenida,v_suma_asegurada DECIMAL(16,2);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_suscrip   DATE;
    DEFINE v_filtros          CHAR(255);
    DEFINE v_porc_partic      DECIMAL(5,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_usuario          CHAR(08);

	   CREATE TEMP TABLE temp_perfil
             (no_poliza      	CHAR(10),
			  no_endoso         CHAR(5),
              no_documento   	CHAR(20),
              no_factura     	CHAR(10),
              cod_ramo       	CHAR(3),
              cod_subramo    	CHAR(3),
              cod_sucursal   	CHAR(3),
              cod_grupo         CHAR(5),
              cod_tipoprod      CHAR(3),
              cod_contratante   CHAR(10),
              prima_suscrita    DEC(16,2),
              prima_retenida    DEC(16,2),
              vigencia_inic     DATE,
              vigencia_final    DATE,
              fecha_suscripcion DATE,
              usuario           CHAR(08),
              suma_asegurada    DEC(16,2),
              seleccionado      SMALLINT DEFAULT 1)
              WITH NO LOG;

         --     PRIMARY KEY(no_poliza))
       CREATE INDEX i_perfil1 ON temp_perfil(no_poliza, no_endoso);
       CREATE INDEX i_perfil2 ON temp_perfil(cod_ramo);
       CREATE INDEX i_perfil3 ON temp_perfil(cod_subramo);
       CREATE INDEX i_perfil4 ON temp_perfil(cod_tipoprod);
       CREATE INDEX i_perfil5 ON temp_perfil(cod_sucursal);

    LET v_cod_ramo     = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_cod_grupo    = NULL;
    LET v_cod_tipoprod = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_filtros        = " ";
    LET _tipo            = NULL;
    LET _no_documento     = NULL;
    LET _no_factura       = NULL;
    LET _no_poliza        = NULL;


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pr04a.trc";
--trace on;

    SET ISOLATION TO DIRTY READ;


          FOREACH WITH HOLD

              SELECT e.no_poliza,e.no_documento,e.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,e.prima_suscrita,e.prima_retenida,
                     e.vigencia_inic,e.vigencia_final,d.fecha_suscripcion,
                     d.user_added,d.suma_asegurada,e.no_endoso
                INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,v_prima_suscrita,v_prima_retenida,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada,_no_endoso
	             FROM emipomae d, endedmae e
	            WHERE d.no_poliza = e.no_poliza
	              AND d.cod_compania = a_cia
	              AND e.actualizado = 1
				  AND d.cod_ramo = a_cod_ramo
				 
{	          FOREACH
	            SELECT z.cod_agente,
	            	   z.porc_partic_agt
	              INTO v_cod_agente,
	              	   v_porc_partic
	              FROM emipoagt z
	             WHERE z.no_poliza = no_poliza}

	            INSERT INTO temp_perfil
	                VALUES(_no_poliza,
					       _no_endoso,
	                       _no_documento,
	                       _no_factura,
	                       v_cod_ramo,
	                       v_cod_subramo,
	                       v_cod_sucursal,
	                       v_cod_grupo,
	                       v_cod_tipoprod,
	                       v_contratante,
	                       v_prima_suscrita,
	                       v_prima_retenida,
	                       v_vigencia_inic,
	                       v_vigencia_final,
	                       v_fecha_suscrip,
	                       v_usuario,
	                       v_suma_asegurada,
	                       1);
--	          END FOREACH

          END FOREACH


    RETURN v_filtros;
END PROCEDURE







										  