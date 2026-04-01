--------------------------------------------
---  RANGOS DE SUMA ASEGURADA 1ER. EXCEDENTE   ---
---  INCENDIO Y MULTIRIESGO POLIZA VIGENTES    ---
---  Creado por Amado Perez Octubre 2001 	   ---
---  Corregido el 29/11/2001                   ---
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------

DROP procedure sp_pro02e;
CREATE procedure "informix".sp_pro02e(a_compania CHAR(3),a_agencia CHAR(03) DEFAULT "*",a_periodo DATE,a_codsucursal  CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")
   RETURNING CHAR(20),DEC(16,2),DEC(16,2),SMALLINT,DEC(16,2),DEC(16,2),
             DEC(16,2),DEC(16,2),SMALLINT,SMALLINT,CHAR(03),CHAR(45),
             DATE,CHAR(45),CHAR(255);


 BEGIN
	DEFINE v_suma_asegurada    DEC(16,2);
	DEFINE v_retencion         DEC(16,2);
	DEFINE v_prima_retencion   DEC(16,2);
	DEFINE v_excedente         DEC(16,2);
	DEFINE v_prima_excedente   DEC(16,2);
	DEFINE v_facultativo       DEC(16,2);
	DEFINE v_prima_facultativo DEC(16,2);
	DEFINE v_prima			   DEC(16,2);
	DEFINE v_compania_nombre   CHAR(50);

    DEFINE v_codramo,v_codsucursal      CHAR(3);
    DEFINE v_desc_ramo,descr_cia        CHAR(45);
    DEFINE v_cant_polizas,v_cant_coasegur1,v_cant_coasegur2,mes SMALLINT;
    DEFINE v_prima_excedente2,v_prima_retenida,
           v_rango_inicial,v_rango_final,v_suma_asegurada2, suma_compara  DECIMAL(16,2);
    DEFINE codigo1          SMALLINT;
    DEFINE v_fecha_cancel   DATE;
    DEFINE _no_poliza, a_poliza, ref_no_poliza   CHAR(10);
    DEFINE v_filtros        CHAR(255);
    DEFINE _tipo            CHAR(1);
    DEFINE rango_max,_cant_exe INTEGER;
    DEFINE mes1             CHAR(02);
	DEFINE ano              CHAR(04);
    DEFINE periodo1         CHAR(07);
	DEFINE v_cod_tipoprod   CHAR(03);
	DEFINE v_cod_cliente    CHAR(10);
	DEFINE v_documento		CHAR(20);
	DEFINE _fecha_emision, _fecha_cancelacion DATE;
	DEFINE _no_endoso		CHAR(5);

   CREATE TEMP TABLE temp_ubica(
		  cod_ubica          CHAR(3),
          no_poliza          CHAR(10),
		  no_documento	     CHAR(20),
          suma_asegurada     DEC(16,2),
		  retencion          DEC(16,2),
		  retencion_prima    DEC(16,2),
          primer_excedente   DEC(16,2),
		  cnt_excedente      INT,
		  primer_exced_prima DEC(16,2),
          facultativo        DEC(16,2),
          facultativo_prima  DEC(16,2),
          prima_terremoto    DEC(16,2),
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

       LET descr_cia = sp_sis01(a_compania);
       CREATE TEMP TABLE temp_civil
             (no_poliza        CHAR(10),
			  no_documento     CHAR(20),
              cod_sucursal     CHAR(03),
              cod_ramo         CHAR(03),
              rango_inicial    DECIMAL(16,2),
              rango_final      DECIMAL(16,2),
              cant_polizas     SMALLINT,
			  suma_excedente   DEC(16,2),
              prima_excedente  DEC(16,2),
			  suma_retenida    DEC(16,2),
              prima_retenida   DEC(16,2),
              cant_coasegur1   SMALLINT,
              cant_coasegur2   SMALLINT,
              seleccionado     SMALLINT DEFAULT 1,
              PRIMARY KEY (no_poliza)) WITH NO LOG;

      CREATE INDEX iend1_temp_civil ON temp_civil(cod_sucursal);
      CREATE INDEX iend2_temp_civil ON temp_civil(cod_ramo);
--      CREATE INDEX iend3_temp_civil ON temp_civil(cod_ramo,rango_inicial);

    LET v_codramo        = NULL;
    LET v_desc_ramo      = NULL;
 --	LET _no_poliza = null;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET v_cant_polizas   = 0;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET v_prima_excedente2 = 0;
    LET v_prima_retenida = 0;
    LET v_suma_asegurada = 0;
    LET _no_poliza        = NULL;
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
--SET DEBUG FILE TO "sp_pro02b.trc";
--TRACE ON;

       FOREACH

       SELECT a.no_poliza,e.prima_suscrita,e.prima_retenida,
              a.fecha_cancelacion,a.cod_ramo,a.cod_sucursal,
              e.suma_asegurada,a.cod_tipoprod,a.no_documento,a.fecha_cancelacion,e.no_endoso
         INTO _no_poliza,v_prima_excedente2,v_prima_retenida,
              v_fecha_cancel,v_codramo,v_codsucursal,
              v_suma_asegurada2,v_cod_tipoprod,v_documento,_fecha_cancelacion,_no_endoso
         FROM emipomae a, endedmae e
	    WHERE a.cod_compania  = a_compania
	  	  AND a.cod_ramo in ('001','003')
	      AND (a.vigencia_final >= a_periodo
		   OR a.vigencia_final IS NULL)
	      AND a.fecha_suscripcion <= a_periodo
		  AND a.vigencia_inic < a_periodo
		  AND a.actualizado = 1
		  AND e.no_poliza = a.no_poliza
		  AND e.periodo <= periodo1
		  AND e.fecha_emision <= a_periodo
		  AND e.actualizado = 1

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


       LET suma_compara = 0;
       LET v_prima_excedente   = 0;
       LET v_prima_retencion   = 0;
       LET v_excedente         = 0;
       LET v_retencion         = 0;
	   LET v_suma_asegurada    = 0;

 	   IF _no_poliza is not null then
		   CALL sp_pro2c(
			 	a_compania,
			 	0,	
			 	a_periodo,
			 	_no_poliza,
				_no_endoso
			    ); 
	   END IF
	
	 END FOREACH

	 FOREACH
	   SELECT no_poliza,         
			  suma_asegurada,    
			  retencion,         
			  retencion_prima,   
			  primer_excedente,  
			  cnt_excedente,     
			  primer_exced_prima,
			  facultativo,       
			  facultativo_prima, 
			  prima_terremoto  
		 INTO ref_no_poliza,
		 	  v_suma_asegurada,	
		 	  v_retencion,  	    
		 	  v_prima_retencion,  
		 	  v_excedente,	 
		 	  _cant_exe,      
		 	  v_prima_excedente,  
		 	  v_facultativo, 
		 	  v_prima_facultativo,
			  v_prima
		 FROM temp_ubica	   

	   SELECT cod_ramo,
	          no_documento
		 INTO v_codramo,
		      v_documento
		 FROM emipomae
		WHERE no_poliza = ref_no_poliza;

	   SELECT emitipro.tipo_produccion
         INTO codigo1
         FROM emitipro,emipomae
        WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
          AND emipomae.no_poliza = ref_no_poliza;

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

       LET v_cant_coasegur1 = v_cant_coasegur1 * _cant_exe;
       LET v_cant_coasegur2 = v_cant_coasegur2 * _cant_exe;
 
   	   IF  v_suma_asegurada < 0 THEN
	       LET suma_compara = 0;
	   ELSE
	       LET suma_compara = v_suma_asegurada;
	   END IF

 	   SELECT parinfra.rango1, parinfra.rango2
              INTO v_rango_inicial,v_rango_final
              FROM parinfra
             WHERE parinfra.cod_ramo = v_codramo
               AND suma_compara >=  parinfra.rango1  
               AND suma_compara <=  parinfra.rango2;

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                    SET suma_excedente  = v_excedente + suma_excedente,
					    cant_polizas    = cant_polizas + _cant_exe,
                        prima_excedente = v_prima_excedente + prima_excedente,
						suma_retenida   = v_retencion + suma_retenida,
                        prima_retenida  = v_prima_retencion + prima_retenida,
                        cant_coasegur1  = cant_coasegur1 + v_cant_coasegur1,
                        cant_coasegur2  = cant_coasegur2 + v_cant_coasegur2
                  WHERE no_poliza = ref_no_poliza;

          END EXCEPTION

          INSERT INTO temp_civil
                VALUES(ref_no_poliza,
				       v_documento,
                       v_codsucursal,
                       v_codramo,
                       v_rango_inicial,
                       v_rango_final,
                       _cant_exe,
					   v_excedente,
                       v_prima_excedente,
					   v_retencion,
                       v_prima_retencion,
                       v_cant_coasegur1,
                       v_cant_coasegur2,
                       1);

       END
       LET v_prima_excedente   = 0;
       LET v_prima_retencion   = 0;
       LET v_excedente         = 0;
       LET v_retencion         = 0;

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
         SELECT x.no_documento,x.cod_ramo,x.rango_inicial,x.rango_final,x.cant_polizas,
                x.prima_excedente,x.prima_retenida,x.cant_coasegur1,
                x.cant_coasegur2,x.suma_excedente,x.suma_retenida
                INTO v_documento,v_codramo,v_rango_inicial,v_rango_final,v_cant_polizas,
                     v_prima_excedente2,v_prima_retenida,v_cant_coasegur1,
                     v_cant_coasegur2,v_excedente,v_retencion
                FROM temp_civil x
              WHERE  x.seleccionado = 1
               ORDER BY x.rango_inicial,no_documento

         SELECT MAX(rango1)
             INTO rango_max
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

         IF rango_max = v_rango_inicial THEN
               LET v_rango_final = -1;
         END IF;

         SELECT prdramo.nombre
                INTO v_desc_ramo
                FROM prdramo
               WHERE prdramo.cod_ramo = v_codramo;

         RETURN v_documento,
                v_rango_inicial,
         		v_rango_final,
         		v_cant_polizas,
				v_excedente / 1000,
				v_prima_excedente2,
				v_retencion / 1000,
                v_prima_retenida,
                v_cant_coasegur1,
                v_cant_coasegur2,
                v_codramo,
                v_desc_ramo,
                a_periodo,
                descr_cia,
                v_filtros WITH RESUME;
      END FOREACH

DROP TABLE temp_civil;
DROP TABLE temp_ubica;
   END
END PROCEDURE;
