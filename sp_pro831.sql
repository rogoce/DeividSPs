--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Armando Moreno M. 22/11/2001
---  Copia del sp_pro83 pero se elimina el filtro de canceladas
---  Amado Perez 14/01/2002
---  Ref. Power Builder - sp_pro03
--------------------------------------------

--DROP procedure sp_pro831;
CREATE procedure "informix".sp_pro831(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codramo CHAR(255))

RETURNING CHAR(255);

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal,v_cod_tipoprod  CHAR(3);
    DEFINE _no_poliza,_no_factura   CHAR(10);
    DEFINE _no_documento            CHAR(20);
    DEFINE v_cod_grupo              CHAR(05);
    DEFINE v_contratante            CHAR(10);
    DEFINE v_suma_asegurada DECIMAL(16,2);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_suscrip   DATE;
    DEFINE v_filtros          CHAR(255);
    DEFINE v_porc_partic      DECIMAL(5,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_usuario          CHAR(08);
    DEFINE mes                SMALLINT;
	DEFINE mes1               CHAR(02);
	DEFINE ano                CHAR(04);
    DEFINE periodo1           CHAR(07);

	   CREATE TEMP TABLE temp_perfil
             (no_poliza      	CHAR(10),
              no_documento   	CHAR(20),
              no_factura     	CHAR(10),
              cod_ramo       	CHAR(3),
              cod_subramo    	CHAR(3),
              cod_sucursal   	CHAR(3),
              cod_grupo         CHAR(5),
              cod_tipoprod      CHAR(3),
              cod_contratante   CHAR(10),
              vigencia_inic     DATE,
              vigencia_final    DATE,
              fecha_suscripcion DATE,
              usuario           CHAR(08),
              suma_asegurada    DEC(16,2),
              seleccionado      SMALLINT DEFAULT 1)
              WITH NO LOG;

       CREATE INDEX i_perfil1 ON temp_perfil(no_poliza);
       CREATE INDEX i_perfil2 ON temp_perfil(cod_ramo);
       CREATE INDEX i_perfil3 ON temp_perfil(cod_subramo);
       CREATE INDEX i_perfil4 ON temp_perfil(cod_tipoprod);
       CREATE INDEX i_perfil5 ON temp_perfil(cod_sucursal);

    LET v_cod_ramo     = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_cod_grupo    = NULL;
    LET v_cod_tipoprod = NULL;
    LET v_filtros        = " ";
    LET _tipo            = NULL;
    LET no_documento     = NULL;
    LET no_factura       = NULL;
    LET no_poliza        = NULL;

	LET mes = MONTH(a_periodo);
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

    IF a_codramo = "*" THEN
	   FOREACH WITH HOLD
          SELECT  d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                  d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,d.cod_contratante,
                  d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  d.user_added,d.suma_asegurada
            INTO  no_poliza,no_documento,no_factura,v_cod_sucursal,
                  v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,v_contratante,
                  v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                  v_usuario,v_suma_asegurada
             FROM emipomae d
            WHERE d.cod_compania = a_cia
              AND (d.vigencia_final >= a_periodo
			   OR d.vigencia_final IS NULL)
              AND d.fecha_suscripcion <= a_periodo
              AND d.vigencia_inic < a_periodo
              AND d.actualizado = 1

            INSERT INTO temp_perfil
                VALUES(no_poliza,
                       no_documento,
                       no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario,
                       v_suma_asegurada,
                       1);

       END FOREACH
    END IF

    IF a_codramo <> "*" THEN
       LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String
       LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);

       IF _tipo <> "E" THEN -- Incluir los Registros
          FOREACH WITH HOLD
              SELECT d.no_poliza,
              		 d.no_documento,
              		 d.no_factura,
              		 d.sucursal_origen,
                     d.cod_grupo,
                     d.cod_ramo,
                     d.cod_subramo,
                     d.cod_tipoprod,
                     d.cod_contratante,
                     d.vigencia_inic,
                     d.vigencia_final,
                     d.fecha_suscripcion,
                     d.user_added,
                     d.suma_asegurada
                INTO no_poliza,
                	 no_documento,
                	 no_factura,
                	 v_cod_sucursal,
                     v_cod_grupo,
                     v_cod_ramo,
                     v_cod_subramo,
                     v_cod_tipoprod,
                     v_contratante,
                     v_vigencia_inic,
                     v_vigencia_final,
                     v_fecha_suscrip,
                     v_usuario,
                     v_suma_asegurada
                FROM emipomae d
               WHERE d.cod_compania = a_cia
              	 AND (d.vigencia_final >= a_periodo
			   	  OR d.vigencia_final IS NULL)
	             AND d.fecha_suscripcion <= a_periodo
	             AND d.vigencia_inic < a_periodo
	             AND d.actualizado = 1
				 AND d.cod_ramo IN(SELECT codigo FROM tmp_codigos)
				 
	            INSERT INTO temp_perfil
	                VALUES(no_poliza,
	                       no_documento,
	                       no_factura,
	                       v_cod_ramo,
	                       v_cod_subramo,
	                       v_cod_sucursal,
	                       v_cod_grupo,
	                       v_cod_tipoprod,
	                       v_contratante,
	                       v_vigencia_inic,
	                       v_vigencia_final,
	                       v_fecha_suscrip,
	                       v_usuario,
	                       v_suma_asegurada,
	                       1);
          END FOREACH

          DROP TABLE tmp_codigos;
       ELSE
          FOREACH WITH HOLD

              SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,
                     d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                     d.user_added,d.suma_asegurada
                INTO no_poliza,no_documento,no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada
                 FROM emipomae d
                WHERE d.cod_compania = a_cia
                  AND (d.vigencia_final >= a_periodo
			   	   OR d.vigencia_final IS NULL)
	              AND d.fecha_suscripcion <= a_periodo
	              AND d.vigencia_inic < a_periodo
	              AND d.actualizado = 1
				  AND d.cod_ramo NOT IN(SELECT codigo FROM tmp_codigos)

            INSERT INTO temp_perfil
                VALUES(no_poliza,
                       no_documento,
                       no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario, 
                       v_suma_asegurada,
                       1);

          END FOREACH
          DROP TABLE tmp_codigos;
       END IF
    END IF
RETURN v_filtros;
END PROCEDURE







										  