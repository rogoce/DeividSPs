---------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL  ---
---            POLIZAS VIGENTES           ---
---  Yinia M. Zamora - agosto 2000 - YMZM ---
---  Ref. Power Builder - d_sp_pro03	  ---
---------------------------------------------

DROP procedure sp_pro03h;
CREATE procedure sp_pro03h(
		 a_cia 	   CHAR(03),
		 a_agencia CHAR(3),
		 a_periodo DATE,
		 a_codramo CHAR(255)
		 )

RETURNING CHAR(255);

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal,v_cod_tipoprod  CHAR(3);
    DEFINE _no_poliza,_no_factura     CHAR(10);
    DEFINE _no_documento              CHAR(20);
    DEFINE v_cod_grupo                CHAR(05);
    DEFINE v_contratante              CHAR(10);
    DEFINE v_cod_agente               CHAR(05);
    DEFINE v_prima_suscrita,v_prima_retenida,v_suma_asegurada DECIMAL(16,2);
    DEFINE v_prima_bruta 			  DECIMAL(16,2);
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
	define _cnt               smallint;

    LET v_cod_ramo     = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_cod_grupo    = NULL;
    LET v_cod_tipoprod = NULL;
    LET v_cod_agente   = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
	let v_prima_bruta    = 0;
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

    SET ISOLATION TO DIRTY READ;

IF a_codramo <> "*" THEN
   LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String
   LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);

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
				 d.prima_suscrita,
				 d.prima_retenida,
				 d.vigencia_inic,
				 d.vigencia_final,
				 d.fecha_suscripcion,
				 d.user_added,
				 d.suma_asegurada,
				 d.fecha_cancelacion,
				 d.prima_bruta
			INTO _no_poliza,
				 _no_documento,
				 _no_factura,
				 v_cod_sucursal,
				 v_cod_grupo,
				 v_cod_ramo,
				 v_cod_subramo,
				 v_cod_tipoprod,
				 v_contratante,
				 v_prima_suscrita,
				 v_prima_retenida,
				 v_vigencia_inic,
				 v_vigencia_final,
				 v_fecha_suscrip,
				 v_usuario,
				 v_suma_asegurada,
				 _fecha_cancelacion,
				 v_prima_bruta
			FROM emipomae d
		   WHERE d.cod_compania    = a_cia
			 AND d.estatus_poliza  = 3
			 AND d.cod_ramo IN(SELECT codigo FROM tmp_codigos)

		 
		  FOREACH
			SELECT z.cod_agente,
				   z.porc_partic_agt
			  INTO v_cod_agente,
				   v_porc_partic
			  FROM emipoagt z
			 WHERE z.no_poliza = _no_poliza

				Exit foreach;
		  END FOREACH

			select count(*)
			  into _cnt
			  from temp_perfil
			 where no_documento = _no_documento;

			if _cnt > 0 then
			else
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
						   v_prima_bruta,
						   1);
		  
			end if
	  END FOREACH

	  DROP TABLE tmp_codigos;
END IF
RETURN v_filtros;
END PROCEDURE