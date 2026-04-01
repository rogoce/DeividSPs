----------------------------------------------
---  RANGOS DE SUMA ASEGURADA AUTOMOVIL    ---
---            POLIZAS VIGENTES            ---
---  EXCLUYENDO COASEGUROS Y CONTRATOS
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro04a
---  Mod. por Armando Moreno M. 16/11/2001
----------------------------------------------
DROP procedure sp_pro04abk;
CREATE procedure "informix".sp_pro04abk(a_compania CHAR(3),a_agencia CHAR(3),a_periodo DATE,a_codsucursal CHAR(3) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",	a_codtipoveh  CHAR(255) DEFAULT "*")

RETURNING DEC(16,2),
		  DEC(16,2),
		  INT,DEC(16,2),
          DEC(16,2),
          INT,
          CHAR(03),
          CHAR(45),
          DATE,
          CHAR(45),
          CHAR(255),
		  DEC(16,2);

BEGIN
    DEFINE v_codramo,v_codtipoveh,v_codsucursal,v_codigo    CHAR(3);
    DEFINE v_desc_ramo,descr_cia,v_desc_subramo             CHAR(45);
    DEFINE v_desc_tipoveh      						        CHAR(50);
    DEFINE v_unidades,unidades1,unidades2          			INT;
    DEFINE v_prima_suscrita,v_prima_retenida,
           v_rango_inicial,v_rango_final,v_suma_asegurada,rango_min   DECIMAL(16,2);
    DEFINE v_cant_polizas,rango_max                         INT;
    DEFINE v_fecha_cancel                          DATE;
    DEFINE _no_poliza                              CHAR(10);
    DEFINE v_filtros                               CHAR(255);
    DEFINE v_seleccionado                          SMALLINT;
    DEFINE _tipo                                   CHAR(01);
	DEFINE v_saber								   CHAR(3);
	DEFINE v_no_unidad, _no_endoso				   CHAR(5);	
	DEFINE suma_compara   						   DECIMAL(16,2);
	DEFINE _cod_contratante						   CHAR(10);
	DEFINE _asegurado							   varchar(100);
	define v_nodocumento                           char(20);
	define v_codsubramo                            char(3);
	DEFINE v_suma_uni     						   DECIMAL(16,2);
	DEFINE v_prima_sus_uni						   DECIMAL(16,2);
	DEFINE v_prima_ret_uni						   DECIMAL(16,2);
	define _no_unidad                              char(5);

    LET descr_cia = sp_sis01(a_compania);

    CREATE TEMP TABLE temp_polizat
         (no_poliza        CHAR(10),
          cod_ramo         CHAR(03),
          cod_sucursal     CHAR(03),
          rango_inicial    DECIMAL(16,2),
          rango_final      DECIMAL(16,2),
          cant_polizas     INTEGER,
          prima_suscrita   DEC(16,2),
          prima_retenida   DEC(16,2),
          unidades         INTEGER,
		  cod_tipoveh      CHAR(03) NOT NULL,
          seleccionado     SMALLINT DEFAULT 1,
          suma_asegurada   DEC(16,2),
		  asegurado        varchar(100),
          PRIMARY KEY(no_poliza,rango_inicial)) WITH NO LOG;

	   CREATE TEMP TABLE temp_poliza
	         (no_poliza        CHAR(10),
			  no_documento     CHAR(20),
			  cod_ramo         CHAR(3),
	          cod_sucursal     CHAR(03),
			  suma_asegurada   DEC(16,2),
	          prima_suscrita   DEC(16,2),
	          prima_retenida   DEC(16,2),
	          unidades         INTEGER,
	          PRIMARY KEY (no_poliza))
	          WITH NO LOG;


    LET v_codramo        = NULL;
    LET v_codsucursal    = NULL;
    LET v_codtipoveh     = NULL;
    LET v_desc_ramo      = NULL;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET v_seleccionado   = 0;
    LET _no_poliza        = NULL;
    LET v_filtros        = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_cant_polizas   = 0;
    LET v_unidades       = 0;
    LET unidades1        = 0;
    LET unidades2        = 0;

    SET ISOLATION TO DIRTY READ; 

    LET v_filtros ="";

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

       		  SELECT y.no_poliza,
			         y.no_endoso,
       		 		 y.no_documento,
               		 y.cod_sucursal,
               		 y.cod_ramo,
               		 y.cod_subramo,
               		 y.suma_asegurada
                INTO _no_poliza,
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

		 	SELECT COUNT(no_unidad)
		      INTO v_unidades
		      FROM emipouni
		     WHERE emipouni.no_poliza = _no_poliza;

	         SELECT prima_suscrita,
			 	    prima_retenida,
					suma_asegurada
	           INTO v_prima_suscrita,
					v_prima_retenida,
					v_suma_asegurada
	           FROM endedmae
	          WHERE no_poliza = _no_poliza
			    AND no_endoso = _no_endoso;    

    	BEGIN
          ON EXCEPTION IN(-239)
           		 UPDATE temp_poliza
                    SET suma_asegurada = suma_asegurada + v_suma_asegurada,
                        prima_suscrita = prima_suscrita + v_prima_suscrita,
                        prima_retenida = prima_retenida + v_prima_retenida
                  WHERE no_poliza      = _no_poliza;

          END EXCEPTION
          		  INSERT INTO temp_poliza
                  VALUES(_no_poliza,
				         v_nodocumento,
				         v_codramo,
                         v_codsucursal,
						 v_suma_asegurada,
                         v_prima_suscrita,
                         v_prima_retenida,
                         v_unidades);
    	END

	   	LET v_unidades = 0;
END FOREACH

--set debug file to "sp_pro04abk.trc";
--trace on;

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
			 v_prima_suscrita,
			 v_prima_retenida,
			 v_unidades
		FROM temp_poliza

	  foreach

		   select no_unidad    --suma_asegurada,prima_suscrita,prima_retenida
		     into _no_unidad   --v_suma_asegurada,v_prima_suscrita,v_prima_retenida
			 from emipouni
			where no_poliza = _no_poliza

				let v_suma_uni      = 0;
				let v_prima_sus_uni = 0;
				let v_prima_ret_uni = 0;

			foreach
       		  SELECT y.no_endoso
                INTO _no_endoso
                FROM temp_perfil y,emitipro z
               WHERE y.seleccionado  = 1
			  	 AND y.cod_tipoprod  = z.cod_tipoprod
			  	 AND z.tipo_produccion  IN (1,4)
			     AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')
				 and y.no_poliza = _no_poliza

              select sum(suma_asegurada),sum(prima_suscrita),sum(prima_retenida)
			    into v_suma_asegurada,v_prima_suscrita,v_prima_retenida
				from endeduni
			   where no_poliza = _no_poliza
			     and no_endoso = _no_endoso
				 and no_unidad = _no_unidad;

				if v_suma_asegurada is null then
					continue foreach;
				 end if
				let v_suma_uni      = v_suma_uni      + v_suma_asegurada;
				let v_prima_sus_uni = v_prima_sus_uni + v_prima_suscrita;
				let v_prima_ret_uni = v_prima_ret_uni + v_prima_retenida;
			end foreach

				let v_suma_asegurada = v_suma_uni     ;
				let	v_prima_suscrita = v_prima_sus_uni;
				let	v_prima_retenida = v_prima_ret_uni;


		   LET suma_compara = 0;
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

			let v_unidades = 1;

			   FOREACH
		 	       SELECT cod_tipoveh
			         INTO v_codtipoveh
			         FROM emiauto
			        WHERE emiauto.no_poliza = _no_poliza
				   EXIT FOREACH;
			   END FOREACH

			let _asegurado = '';
	        select cod_contratante into _cod_contratante from emipomae where no_poliza = _no_poliza;
			select nombre into _asegurado from cliclien where cod_cliente = _cod_contratante;


	        BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_polizat
	                SET prima_suscrita = prima_suscrita + v_prima_suscrita,
	                    prima_retenida = prima_retenida + v_prima_retenida, 
	                    suma_asegurada = suma_asegurada + v_suma_asegurada,
						unidades       = unidades + 1
	              WHERE no_poliza      = _no_poliza
	                and rango_inicial  = v_rango_inicial;

	          END EXCEPTION

			   INSERT INTO temp_polizat
	                VALUES(_no_poliza,
	                       v_codramo,
	                       v_codsucursal,
	                       v_rango_inicial,
	                       v_rango_final,
	                       1,
	                       v_prima_suscrita,
	                       v_prima_retenida,
	                       v_unidades,
						   v_codtipoveh,
	                       1,
	                       v_suma_asegurada,
	                       _asegurado);

		    END
		end foreach
END FOREACH

IF a_codtipoveh <> "*" THEN
         LET v_filtros = TRIM(v_filtros) || "Tipo de Vehic.: ";
         LET _tipo = sp_sis04(a_codtipoveh); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
            UPDATE temp_polizat
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_tipoveh NOT IN(SELECT codigo FROM tmp_codigos);
		    LET v_saber = "";
         ELSE
            UPDATE temp_polizat
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_tipoveh IN(SELECT codigo FROM tmp_codigos);
		    LET v_saber = " Ex";
         END IF

		 FOREACH
			SELECT emitiveh.nombre,tmp_codigos.codigo
              INTO v_desc_tipoveh,v_codigo
              FROM emitiveh,tmp_codigos
             WHERE emitiveh.cod_tipoveh = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_tipoveh) || " " || TRIM(v_saber);
		 END FOREACH

         DROP TABLE tmp_codigos;
END IF

FOREACH
         SELECT cod_ramo,
         		rango_inicial,
                rango_final,
                SUM(cant_polizas),
                SUM(prima_suscrita),
                SUM(prima_retenida),
                SUM(unidades),
				SUM(suma_asegurada)
           INTO v_codramo,
           		v_rango_inicial,
                v_rango_final,
                v_cant_polizas,
                v_prima_suscrita,
             	v_prima_retenida,
             	v_unidades,
				v_suma_asegurada
           FROM temp_polizat
          WHERE seleccionado = 1
          GROUP BY cod_ramo, rango_inicial, rango_final
          ORDER BY cod_ramo, rango_inicial, rango_final

		   SELECT MAX(rango1)
             INTO rango_max
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

	         IF rango_max = v_rango_inicial THEN
	               LET v_rango_final = -1;
	         END IF;

		   SELECT MIN(rango1)
             INTO rango_min
             FROM parinfra
            WHERE parinfra.cod_ramo = v_codramo;

	         IF rango_min = v_rango_inicial THEN
	               LET v_rango_inicial = -1;
	         END IF;

			SELECT prdramo.nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE prdramo.cod_ramo = v_codramo;

			RETURN v_rango_inicial,v_rango_final,v_cant_polizas,
			       v_prima_suscrita,v_prima_retenida,v_unidades,
			       v_codramo,v_desc_ramo,a_periodo,descr_cia,v_filtros,v_suma_asegurada
			       WITH RESUME;
END FOREACH

--DROP TABLE temp_polizat;
--DROP TABLE temp_perfil;
END
END PROCEDURE;
