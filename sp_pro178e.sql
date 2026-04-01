   --DROP procedure sp_pro178;
   CREATE procedure "informix".sp_pro178e()

   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---
---  Amado Perez M. 02/02/2007
---  Ref. Power Builder 
--------------------------------------------


    CREATE TEMP TABLE temp_cobert(
              cod_ramo        CHAR(3),
              cod_subramo     CHAR(3), 
			  cod_cobertura   CHAR(5),
			  prima_bruta     DEC(16,2),
			  incurrido_bruto DEC(16,2)
              PRIMARY KEY(cod_ramo,cod_subramo,cod_cobertura)) WITH NO LOG;


FOREACH
   SELECT no_poliza,
   		  cod_ramo,
   		  cod_subramo
     INTO _no_poliza,
     	  v_cod_ramo,
     	  v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1
	  AND cod_ramo = '002'
	  AND cod_subramo IN ('001','002')

	 FOREACH
	  SELECT cod_cobertura,
	         prima_neta
	    INTO _cod_cobertura,
		     _prima_neta
	    FROM tmp_cobp
	   WHERE no_poliza = _no_poliza

	   BEGIN
	      ON EXCEPTION IN(-239)
	         UPDATE temp_cobert
	            SET prima_bruta   = prima_bruta + _prima_neta
	          WHERE cod_ramo       = v_cod_ramo
	            AND cod_subramo    = v_cod_subramo
	            AND cod_cobertura  = _cod_cobertura;

	      END EXCEPTION
	      INSERT INTO temp_cobert
	          VALUES(v_cod_ramo,
	                 v_cod_subramo,
					 _cod_cobertura,
	                 _prima_neta,
					 0
	                 );
	   END
		
	 END FOREACH

	 FOREACH
	  SELECT cod_cobertura,
	         pagado_bruto
	    INTO _cod_cobertura,
		     _pagado_bruto
	    FROM tmp_inc_cob
	   WHERE no_poliza = _no_poliza

	   BEGIN
	      ON EXCEPTION IN(-239)
	         UPDATE temp_cobert
	            SET incurrido_bruto  = incurrido_bruto + pagado_bruto
	          WHERE cod_ramo       = v_cod_ramo
	            AND cod_subramo    = v_cod_subramo
	            AND cod_cobertura  = _cod_cobertura;

	      END EXCEPTION
	      INSERT INTO temp_cobert
	          VALUES(v_cod_ramo,
	                 v_cod_subramo,
					 _cod_cobertura,
	                 0,
					 incurrido_bruto
	                 );
	   END
		
	 END FOREACH


END FOREACH
  

END PROCEDURE;
