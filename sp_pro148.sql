--------------------------------------------
---  RANGOS DE SUMA ASEGURADA 1ER. EXCEDENTE   ---
---  INCENDIO Y MULTIRIESGO POLIZA VIGENTES    ---
---  Creado por Amado Perez Octubre 2001 	   ---
---  Corregido el 29/11/2001                   ---
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------

DROP procedure sp_pro148;

CREATE procedure "informix".sp_pro148(a_compania CHAR(3),a_agencia CHAR(255) DEFAULT "*",a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")
RETURNING char(20),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  smallint;

  --------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES            ---
---  EXCLUYENDO COASEGUROS Y CONTRATOS
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_prod_sp_pro04
----------------------------------------------

    DEFINE v_codramo,v_codsubramo,v_codsucursal    CHAR(3);
    DEFINE v_desc_ramo,descr_cia  				   CHAR(45);
    DEFINE v_unidades,unidades1,unidades2          SMALLINT;
    DEFINE v_prima_suscrita,v_prima_retenida,
           v_rango_inicial,v_rango_final,v_suma_asegurada,
		   _prima_suscrita,_prima_retenida,rango_min, suma_compara   DECIMAL(16,2);
    DEFINE v_cant_polizas,tot_cant                 SMALLINT;
    DEFINE v_fecha_cancel   DATE;
    DEFINE _no_poliza        CHAR(10);
	DEFINE _no_endoso       CHAR(5);
    DEFINE _tipo            CHAR(01);
    DEFINE v_filtros        CHAR(255);
    DEFINE v_seleccionado   SMALLINT;
    DEFINE v_nodocumento    CHAR(20);
    DEFINE rango_max        INTEGER;

       CREATE TEMP TABLE temp_polizav
             (cod_ramo         CHAR(03),
              cod_sucursal     CHAR(03),
              rango_inicial    DECIMAL(16,2),
              rango_final      DECIMAL(16,2),
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              unidades         INT,
              seleccionado     SMALLINT DEFAULT 1,
			  suma_asegurada   dec(16,2),	
              PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

	   CREATE TEMP TABLE temp_cant
             (no_documento     CHAR(20),
              cod_ramo         CHAR(03),
              cod_sucursal     CHAR(03),
              rango_inicial    DECIMAL(16,2),
              cant_polizas     INT,
              seleccionado     SMALLINT DEFAULT 1,
              PRIMARY KEY (no_documento,cod_ramo,rango_inicial)) WITH NO LOG;

	   CREATE TEMP TABLE temp_poliza
	         (no_poliza        CHAR(10),
			  no_documento     CHAR(20),
			  cod_ramo         CHAR(3),
	          cod_sucursal     CHAR(03),
			  suma_asegurada   DEC(16,2),
	          prima_suscrita   DEC(16,2),
	          prima_retenida   DEC(16,2),
	          unidades         INT,
	          PRIMARY KEY (no_poliza))
	          WITH NO LOG;

    LET v_codramo        = NULL;
    LET v_codsucursal    = NULL;
    LET v_desc_ramo      = NULL;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET descr_cia        = NULL;
    LET _no_poliza        = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita = 0;
    LET _prima_retenida = 0;
    LET v_cant_polizas   = 0;
    LET v_unidades       = 0;
    LET v_seleccionado   = 1;
    LET v_filtros        = NULL;
    LET unidades1        = 0;
    LET unidades2        = 0;
    LET tot_cant         = 0;
 
    LET descr_cia = sp_sis01(a_compania);
    CALL sp_pro83(a_compania,a_agencia,a_periodo,a_codramo) RETURNING v_filtros;

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

       		 SELECT  y.no_poliza,
			         y.no_endoso,
       		 		 y.no_documento,
               		 y.cod_sucursal,
               		 y.cod_ramo,
               		 y.cod_subramo,
               		 y.suma_asegurada
               INTO  _no_poliza,
			         _no_endoso,
               		 v_nodocumento,
                     v_codsucursal,
                     v_codramo,
                     v_codsubramo,
                     v_suma_asegurada
                FROM temp_perfil y,emitipro z
               WHERE y.seleccionado  = 1
			  	 AND y.cod_tipoprod  = z.cod_tipoprod
			  	 AND z.tipo_produccion  IN (1,4)
			     AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')

{	          SELECT b.rango1,b.rango2
	            INTO v_rango_inicial,v_rango_final
	            FROM parinfra b
	           WHERE v_suma_asegurada >= b.rango1 
	             AND v_suma_asegurada <= b.rango2
	             AND b.cod_ramo = v_codramo ;}

--		       IF v_rango_inicial IS NULL OR
--		          v_nodocumento   IS NULL THEN
--			      CONTINUE FOREACH;
--			   END IF


			 IF _no_endoso = '00000' THEN
				 FOREACH
				 	SELECT emipouni.no_unidad
				      INTO unidades1
				      FROM emipouni
				     WHERE emipouni.no_poliza = _no_poliza
				     LET v_unidades = v_unidades + 1;
				 END FOREACH
			 END IF

	         SELECT prima_suscrita,
			 	    prima_retenida,
					suma_asegurada
	           INTO _prima_suscrita,
					_prima_retenida,
					v_suma_asegurada
	            FROM endedmae
	           WHERE no_poliza = _no_poliza
			     AND no_endoso = _no_endoso;    

    	BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_poliza
                    SET suma_asegurada = suma_asegurada + v_suma_asegurada,
                        prima_suscrita = prima_suscrita + _prima_suscrita,
                        prima_retenida = prima_retenida + _prima_retenida,
                        unidades       = unidades + v_unidades
                  WHERE no_poliza      = _no_poliza;

          END EXCEPTION
          INSERT INTO temp_poliza
                  VALUES(_no_poliza,
				         v_nodocumento,
				         v_codramo,
                         v_codsucursal,
						 v_suma_asegurada,
                         _prima_suscrita,
                         _prima_retenida,
                         v_unidades);
    	END


    	LET v_unidades = 0;

       END FOREACH

     FOREACH
	  SELECT no_poliza,  
	         no_documento,   
	         cod_ramo,
			 cod_sucursal,  
			 suma_asegurada,
			 prima_suscrita,
			 prima_retenida,
			 unidades 
		INTO _no_poliza,
		     v_nodocumento,
			 v_codramo,
			 v_codsucursal,     
			 v_suma_asegurada,
			 _prima_suscrita,
			 _prima_retenida,
			 v_unidades
		FROM temp_poliza
	   where suma_asegurada > 50000
		

		return v_nodocumento,
			   v_suma_asegurada,
			   _prima_suscrita,
			   _prima_retenida,
			   v_unidades
			   with resume;
			


{
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
             UPDATE temp_polizav
                    SET prima_suscrita = prima_suscrita + _prima_suscrita,
                        prima_retenida = prima_retenida + _prima_retenida,
                        unidades       = unidades       + v_unidades,
						suma_asegurada = suma_asegurada + suma_compara
                  WHERE cod_ramo       = v_codramo
                    AND rango_inicial  = v_rango_inicial;

          END EXCEPTION
          INSERT INTO temp_polizav
                  VALUES(v_codramo,
                         v_codsucursal,
                         v_rango_inicial,
                         v_rango_final,
                         _prima_suscrita,
                         _prima_retenida,
                         v_unidades,
                         1,
                         suma_compara);
		END 

    	BEGIN
		  		ON EXCEPTION IN(-239)
	            -- No hace nada
	          	END EXCEPTION
	          	INSERT INTO temp_cant
	                  VALUES(v_nodocumento,
	                         v_codramo,
	                         v_codsucursal,
	                         v_rango_inicial,
	                         1,
	                         1);

    	END; 

	  END FOREACH

      FOREACH
         SELECT temp_polizav.*
           INTO v_codramo,
           		v_codsucursal,
           		v_rango_inicial,
           		v_rango_final,
                v_prima_suscrita,
                v_prima_retenida,
                v_unidades,
                v_seleccionado,
				v_suma_asegurada
           FROM temp_polizav
          WHERE seleccionado = 1
       ORDER BY cod_ramo,rango_inicial

		 FOREACH
	       SELECT cant_polizas
	         INTO v_cant_polizas
	 	     FROM temp_cant
		    WHERE cod_ramo      = v_codramo
		      AND rango_inicial = v_rango_inicial 
	      
		      LET tot_cant = tot_cant + v_cant_polizas;  

	     END FOREACH 

		   SELECT MAX(rango1)
             INTO rango_max
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

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

		   SELECT prdramo.nombre
	         INTO v_desc_ramo
	         FROM prdramo
	        WHERE prdramo.cod_ramo = v_codramo;

       	   RETURN v_rango_inicial,
       	   		  v_rango_final,
       	   		  tot_cant,
               	  v_prima_suscrita,
               	  v_prima_retenida,
               	  v_unidades,
                  v_codramo,
                  v_desc_ramo,
                  a_periodo,
                  descr_cia,
                  v_filtros,
				  v_suma_asegurada / v_unidades
              WITH RESUME;

      	   LET tot_cant = 0;
}

     END FOREACH

DROP TABLE temp_polizav;
DROP TABLE temp_poliza;
DROP TABLE temp_perfil;
DROP TABLE temp_cant;

END PROCEDURE;