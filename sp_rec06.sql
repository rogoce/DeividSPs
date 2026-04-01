DROP procedure sp_rec06;
CREATE procedure "informix".sp_rec06(a_compania CHAR(3),a_agencia CHAR(03),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*",a_codtipoveh CHAR(255) DEFAULT "*")

RETURNING CHAR(255);
--------------------------------------------
---  ANALISIS DE RECLAMOS POR AUTO       ---
---           PARA AUTO
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado Junio,2001 - Amado Perez
---  Ref. Power Builder - d_sp_rec06
--------------------------------------------

    DEFINE v_nopoliza,v_noreclamo,y_no_reclamo  CHAR(10);
    DEFINE v_cod_ramo,v_cod_subramo         	CHAR(3);
    DEFINE v_cod_grupo                      	CHAR(5);
    DEFINE v_rec_abierto,v_rec_cerrado      	INT;
	DEFINE no_trans, v_tranreclamo          	INT;
    DEFINE v_incurrido_bruto,v_incurrido_neto,v_incurrido_abierto 	DECIMAL(16,2);
    DEFINE v_nounidad                       	CHAR(5);
    DEFINE v_tipoveh                        	CHAR(3);
    DEFINE v_filtros                        	CHAR(255);
    DEFINE _tipo                            	CHAR(1);

    CREATE TEMP TABLE temp_reclamo
                (cod_ramo      CHAR(3),
                 cod_subramo   CHAR(3),
                 cod_grupo     CHAR(5),
                 cod_tipoveh   CHAR(03),
                 rec_abierto   INT,
                 rec_cerrado   INT,
                 no_tranreclamo INT,
                 incurrido_bruto   DECIMAL(16,2),
                 incurrido_neto    DECIMAL(16,2),
				 incurrido_abierto DECIMAL(16,2),
                 seleccionado     SMALLINT DEFAULT 1,
                 PRIMARY KEY (cod_ramo,cod_subramo,cod_grupo,cod_tipoveh)) 
                              WITH NO LOG;

    CREATE INDEX irec1_temp_reclamo ON temp_reclamo(cod_ramo);
    CREATE INDEX irec2_temp_reclamo ON temp_reclamo(cod_subramo);
    CREATE INDEX irec3_temp_reclamo ON temp_reclamo(cod_grupo);
    CREATE INDEX irec4_temp_reclamo ON temp_reclamo(cod_tipoveh);

    LET v_nopoliza   = NULL;
    LET v_noreclamo  = NULL;
    LET v_cod_ramo    = NULL;
    LET v_cod_subramo = NULL;
    LET v_cod_grupo   = NULL;
    LET no_trans     = 0;
    LET v_incurrido_bruto    = 0;
    LET v_incurrido_neto     = 0;
    LET v_incurrido_abierto  = 0;
    LET v_rec_abierto        = 0;
    LET v_rec_cerrado        = 0;
    LET v_tranreclamo        = 0;
	LET a_codramo = '002;';

	set isolation to dirty read;
	
    CALL sp_rec01(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,
                  a_codgrupo,a_codramo,a_codagente,a_codsubramo)
                  RETURNING v_filtros;

    FOREACH

       SELECT no_poliza,
       		  no_reclamo,
       		  cod_ramo,
       		  cod_subramo,
       		  cod_grupo,
              incurrido_bruto,
              incurrido_neto,
              incurrido_abierto
         INTO v_nopoliza,
         	  v_noreclamo,
         	  v_cod_ramo,
         	  v_cod_subramo,
         	  v_cod_grupo,
              v_incurrido_bruto,
              v_incurrido_neto,
              v_incurrido_abierto
         FROM tmp_sinis
        WHERE seleccionado = 1

       SELECT no_unidad
         INTO v_nounidad
         FROM recrcmae
        WHERE no_poliza  = v_nopoliza
          AND no_reclamo = v_noreclamo;

	   SELECT cod_tipoveh
	     INTO v_tipoveh
	     FROM emiauto
	    WHERE no_poliza = v_nopoliza
	      AND no_unidad = v_nounidad;

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_endoso = "00000"
		           AND no_unidad = v_nounidad;
			END IF

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
			  FOREACH
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_unidad = v_nounidad
				EXIT FOREACH;
			  END FOREACH
			END IF
       IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
	     LET v_tipoveh = '000';
--         CONTINUE FOREACH;
       END IF 
-- Conteo de Reclamos Cerrados          

 {      FOREACH

    	 SELECT no_reclamo
    	   INTO y_no_reclamo
		   FROM rectrmae
    	  WHERE cod_compania = a_compania
            AND cod_sucursal = a_agencia
            AND no_reclamo   = v_noreclamo
            AND periodo     >= a_periodo1
  		    AND periodo     <= a_periodo2
   		    AND actualizado = 1
			AND cerrar_rec  = 1
		  GROUP BY no_reclamo

 	     IF y_no_reclamo IS NOT NULL THEN
	        LET v_rec_cerrado= v_rec_cerrado + 1;
   		 END IF		  
	   END FOREACH

       IF v_rec_cerrado IS NULL THEN
          LET v_rec_cerrado = 0;
       END IF;}

-- Conteo de Transacciones de Reclamos

  {     FOREACH
		 SELECT no_reclamo
		       INTO y_no_reclamo
		       FROM rectrmae
		      WHERE cod_compania  = a_compania
		        AND cod_sucursal  = a_agencia
				AND periodo >= a_periodo1
				AND periodo <= a_periodo2
				AND no_reclamo = v_noreclamo
				AND actualizado = 1

		 IF y_no_reclamo IS NOT NULL THEN 
         	LET v_tranreclamo = v_tranreclamo + 1;
		 END IF
 	   END FOREACH}

   --    IF v_tranreclamo IS NULL THEN
   --       LET v_tranreclamo = 0;
   --    END IF;

       IF v_cod_ramo IS NULL THEN
	      CONTINUE FOREACH;
	   END IF

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_reclamo
                SET incurrido_bruto   = incurrido_bruto + v_incurrido_bruto,
                    incurrido_neto    = incurrido_neto  + v_incurrido_neto,
                    incurrido_abierto = incurrido_abierto + v_incurrido_abierto,
                    rec_abierto       = rec_abierto     + v_rec_abierto,
                    rec_cerrado       = rec_cerrado     + v_rec_cerrado,
                    no_tranreclamo    = no_tranreclamo  + v_tranreclamo
              WHERE cod_ramo          = v_cod_ramo
                AND cod_subramo       = v_cod_subramo
                AND cod_grupo         = v_cod_grupo
                AND cod_tipoveh       = v_tipoveh;

          END EXCEPTION
          INSERT INTO temp_reclamo
               VALUES(v_cod_ramo,
                      v_cod_subramo,
                      v_cod_grupo,
                      v_tipoveh,
                      v_rec_abierto,
                      v_rec_cerrado,
                      v_tranreclamo,
                      v_incurrido_bruto,
                      v_incurrido_neto,
                      v_incurrido_abierto,
                      1);
       END

    LET no_trans             = 0;
    LET v_incurrido_bruto    = 0;
    LET v_incurrido_neto     = 0;
    LET v_incurrido_abierto  = 0;
    LET v_rec_abierto        = 0;
    LET v_rec_cerrado        = 0;
    LET v_tranreclamo        = 0;
    END FOREACH;


--	   Conteo de Reclamos Abiertos 
	   FOREACH

     	    SELECT a.no_reclamo, a.no_unidad, b.cod_ramo, b.cod_subramo, b.cod_grupo, b.no_poliza
              INTO y_no_reclamo, v_nounidad, v_cod_ramo, v_cod_subramo, v_cod_grupo, v_nopoliza
              FROM recrcmae a, emipomae b
             WHERE b.no_poliza = a.no_poliza
               AND a.cod_compania = a_compania
               AND a.cod_sucursal = a_agencia
               AND a.periodo   >= a_periodo1
			   AND a.periodo   <= a_periodo2
			   AND a.actualizado = 1

	        SELECT cod_tipoveh
	          INTO v_tipoveh
	          FROM emiauto
	         WHERE no_poliza = v_nopoliza
	           AND no_unidad = v_nounidad;

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_endoso = "00000"
		           AND no_unidad = v_nounidad;
			END IF

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
			  FOREACH
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_unidad = v_nounidad
				EXIT FOREACH;
			  END FOREACH
			END IF
            
	       IF v_tipoveh IS NULL THEN
	         LET v_tipoveh = '000';
	     --    CONTINUE FOREACH;
	       END IF 
 
          IF y_no_reclamo IS NOT NULL THEN
            LET v_rec_abierto = 1;
		  ELSE
		    LET v_rec_abierto = 0;
		  END IF


         UPDATE temp_reclamo
            SET rec_abierto   = rec_abierto + v_rec_abierto
          WHERE cod_ramo      = v_cod_ramo
            AND cod_subramo   = v_cod_subramo
            AND cod_grupo     = v_cod_grupo
            AND cod_tipoveh   = v_tipoveh;

	   END FOREACH

-- Conteo de Reclamos Cerrados          

       FOREACH
		 SELECT c.no_reclamo
		   INTO y_no_reclamo
		   FROM recrcmae a, emipomae b, rectrmae c
		  WHERE c.cod_compania  = a_compania
		    AND c.cod_sucursal  = a_agencia
		 	AND c.periodo >= a_periodo1
			AND c.periodo <= a_periodo2
			AND a.no_reclamo = c.no_reclamo
			AND b.no_poliza = a.no_poliza
			AND c.cerrar_rec  = 1
			AND c.actualizado = 1
		  GROUP BY c.no_reclamo

 		SELECT a.no_unidad, b.cod_ramo, b.cod_subramo, b.cod_grupo, b.no_poliza
 		  INTO v_nounidad, v_cod_ramo, v_cod_subramo, v_cod_grupo, v_nopoliza
          FROM recrcmae a, emipomae b
         WHERE a.no_reclamo   = y_no_reclamo 
           AND b.no_poliza    = a.no_poliza;

	        SELECT cod_tipoveh
	          INTO v_tipoveh
	          FROM emiauto
	         WHERE no_poliza = v_nopoliza
	           AND no_unidad = v_nounidad;

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_endoso = "00000"
		           AND no_unidad = v_nounidad;
			END IF

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
			  FOREACH
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_unidad = v_nounidad
				EXIT FOREACH;
			  END FOREACH
			END IF
            
	       IF v_tipoveh IS NULL THEN
	         LET v_tipoveh = '000';
	     --    CONTINUE FOREACH;
	       END IF 
 
          IF y_no_reclamo IS NOT NULL THEN
            LET v_rec_cerrado = 1;
		  ELSE
		    LET v_rec_cerrado = 0;
		  END IF


         UPDATE temp_reclamo
            SET rec_cerrado   = rec_cerrado + v_rec_cerrado
          WHERE cod_ramo      = v_cod_ramo
            AND cod_subramo   = v_cod_subramo
            AND cod_grupo     = v_cod_grupo
            AND cod_tipoveh   = v_tipoveh;

 	   END FOREACH

-- Conteo de Transacciones de Reclamos

       FOREACH
		 SELECT c.no_reclamo, a.no_unidad, b.cod_ramo, b.cod_subramo, b.cod_grupo, b.no_poliza
		   INTO y_no_reclamo, v_nounidad, v_cod_ramo, v_cod_subramo, v_cod_grupo, v_nopoliza
		   FROM recrcmae a, emipomae b, rectrmae c
		  WHERE c.cod_compania  = a_compania
		    AND c.cod_sucursal  = a_agencia
		 	AND c.periodo >= a_periodo1
			AND c.periodo <= a_periodo2
			AND a.no_reclamo = c.no_reclamo
			AND b.no_poliza = a.no_poliza
			AND c.actualizado = 1

	        SELECT cod_tipoveh
	          INTO v_tipoveh
	          FROM emiauto
	         WHERE no_poliza = v_nopoliza
	           AND no_unidad = v_nounidad;

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_endoso = "00000"
		           AND no_unidad = v_nounidad;
			END IF

			IF v_tipoveh IS NULL OR v_tipoveh = '' THEN
			  FOREACH
		        SELECT cod_tipoveh
		          INTO v_tipoveh
		          FROM endmoaut
		         WHERE no_poliza = v_nopoliza
		           AND no_unidad = v_nounidad
				EXIT FOREACH;
			  END FOREACH
			END IF
            
	       IF v_tipoveh IS NULL THEN
	         LET v_tipoveh = '000';
	     --    CONTINUE FOREACH;
	       END IF 
 
          IF y_no_reclamo IS NOT NULL THEN
            LET v_tranreclamo = 1;
		  ELSE
		    LET v_tranreclamo = 0;
		  END IF


         UPDATE temp_reclamo
            SET no_tranreclamo = no_tranreclamo + v_tranreclamo
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo
            AND cod_grupo      = v_cod_grupo
            AND cod_tipoveh    = v_tipoveh;

 	   END FOREACH


    IF a_codtipoveh <> "*" THEN
        LET v_filtros = TRIM(v_filtros) || "Tipo Vehiculo " ||
                        TRIM(a_codtipoveh);

        LET _tipo = sp_sis04(a_codtipoveh);
        -- Separa los Valores del String en una tabla de codigos

        IF _tipo <> "E" THEN -- Incluir los Registros
                UPDATE temp_reclamo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_tipoveh NOT IN (SELECT codigo FROM tmp_codigos);
        ELSE                    -- Excluir estos Registros
                UPDATE temp_reclamo
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_tipoveh IN (SELECT codigo FROM tmp_codigos);
        END IF
    DROP TABLE tmp_codigos;
    END IF
    RETURN v_filtros;
END PROCEDURE