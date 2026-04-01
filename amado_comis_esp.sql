-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf80;
CREATE PROCEDURE "informix".comis_especial(a_requis CHAR(10)) 
			RETURNING CHAR(5), 
					  VARCHAR(50),
					  CHAR(3),
					  VARCHAR(50),
					  DEC(5,2),
					  CHAR(8),
					  DATE,
					  CHAR(3),
					  VARCHAR(50),
					  DEC(5,2),
					  CHAR(8),
			  		  DATE;

DEFINE _cod_agente     CHAR(5); 
DEFINE _nombre_agente  VARCHAR(50);
DEFINE _cod_ramo       CHAR(3);
DEFINE _nombre_ramo    VARCHAR(50);
DEFINE _porc_comis_agt DEC(5,2);
DEFINE _user_added	   CHAR(8);
DEFINE _date_added     DATE;
DEFINE _cod_subramo	   CHAR(3);
DEFINE _nombre_subra   VARCHAR(50);
DEFINE _porc_comision  DEC(5,2);
DEFINE _user_added_s   CHAR(8);
DEFINE _date_added_s   DATE;
DEFINE _cant           INT;

--SET LOCK MODE TO WAIT;
SET ISOLATION TO DIRTY READ;

FOREACH
	  SELECT agtagent.cod_agente,   
	         agtagent.nombre,   
	         agtcomra.cod_ramo,   
	         agtcomra.porc_comis_agt,   
	         prdramo.nombre,   
	         agtcomra.user_added,   
	         agtcomra.date_added
	    INTO _cod_agente, 
			 _nombre_agente,
			 _cod_ramo,
			 _porc_comis_agt,
			 _nombre_ramo,
			 _user_added,
			 _date_added
	    FROM agtagent,   
	         agtcomra,   
	         prdramo  
	   WHERE ( agtcomra.cod_agente = agtagent.cod_agente ) and  
	         ( prdramo.cod_ramo = agtcomra.cod_ramo )
	         
	 SELECT COUNT(*) 
	   INTO _cant
	   FROM agtcomsu
	  WHERE cod_agente = _cod_agente
	    AND cod_ramo   = _cod_ramo;
	    
	 IF _cant > 0 THEN
	    FOREACH
			SELECT cod_subramo,
			       porc_comision,
				   user_added,
				   date_added
			  INTO _cod_subramo,
			   	   _porc_comision,
				   _user_added_s,
				   _date_added_s
			  FROM agtcomsu
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo = _cod_ramo

            SELECT nombre
			  INTO _nombre_subra
			  FROM prdsubra
			 WHERE cod_ramo = _cod_ramo
			   AND cod_subramo = _cod_subramo;

            RETURN _cod_agente, 
            	   _nombre_agente,
            	   _cod_ramo,
				   _nombre_ramo,
            	   _porc_comis_agt,
            	   _user_added,
            	   _date_added,
            	   _cod_subramo,
				   _nombre_subra,
            	   _porc_comision,
              	   _user_added_s,
				   _date_added_s WITH RESUME;
		END FOREACH
	 ELSE
            RETURN _cod_agente, 
            	   _nombre_agente,
            	   _cod_ramo,
				   _nombre_ramo,
            	   _porc_comis_agt,
            	   _user_added,
            	   _date_added,
            	   NULL,
            	   NULL,
              	   NULL,
				   NULL,
				   NULL WITH RESUME;
	 END IF
	 
END FOREACH    


END PROCEDURE