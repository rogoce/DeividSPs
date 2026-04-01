DROP procedure tipoveh;
CREATE procedure "informix".tipoveh()

RETURNING CHAR(3),
		  CHAR(3),
		  CHAR(5),
		  CHAR(10),
		  CHAR(20),
		  CHAR(5),
		  CHAR(100),
		  CHAR(50),
		  CHAR(50);

--------------------------------------------
---  PROGRAMA QUE BARRE LA TABLA EMIPOMAE --
---  Y BUSCA TODAS AQUELLAS CUYO RAMO SEA 			 Amado
---  AUTOMOVIL Y NO TENGAN TIPO DE VEHICULO
--------------------------------------------

    DEFINE v_nopoliza 				            CHAR(10);
	DEFINE v_nodocumento						CHAR(20);
    DEFINE v_cod_ramo,v_cod_subramo         	CHAR(3);
    DEFINE v_cod_grupo                      	CHAR(5);
    DEFINE v_nounidad                       	CHAR(5);
    DEFINE v_tipoveh                        	CHAR(3);
	DEFINE _cod_asegurado                       CHAR(10);
	DEFINE v_asegurado                          CHAR(100);
	DEFINE v_subramo, v_grupo                   CHAR(50);

  {  CREATE TEMP TABLE temp_tipoveh
                (cod_ramo      CHAR(3),
                 cod_subramo   CHAR(3),
                 cod_grupo     CHAR(5),
				 no_poliza     CHAR(10),
				 no_documento  CHAR(20),
				 no_unidad     CHAR(5)
                 PRIMARY KEY (cod_ramo,cod_subramo,cod_grupo) 
                              WITH NO LOG;

    CREATE INDEX irec1_temp_reclamo ON temp_reclamo(cod_ramo);
    CREATE INDEX irec2_temp_reclamo ON temp_reclamo(cod_subramo);
    CREATE INDEX irec3_temp_reclamo ON temp_reclamo(cod_grupo);}

    LET v_nopoliza   = NULL;
    LET v_cod_ramo    = NULL;
    LET v_cod_subramo = NULL;
    LET v_cod_grupo   = NULL;


    FOREACH

       SELECT a.no_poliza, a.no_documento, a.cod_ramo, a.cod_subramo, a.cod_grupo
         INTO v_nopoliza,v_nodocumento,v_cod_ramo,v_cod_subramo,v_cod_grupo
         FROM emipomae a, recrcmae b
		WHERE a.cod_ramo = '002'
		  AND b.no_poliza = a.no_poliza
		  AND a.actualizado = 1
		  AND a.estatus_poliza = 1

	    IF v_nopoliza IS NULL THEN
	       CONTINUE FOREACH;
	    END	IF

	   FOREACH

			SELECT no_unidad,
			       cod_asegurado
              INTO v_nounidad,
			       _cod_asegurado
              FROM emipouni
             WHERE no_poliza  = v_nopoliza

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

		      SELECT nombre
				INTO v_asegurado
				FROM cliclien
			   WHERE cod_cliente = _cod_asegurado;

			  SELECT nombre
			    INTO v_subramo
				FROM prdsubra
			   WHERE cod_ramo = v_cod_ramo
			     AND cod_subramo = v_cod_subramo;

              SELECT nombre
			    INTO v_grupo
				FROM cligrupo
			   WHERE cod_grupo =  v_cod_grupo;

			  RETURN v_cod_ramo,
					 v_cod_subramo,
					 v_cod_grupo,
					 v_nopoliza,
					 v_nodocumento,
					 v_nounidad,
					 v_asegurado,
					 v_subramo,
					 v_grupo WITH RESUME;


				
  {	          INSERT INTO temp_tipoveh
	               VALUES(v_cod_ramo,
	                      v_cod_subramo,
	                      v_cod_grupo,
						  v_nopoliza,
						  v_nodocumento,
	                      v_nounidad);}

	       END IF 

	   END FOREACH

	END FOREACH

END PROCEDURE
