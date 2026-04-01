----------------------------------------------
---  RANGOS DE SUMA ASEGURADA AUTOMOVIL    ---
---            POLIZAS VIGENTES            ---
---  EXCLUYENDO COASEGUROS Y CONTRATOS
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro04a
---  Mod. por Armando Moreno M. 16/11/2001
----------------------------------------------
DROP procedure sp_pro04a1;
CREATE procedure "informix".sp_pro04a1(
		a_compania 	  CHAR(3),
		a_agencia 	  CHAR(3),
		a_periodo 	  DATE,
		a_codsucursal CHAR(3) DEFAULT "*",
		a_codramo 	  CHAR(255) DEFAULT "*",
		a_codtipoveh  CHAR(255) DEFAULT "*"
		)

RETURNING DEC(16,2),
		  DEC(16,2),
		  INT,DEC(16,2),
          DEC(16,2),
          INT,
          CHAR(03),
          CHAR(45),
          DATE,
          CHAR(45),
          CHAR(255);

BEGIN
    DEFINE v_codramo,v_codtipoveh,v_codsucursal,v_codigo    CHAR(3);
    DEFINE v_desc_ramo,descr_cia,v_desc_subramo             CHAR(45);
    DEFINE v_desc_tipoveh      						        CHAR(50);
    DEFINE v_unidades,unidades1,unidades2          			INT;
    DEFINE v_prima_suscrita,v_prima_retenida,
           v_rango_inicial,v_rango_final,v_suma_asegurada,rango_min   DECIMAL(16,2);
    DEFINE v_cant_polizas,rango_max                         INT;
    DEFINE v_fecha_cancel                          DATE;
    DEFINE _no_poliza                               CHAR(10);
    DEFINE v_filtros                               CHAR(255);
    DEFINE v_seleccionado                          SMALLINT;
    DEFINE _tipo                                   CHAR(01);
	DEFINE v_saber								   CHAR(3);
	DEFINE v_no_unidad, _no_endoso				   CHAR(5);	
    LET descr_cia = sp_sis01(a_compania);

    CREATE TEMP TABLE temp_polizat
         (no_poliza        CHAR(10),
          cod_ramo         CHAR(03),
          cod_sucursal     CHAR(03),
          rango_inicial    DECIMAL(16,2),
          rango_final      DECIMAL(16,2),
          cant_polizas     INT,
          prima_suscrita   DEC(16,2),
          prima_retenida   DEC(16,2),
          unidades         INT,
		  cod_tipoveh      CHAR(03) NOT NULL,
          seleccionado     SMALLINT DEFAULT 1,
          PRIMARY KEY(no_poliza)) WITH NO LOG;

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

	LET a_codramo = '002;';

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
  

    FOREACH
	       SELECT y.no_poliza,
		          y.no_endoso,
	              y.cod_sucursal,
	              y.cod_ramo,
	              y.suma_asegurada
	         INTO _no_poliza,
			      _no_endoso,
	              v_codsucursal,
	              v_codramo,
	              v_suma_asegurada
	         FROM temp_perfil y,emitipro z
	        WHERE y.cod_tipoprod  = z.cod_tipoprod
		      AND z.tipo_produccion IN (1,4)
 		      AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')
	          AND y.seleccionado  = 1

	       SELECT b.cod_ramo,
	       		  b.rango1,
	       		  b.rango2
	         INTO v_codramo,
	         	  v_rango_inicial,
	         	  v_rango_final
	         FROM parinfra b
	        WHERE b.cod_ramo = v_codramo
	          AND v_suma_asegurada >= b.rango1 
	          AND v_suma_asegurada <= b.rango2;

           SELECT e.prima_suscrita,
				  e.prima_retenida
             INTO v_prima_suscrita,
				  v_prima_retenida
            FROM endedmae e
           WHERE e.no_poliza = _no_poliza
		     AND e.no_endoso = _no_endoso;


		   IF v_codramo IS NULL or v_rango_inicial IS NULL THEN
		      CONTINUE FOREACH;
		   END IF;

       LET unidades1 = 0;

	   IF _no_endoso = '00000' THEN
		   FOREACH
		       SELECT no_unidad
		         INTO v_no_unidad
		         FROM emipouni
		        WHERE emipouni.no_poliza = _no_poliza 

	 	       SELECT cod_tipoveh
		         INTO v_codtipoveh
		         FROM emiauto
		        WHERE emiauto.no_poliza = _no_poliza
		          AND emiauto.no_unidad = v_no_unidad;
			   LET unidades1 = unidades1 + 1;

		   END FOREACH

		END IF
        BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_polizat
                SET prima_suscrita = prima_suscrita + v_prima_suscrita,
                    prima_retenida = prima_retenida + v_prima_retenida
              WHERE no_poliza = _no_poliza ;

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
                       unidades1,
					   v_codtipoveh,
                       1);

	    END
    END FOREACH

	   --Si es flota se asume que todas las unidades seran del mismo tipo de vehiculo
 {*	BEGIN
	  DEFINE _no_poliza  CHAR(10);
		FOREACH
			SELECT no_poliza
			  INTO _no_poliza
			  FROM temp_polizat

			  LET unidades1 = 0;

		    FOREACH
		       SELECT no_unidad
		         INTO v_no_unidad
		         FROM emipouni
		        WHERE emipouni.no_poliza = _no_poliza 

		       SELECT cod_tipoveh
		         INTO v_codtipoveh
		         FROM emiauto
		        WHERE emiauto.no_poliza = _no_poliza
		          AND emiauto.no_unidad = v_no_unidad;

			   IF v_codtipoveh IS NULL THEN
		          CONTINUE FOREACH;
		       END IF;

		       LET unidades1 = unidades1 + 1; --cuenta unidades por poliza

		   END FOREACH

		   UPDATE temp_polizat
		      SET unidades = unidades1
			WHERE no_poliza = _no_poliza;

		END FOREACH
	END*}

    LET v_filtros ="";

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
                cant_polizas,
                prima_suscrita,
                prima_retenida,
                unidades
           INTO v_codramo,
           		v_rango_inicial,
                v_rango_final,
                v_cant_polizas,
                v_prima_suscrita,
             	v_prima_retenida,
             	v_unidades
           FROM temp_polizat
          WHERE seleccionado = 1
 --         GROUP BY cod_ramo, rango_inicial, rango_final
--          ORDER BY cod_ramo, rango_inicial, rango_final

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
			       v_codramo,v_desc_ramo,a_periodo,descr_cia,v_filtros
			       WITH RESUME;
    	END FOREACH

	DROP TABLE temp_polizat;
END
END PROCEDURE;
