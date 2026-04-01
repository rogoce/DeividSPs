--   DROP procedure sp_pro03f;
   CREATE procedure "informix".sp_pro03f(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),CHAR(50),INT,DECIMAL(16,2),DECIMAL(16,2),DATE,
             CHAR(3),CHAR(50),CHAR(255),CHAR(45);
--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro03b
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
	DEFINE v_desc_producto	  CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2, _tipo_contrato  SMALLINT;
    DEFINE _no_poliza         CHAR(10);
	DEFINE _no_endoso, _no_unidad  CHAR(5);
	DEFINE _cod_producto, _cod_contrato      CHAR(5);
    DEFINE v_cant_polizas          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida, _prima,
           _prima_suscrita,_prima_retenida,v_suma_asegurada   DECIMAL(16,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_filtros          CHAR(255);

    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
			  cod_producto   CHAR(5),
              cod_sucursal   CHAR(3),
              cant_polizas   SMALLINT,
              prima_suscrita DEC(16,2),
              prima_retenida DEC(16,2),
              seleccionado   SMALLINT DEFAULT 1,
              PRIMARY KEY(cod_ramo,cod_subramo,cod_producto)) WITH NO LOG;

    LET v_cod_ramo  = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_desc_subramo = NULL;
    LET v_cant_polizas = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita = 0;
    LET _prima_retenida = 0;
    LET _tipo     = NULL;

	LET descr_cia = sp_sis01(a_cia);

    CALL sp_pro83(a_cia,a_agencia,a_periodo,a_codramo) RETURNING v_filtros;
    
    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String
 
         IF _tipo <> "E" THEN -- Incluir los Registros
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF  
     
    FOREACH WITH HOLD
       SELECT no_poliza,
       		  cod_ramo,
       		  cod_subramo,
       		  cod_sucursal,
              suma_asegurada
         INTO _no_poliza,
         	  v_cod_ramo,
         	  v_cod_subramo,
         	  v_cod_sucursal,
              v_suma_asegurada
         FROM temp_perfil
        WHERE seleccionado = 1

		 FOREACH
          SELECT prima_suscrita,
				 prima_retenida,
				 cod_producto,
				 no_endoso,
				 no_unidad
            INTO _prima_suscrita,
				 _prima_retenida,
				 _cod_producto,
				 _no_endoso,
				 _no_unidad
            FROM endeduni
           WHERE no_poliza = _no_poliza

		  LET _prima_suscrita = 0;
		  LET _prima_retenida = 0;

		  FOREACH
    		SELECT prima,
			       cod_contrato
			  INTO _prima,
			       _cod_contrato
			  FROM emifacon
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = _no_endoso
			   AND no_unidad = _no_unidad

			SELECT tipo_contrato
			  INTO _tipo_contrato
			  FROM reacomae
			 WHERE cod_contrato = _cod_contrato;

			 LET _prima_suscrita = _prima_suscrita + _prima;

			 IF _tipo_contrato = 1 THEN
			 	LET _prima_retenida = _prima_retenida + _prima;
			 END IF

		   END FOREACH


	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
	                    cant_polizas   = cant_polizas + 1
	              WHERE cod_ramo    = v_cod_ramo
	                AND cod_subramo = v_cod_subramo
	                AND cod_producto = _cod_producto;

	          END EXCEPTION
	          INSERT INTO temp_perfil1
	              VALUES(v_cod_ramo,
	                     v_cod_subramo,
						 _cod_producto,
	                     v_cod_sucursal,
	                     1,
	                     _prima_suscrita,
	                     _prima_retenida,
	                     1);
	       END
		 END FOREACH

    END FOREACH
--  Seleccion Final
    FOREACH
       SELECT cod_ramo,
       		  cod_subramo,
			  cod_producto,
       		  cant_polizas,
       		  prima_suscrita,
              prima_retenida
         INTO v_cod_ramo,
              v_cod_subramo,
			  _cod_producto,
              v_cant_polizas,
              v_prima_suscrita,
              v_prima_retenida
         FROM temp_perfil1
        WHERE seleccionado = 1
     ORDER BY cod_ramo,cod_subramo

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
         INTO v_desc_producto
         FROM prdprod
        WHERE cod_producto = _cod_producto;

       RETURN  v_cod_subramo,v_desc_subramo,v_desc_producto,v_cant_polizas,
               v_prima_suscrita,v_prima_retenida,a_periodo,
               v_cod_ramo,v_desc_ramo,v_filtros,descr_cia WITH RESUME;

    END FOREACH

DROP TABLE temp_perfil;
DROP TABLE temp_perfil1;

END PROCEDURE;
