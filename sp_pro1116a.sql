   DROP procedure sp_pro1116a;
   CREATE procedure sp_pro1116a(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codramo CHAR(255))

RETURNING CHAR(255);

--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Amado Perez - Abril 2001 - 
---  Ref. Power Builder - d_sp_pro60a
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal,v_cod_tipoprod  CHAR(3);
    DEFINE _no_poliza,_no_factura     CHAR(10);
    DEFINE _no_documento              CHAR(20);
    DEFINE v_cod_grupo              CHAR(05);
    DEFINE v_contratante            CHAR(10);
    DEFINE v_cod_agente             CHAR(05);
    DEFINE v_prima_suscrita,v_prima_retenida,v_suma_asegurada DECIMAL(16,2);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_suscrip   DATE;
    DEFINE v_filtros          CHAR(255);
    DEFINE v_porc_partic      DECIMAL(5,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_usuario          CHAR(08);
    DEFINE mes                SMALLINT;
	DEFINE mes1               CHAR(02);
	DEFINE ano                CHAR(04);
    DEFINE periodo1           CHAR(07);
	DEFINE _fecha_emision, _fecha_cancelacion DATE;
	DEFINE _estatus_poliza    SMALLINT;

	   CREATE TEMP TABLE temp_perfil
             (no_poliza      CHAR(10),
              no_documento   CHAR(20),
              no_factura     CHAR(10),
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cod_sucursal   CHAR(3),
              cod_grupo      CHAR(5),
              cod_tipoprod   CHAR(3),
              cod_contratante CHAR(10),
              cod_agente      CHAR(5),
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              vigencia_inic    DATE,
              vigencia_final   DATE,
              fecha_suscripcion DATE,
              usuario           CHAR(08),
              suma_asegurada   DEC(16,2),
			  estatus_poliza   SMALLINT,
              seleccionado     SMALLINT DEFAULT 1)
              WITH NO LOG;

         --     PRIMARY KEY(no_poliza))
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
    LET v_cod_agente   = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_filtros        = " ";
    LET _tipo            = NULL;
    LET _no_documento    = NULL;
    LET _no_factura      = NULL;
    LET _no_poliza       = NULL;

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

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pr04a.trc";
--trace on;
    SET ISOLATION TO DIRTY READ;
    IF a_codramo = "*" THEN
		FOREACH WITH HOLD
			SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
			       d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
			       d.cod_contratante,d.prima_suscrita,d.prima_retenida,
			       d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
			       d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
			  INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
			       v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
			       v_contratante,v_prima_suscrita,v_prima_retenida,
			       v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
			       v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
			  FROM emipomae d
			 WHERE d.cod_compania = a_cia
			   AND d.vigencia_final >= a_periodo
			   AND d.fecha_suscripcion <= a_periodo
			   AND d.periodo <= periodo1
			   AND d.vigencia_inic < a_periodo
			   AND d.actualizado = 1

--              AND (d.fecha_cancelacion IS NULL
--              OR  d.fecha_cancelacion > a_periodo)

	        LET _fecha_emision = null;

	      IF _fecha_cancelacion <= a_periodo THEN
		     FOREACH
				SELECT fecha_emision
				  INTO _fecha_emision
				  FROM endedmae
				 WHERE no_poliza = _no_poliza
				   AND cod_endomov = '002'
				   AND vigencia_inic = _fecha_cancelacion
			 END FOREACH

			 IF  _fecha_emision <= a_periodo THEN
				CONTINUE FOREACH;
			 END IF
		  END IF

          FOREACH
            SELECT z.cod_agente,z.porc_partic_agt
                   INTO v_cod_agente,v_porc_partic
                   FROM emipoagt z
                  WHERE z.no_poliza = _no_poliza

                 LET v_prima_suscrita = v_prima_suscrita * (v_porc_partic/100);

          END FOREACH
            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario,
                       v_suma_asegurada,
					   _estatus_poliza,
                       1);

       END FOREACH
    END IF
    IF a_codramo <> "*" THEN
       LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String
       LET v_filtros = TRIM(v_filtros) ||"Ramo: "||TRIM(a_codramo);

       IF _tipo <> "E" THEN -- Incluir los Registros
          FOREACH WITH HOLD

              SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,d.prima_suscrita,d.prima_retenida,
                     d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  	 d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
                INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,v_prima_suscrita,v_prima_retenida,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
                 FROM emipomae d
                WHERE d.cod_compania = a_cia
                  AND d.vigencia_final >= a_periodo
                  AND d.fecha_suscripcion <= a_periodo
				  AND d.periodo <= periodo1
	              AND d.actualizado = 1
				  AND d.vigencia_inic < a_periodo
				  AND d.cod_ramo IN(SELECT codigo FROM tmp_codigos)

--                  AND (d.fecha_cancelacion IS NULL
--                  OR   d.fecha_cancelacion > a_periodo)

		      LET _fecha_emision = null;

		      IF _fecha_cancelacion <= a_periodo THEN
			     FOREACH
					SELECT fecha_emision
					  INTO _fecha_emision
					  FROM endedmae
					 WHERE no_poliza = _no_poliza
					   AND cod_endomov = '002'
					   AND vigencia_inic = _fecha_cancelacion
				 END FOREACH

				 IF  _fecha_emision <= a_periodo THEN
					CONTINUE FOREACH;
				 END IF
			  END IF
				 
          FOREACH
            SELECT z.cod_agente,z.porc_partic_agt
                   INTO v_cod_agente,v_porc_partic
                   FROM emipoagt z
                  WHERE z.no_poliza = _no_poliza

            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario,
                       v_suma_asegurada,
					   _estatus_poliza,
                       1);
                 END FOREACH

          END FOREACH
          DROP TABLE tmp_codigos;

       ELSE
          FOREACH WITH HOLD

              SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,d.prima_suscrita,d.prima_retenida,
                     d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  	 d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
                INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,v_prima_suscrita,v_prima_retenida,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
                 FROM emipomae d
                WHERE d.cod_compania = a_cia
                  AND d.vigencia_final >= a_periodo
	              AND d.actualizado = 1
                  AND d.fecha_suscripcion <= a_periodo
				  AND d.vigencia_inic < a_periodo
				  AND d.periodo <= periodo1
				  AND d.cod_ramo NOT IN(SELECT codigo FROM tmp_codigos)

--                  AND (d.fecha_cancelacion IS NULL
--                  OR  d.fecha_cancelacion > a_periodo)

		      LET _fecha_emision = null;

		      IF _fecha_cancelacion <= a_periodo THEN
			     FOREACH
					SELECT fecha_emision
					  INTO _fecha_emision
					  FROM endedmae
					 WHERE no_poliza = _no_poliza
					   AND cod_endomov = '002'
					   AND vigencia_inic = _fecha_cancelacion
				 END FOREACH

				 IF  _fecha_emision <= a_periodo THEN
					CONTINUE FOREACH;
				 END IF
			  END IF

           FOREACH
              SELECT z.cod_agente,z.porc_partic_agt
                     INTO v_cod_agente,v_porc_partic
                     FROM emipoagt z
                    WHERE z.no_poliza = _no_poliza


            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario, 
                       v_suma_asegurada,
 					   _estatus_poliza,
                      1);

               END FOREACH
            END FOREACH
            DROP TABLE tmp_codigos;
       END IF
     END IF
	 
	-- Pólizas vencidas anio anterior
	let _ano = year(a_periodo);
	let _ano = _ano - 1;
	let _fecha_ini = mdy(1, 1, _ano);
	let _fecha_fin = mdy(12, 31, _ano);
	IF a_codramo = "*" THEN
	   FOREACH WITH HOLD
          SELECT  d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                  d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                  d.cod_contratante,d.prima_suscrita,d.prima_retenida,
                  d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
             INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                  v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                  v_contratante,v_prima_suscrita,v_prima_retenida,
                  v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                  v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
             FROM emipomae d
            WHERE d.cod_compania = a_cia
              AND d.vigencia_final >= _fecha_ini
              AND d.vigencia_final <= _fecha_fin
              AND d.actualizado = 1
			  AND d.renovada = 0
			  AND d.estatus_poliza NOT IN (2, 4)

          FOREACH
            SELECT z.cod_agente,z.porc_partic_agt
                   INTO v_cod_agente,v_porc_partic
                   FROM emipoagt z
                  WHERE z.no_poliza = _no_poliza

                 LET v_prima_suscrita = v_prima_suscrita * (v_porc_partic/100);

          END FOREACH
            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario,
                       v_suma_asegurada,
					   _estatus_poliza,
                       1);
       END FOREACH
	END IF
	IF a_codramo <> "*" THEN
       LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String
       LET v_filtros = TRIM(v_filtros) ||"Ramo: "||TRIM(a_codramo);

       IF _tipo <> "E" THEN -- Incluir los Registros
          FOREACH WITH HOLD

              SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,d.prima_suscrita,d.prima_retenida,
                     d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  	 d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
                INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,v_prima_suscrita,v_prima_retenida,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
                 FROM emipomae d
                WHERE d.cod_compania = a_cia
				  AND d.vigencia_final >= _fecha_ini
				  AND d.vigencia_final <= _fecha_fin
				  AND d.actualizado = 1
				  AND d.renovada = 0
			      AND d.estatus_poliza NOT IN (2, 4)
				  AND d.cod_ramo IN(SELECT codigo FROM tmp_codigos)
				 
          FOREACH
            SELECT z.cod_agente,z.porc_partic_agt
                   INTO v_cod_agente,v_porc_partic
                   FROM emipoagt z
                  WHERE z.no_poliza = _no_poliza

            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario,
                       v_suma_asegurada,
					   _estatus_poliza,
                       1);
                 END FOREACH

          END FOREACH
          DROP TABLE tmp_codigos;

       ELSE
          FOREACH WITH HOLD

              SELECT d.no_poliza,d.no_documento,d.no_factura,d.sucursal_origen,
                     d.cod_grupo,d.cod_ramo,d.cod_subramo,d.cod_tipoprod,
                     d.cod_contratante,d.prima_suscrita,d.prima_retenida,
                     d.vigencia_inic,d.vigencia_final,d.fecha_suscripcion,
                  	 d.user_added,d.suma_asegurada,d.fecha_cancelacion,d.estatus_poliza
                INTO _no_poliza,_no_documento,_no_factura,v_cod_sucursal,
                     v_cod_grupo,v_cod_ramo,v_cod_subramo,v_cod_tipoprod,
                     v_contratante,v_prima_suscrita,v_prima_retenida,
                     v_vigencia_inic,v_vigencia_final,v_fecha_suscrip,
                     v_usuario,v_suma_asegurada,_fecha_cancelacion,_estatus_poliza
                 FROM emipomae d
                WHERE d.cod_compania = a_cia
				  AND d.vigencia_final >= _fecha_ini
				  AND d.vigencia_final <= _fecha_fin
				  AND d.actualizado = 1
				  AND d.renovada = 0
			      AND d.estatus_poliza NOT IN (2, 4)
				  AND d.cod_ramo NOT IN(SELECT codigo FROM tmp_codigos)


           FOREACH
              SELECT z.cod_agente,z.porc_partic_agt
                     INTO v_cod_agente,v_porc_partic
                     FROM emipoagt z
                    WHERE z.no_poliza = _no_poliza


            INSERT INTO temp_perfil
                VALUES(_no_poliza,
                       _no_documento,
                       _no_factura,
                       v_cod_ramo,
                       v_cod_subramo,
                       v_cod_sucursal,
                       v_cod_grupo,
                       v_cod_tipoprod,
                       v_contratante,
                       v_cod_agente,
                       v_prima_suscrita,
                       v_prima_retenida,
                       v_vigencia_inic,
                       v_vigencia_final,
                       v_fecha_suscrip,
                       v_usuario, 
                       v_suma_asegurada,
					   _estatus_poliza,
                       1);

               END FOREACH
            END FOREACH
            DROP TABLE tmp_codigos;
       END IF
	END IF

    RETURN v_filtros;
END PROCEDURE					  