--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------

DROP procedure sp_pro02a;
CREATE procedure "informix".sp_pro02a(a_compania CHAR(3),a_agencia CHAR(03) DEFAULT "*",a_periodo DATE,a_codsucursal  CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")
   RETURNING DEC(16,2),DEC(16,2),SMALLINT,DEC(16,2),
             DEC(16,2),SMALLINT,SMALLINT,CHAR(03),CHAR(45),
             DATE,CHAR(45),CHAR(255),CHAR(20);


 BEGIN

    DEFINE v_codramo,v_codsucursal      CHAR(3);
    DEFINE v_desc_ramo,descr_cia        CHAR(45);
    DEFINE v_cant_polizas,v_cant_coasegur1,v_cant_coasegur2,mes SMALLINT;
    DEFINE v_prima_suscrita				DECIMAL(16,2);
    DEFINE v_prima_retenida				DECIMAL(16,2);
    DEFINE _prima_suscrita				DECIMAL(16,2);
    DEFINE _prima_retenida				DECIMAL(16,2);
    DEFINE v_rango_inicial				DECIMAL(16,2);
    DEFINE v_rango_final				DECIMAL(16,2);
    DEFINE v_suma_asegurada DECIMAL(16,2);
    DEFINE codigo1          SMALLINT;
    DEFINE v_fecha_cancel   DATE;
    DEFINE _no_poliza        CHAR(10);
    DEFINE v_filtros        CHAR(255);
    DEFINE _tipo            CHAR(1);
    DEFINE rango_max        INTEGER;
    DEFINE rango_min        DECIMAL(16,2);
    DEFINE mes1             CHAR(02);
	DEFINE ano              CHAR(04);
    DEFINE periodo1         CHAR(07);
	DEFINE v_cod_tipoprod   CHAR(03);
	DEFINE v_cod_cliente    CHAR(10);
	DEFINE _fecha_emision, _fecha_cancelacion DATE;
	DEFINE _no_endoso		CHAR(5);
	DEFINE v_documento      CHAR(20);

   CREATE TEMP TABLE temp_ubica
         (no_poliza          CHAR(10),
          suma_asegurada     DEC(16,2),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

       LET descr_cia = sp_sis01(a_compania);
       CREATE TEMP TABLE temp_civil
             (cod_sucursal     CHAR(03),
              cod_ramo         CHAR(03),
              rango_inicial    DECIMAL(16,2),
              rango_final      DECIMAL(16,2),
              cant_polizas     SMALLINT,
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              cant_coasegur1   SMALLINT,
              cant_coasegur2   SMALLINT,
              seleccionado     SMALLINT DEFAULT 1,
			  no_poliza        CHAR(10),
              PRIMARY KEY (no_poliza)) WITH NO LOG;

      CREATE INDEX iend1_temp_civil ON temp_civil(cod_sucursal);
      CREATE INDEX iend2_temp_civil ON temp_civil(cod_ramo);
--      CREATE INDEX iend3_temp_civil ON temp_civil(cod_ramo,rango_inicial);

    LET v_codramo        = NULL;
    LET v_desc_ramo      = NULL;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET v_cant_polizas   = 0;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita = 0;
    LET _prima_retenida = 0;
    LET v_suma_asegurada = 0;
    LET _no_poliza       = NULL;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET mes 			 = MONTH(a_periodo);

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

--    SET DEBUG FILE TO "sp_pro02a.trc";
--	trace on;

FOREACH
	SELECT a.no_poliza,
           a.fecha_cancelacion,
           a.cod_ramo,
           a.cod_sucursal,
           a.suma_asegurada,
           a.cod_tipoprod,
		   b.no_endoso
      INTO _no_poliza,
           v_fecha_cancel,
           v_codramo,
           v_codsucursal,
           v_suma_asegurada,
           v_cod_tipoprod,
		   _no_endoso
      FROM emipomae a, endedmae b
     WHERE a.cod_compania = a_compania
       AND (a.vigencia_final >= a_periodo
   	    OR a.vigencia_final IS NULL)
	   AND a.fecha_suscripcion <= a_periodo
	   AND a.vigencia_inic < a_periodo
	   AND a.actualizado = 1
	   AND b.no_poliza = a.no_poliza
	   AND b.periodo <= periodo1
	   AND b.fecha_emision <= a_periodo
	   AND b.actualizado = 1
--	   AND a.no_documento = '0601-00033-01'

		   {b.prima_suscrita,
		   b.prima_retenida,
		   _prima_suscrita,
		   _prima_retenida,}

	      LET _fecha_emision = null;

	      IF v_fecha_cancel <= a_periodo AND v_fecha_cancel IS NOT NULL THEN
		     FOREACH
				SELECT fecha_emision
				  INTO _fecha_emision
				  FROM endedmae
				 WHERE no_poliza = _no_poliza
				   AND cod_endomov = '002'
				   AND vigencia_inic = v_fecha_cancel
				   AND actualizado = 1
			 END FOREACH

			 IF  _fecha_emision <= a_periodo THEN
			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;
				CONTINUE FOREACH;
			 ELSE
	          SELECT prima_suscrita,
					 prima_retenida
	            INTO _prima_suscrita,
					 _prima_retenida
	            FROM endedmae
	           WHERE no_poliza = _no_poliza
			     AND no_endoso = _no_endoso;

			   BEGIN
			      ON EXCEPTION IN(-239)
			         UPDATE temp_ubica
			            SET prima_suscrita = prima_suscrita + _prima_suscrita,
			                prima_retenida = prima_retenida + _prima_retenida
			          WHERE no_poliza      = _no_poliza;

			      END EXCEPTION

			      INSERT INTO temp_ubica
					  VALUES(
				      _no_poliza,
					  v_suma_asegurada,
				      _prima_suscrita,
				      _prima_retenida
				      );
			   END
			 END IF
		  ELSE
	          SELECT prima_suscrita,
					 prima_retenida
	            INTO _prima_suscrita,
					 _prima_retenida
	            FROM endedmae
	           WHERE no_poliza = _no_poliza
			     AND no_endoso = _no_endoso;

			   BEGIN
			      ON EXCEPTION IN(-239)
			         UPDATE temp_ubica
			            SET prima_suscrita = prima_suscrita + _prima_suscrita,
			                prima_retenida = prima_retenida + _prima_retenida
			          WHERE no_poliza      = _no_poliza;

			      END EXCEPTION

			      INSERT INTO temp_ubica
					  VALUES(
				      _no_poliza,
					  v_suma_asegurada,
				      _prima_suscrita,
				      _prima_retenida
				      );
			   END

		  END IF

END FOREACH

FOREACH

	  SELECT no_poliza,
	         suma_asegurada,
			 prima_suscrita,
			 prima_retenida
		INTO _no_poliza,
			 v_suma_asegurada,
			 _prima_suscrita,
			 _prima_retenida
		FROM temp_ubica

	  SELECT cod_ramo
		INTO v_codramo
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

	   SELECT emitipro.tipo_produccion
         INTO codigo1
         FROM emitipro,emipomae
        WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
          AND emipomae.no_poliza = _no_poliza;

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

	SELECT parinfra.rango1, 
		   parinfra.rango2
	  INTO v_rango_inicial,
	  	   v_rango_final
	  FROM parinfra
	 WHERE parinfra.cod_ramo = v_codramo
	   AND parinfra.rango1 <= v_suma_asegurada	   
	   AND parinfra.rango2 >= v_suma_asegurada;

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
--          LET v_rango_inicial = -9999999999.00 ;
--		  LET v_rango_final = 100000.00;
       END IF;

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                SET prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2
              WHERE no_poliza      = _no_poliza;

          END EXCEPTION

          INSERT INTO temp_civil
  		  VALUES(
  		  v_codsucursal,
          v_codramo,
          v_rango_inicial,
          v_rango_final,
          1,
          _prima_suscrita,
          _prima_retenida,
          v_cant_coasegur1,
          v_cant_coasegur2,
          1,
		  _no_poliza
          );
       END
       LET _prima_suscrita   = 0;
       LET _prima_retenida   = 0;
END FOREACH

     -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_civil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

FOREACH
	SELECT cod_ramo,
		   rango_inicial,
		   rango_final,
		   cant_polizas,
		   prima_suscrita,
		   prima_retenida,
		   cant_coasegur1,
		   cant_coasegur2,
		   no_poliza
	  INTO v_codramo,
	  	   v_rango_inicial,
	  	   v_rango_final,
	  	   v_cant_polizas,
	       v_prima_suscrita,
	       v_prima_retenida,
	       v_cant_coasegur1,
	       v_cant_coasegur2,
		   _no_poliza
	  FROM temp_civil
	 WHERE seleccionado = 1
  ORDER BY cod_ramo,rango_inicial

	SELECT MAX(rango1)
	  INTO rango_max
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

	SELECT MIN(rango1)
	  INTO rango_min
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

     IF rango_max = v_rango_inicial THEN
	     LET v_rango_final = -1;
     END IF;
     IF rango_min = v_rango_inicial THEN
	     LET v_rango_inicial = -1;
     END IF;

     SELECT nombre
       INTO v_desc_ramo
       FROM prdramo
      WHERE cod_ramo = v_codramo;

	 SELECT no_documento
	   INTO v_documento
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

         RETURN v_rango_inicial,v_rango_final,v_cant_polizas,
                v_prima_suscrita,v_prima_retenida,v_cant_coasegur1,
                v_cant_coasegur2,v_codramo,v_desc_ramo,a_periodo,
                descr_cia,v_filtros, v_documento WITH RESUME;
END FOREACH

DROP TABLE temp_civil;
DROP TABLE temp_ubica;
   END
END PROCEDURE;
