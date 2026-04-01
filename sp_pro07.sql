   DROP procedure sp_pro07;
   CREATE procedure sp_pro07(
   			a_cia 		  CHAR(03),
   			a_agencia 	  CHAR(255) DEFAULT "*",
   			a_codsucursal CHAR(255) DEFAULT "*",
   			a_codramo 	  CHAR(255) DEFAULT "*",
   			a_periodo 	  DATE
   			)

   RETURNING CHAR(3),
   			 CHAR(3),
   			 CHAR(50),
   			 CHAR(50),
   			 INT,
   			 DATE,
   			 CHAR(255);
--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro07
--------------------------------------------
BEGIN

    DEFINE v_codramo,v_codsubramo,v_codsucursal    CHAR(3);
    DEFINE v_desc_ramo,v_desc_subramo,v_filtros    CHAR(255);
    DEFINE v_unidades,unidades2                    INT;
    DEFINE v_no_poliza                             CHAR(10);
    DEFINE _tipo                                   CHAR(01);
	DEFINE v_no_unidad                             CHAR(5);
	define _no_endoso							   char(10);
	define unidades1                               integer;

       CREATE TEMP TABLE temp_unidad_sub
             (cod_ramo         CHAR(3),
              cod_subramo      CHAR(3),
              cod_sucursal     CHAR(3),
              unidades         INT,
              seleccionado     SMALLINT DEFAULT 1,
			  no_poliza        CHAR(10),
              PRIMARY KEY(no_poliza))WITH NO LOG;

    CREATE INDEX i1_perfil ON temp_unidad_sub(cod_subramo);
    CREATE INDEX i2_perfil ON temp_unidad_sub(cod_sucursal);

    LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_codramo);
	--LET v_filtros = sp_pro83(a_cia,a_agencia,a_periodo,a_codramo);

    LET v_codsubramo   = NULL;
    LET v_codramo      = NULL;
    LET v_desc_subramo = NULL;
    LET v_desc_ramo    = NULL;
    LET v_unidades     = 0;
    LET unidades2      = 0;

    SET ISOLATION TO DIRTY READ;
FOREACH
       SELECT y.no_poliza,
       		  y.cod_sucursal,
       		  y.cod_ramo,
       		  y.cod_subramo
         INTO v_no_poliza,
         	  v_codsucursal,
         	  v_codramo,
         	  v_codsubramo
         FROM temp_perfil y,emitipro z
        WHERE y.cod_tipoprod = z.cod_tipoprod
		  AND z.tipo_produccion IN (1,4)
 		  AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')
          AND y.seleccionado = 1

       IF v_codramo IS NULL THEN
          CONTINUE FOREACH;
       END IF

	
       SELECT COUNT(no_unidad)
         INTO v_unidades
         FROM emipouni
        WHERE emipouni.no_poliza = v_no_poliza;

       IF v_unidades IS NULL OR v_unidades = 0  THEN
          LET v_unidades = 0;
          CONTINUE FOREACH;
       END IF;						  

{       SELECT COUNT(emifacon.no_unidad)
         INTO unidades2
         FROM emifacon,reacomae
        WHERE emifacon.no_poliza     = v_no_poliza
          AND emifacon.cod_contrato  = reacomae.cod_contrato
          AND reacomae.tipo_contrato = 2;

       IF unidades2 > 0 OR unidades2 IS NULL THEN
          CONTINUE FOREACH;
       END IF;							  

       SELECT COUNT(*)
         INTO v_unidades
         FROM emipouni
        WHERE emipouni.no_poliza = v_no_poliza;

       IF v_unidades IS NULL OR v_unidades = 0  THEN
          LET v_unidades = 0;
          CONTINUE FOREACH;
       END IF;							  }

	BEGIN
          ON EXCEPTION IN(-239)
            { UPDATE temp_unidad_sub
                SET unidades       = unidades + v_unidades
              WHERE cod_ramo     = v_codramo
                AND cod_subramo  = v_codsubramo;}
			  CONTINUE FOREACH;

          END EXCEPTION
          INSERT INTO temp_unidad_sub
              VALUES(v_codramo,
                     v_codsubramo,
                     v_codsucursal,
                     v_unidades,
                     1,
                     v_no_poliza);
    END

END FOREACH

	IF a_codramo <> "*" THEN
        LET v_filtros ="";
        LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
	END IF;

     -- Procesos v_filtros

    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agencia "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_unidad_sub
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_unidad_sub
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    FOREACH
       SELECT y.cod_ramo,
       		  y.cod_subramo,
       		  SUM(y.unidades)
         INTO v_codramo,
         	  v_codsubramo,
         	  v_unidades
         FROM temp_unidad_sub y
        WHERE y.seleccionado = 1
     GROUP BY y.cod_ramo,y.cod_subramo
     ORDER BY y.cod_ramo,y.cod_subramo

        SELECT a.nombre
          INTO v_desc_ramo
          FROM prdramo a
         WHERE a.cod_ramo  = v_codramo;

      { SELECT prdsubra.nombre
         INTO v_desc_subramo
         FROM prdsubra,prdramo
        WHERE prdsubra.cod_subramo = v_codsubramo
          AND prdsubra.cod_ramo    = v_codramo;}

	   SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_subramo = v_codsubramo
          AND cod_ramo    = v_codramo;

       RETURN v_codramo,v_codsubramo,v_desc_ramo,v_desc_subramo,v_unidades,
              a_periodo,v_filtros WITH RESUME;

    END FOREACH

DROP TABLE temp_unidad_sub;
DROP TABLE temp_perfil;
END
END PROCEDURE;