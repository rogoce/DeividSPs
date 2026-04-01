-- Procedimiento para generacion una nota demandas
-- 
-- creado: 21/07/2015 - Autor: Jaime Chevalier

DROP PROCEDURE sp_leg03;
CREATE PROCEDURE "informix".sp_leg03(a_compania CHAR(3), a_desde DATE, a_hasta DATE, a_no_demanda CHAR(10))
RETURNING   CHAR(50),                      --Nombre compañia
            CHAR(10),                      --no_demanda
			DATE,                          --fecha_nota
			VARCHAR(250),                  --des_nota
			CHAR(8),                       --user_added
            DATE,                          --fecha desde
            DATE;			               --fecha hasta

DEFINE _no_demanda        CHAR(10);
DEFINE _fecha_nota        DATE;
DEFINE _des_nota          VARCHAR(250);
DEFINE _user_added        CHAR(8);
DEFINE v_compania_nombre  CHAR(50);

LET v_compania_nombre = sp_sis01(a_compania);


IF a_no_demanda <> "" THEN
	If (a_desde IS NULL OR a_desde = " ") or (a_hasta IS NULL OR a_hasta = " ") Then
		FOREACH
			SELECT no_demanda, 
				   fecha_nota, 
				   desc_nota, 
				   user_added
			  INTO _no_demanda,
				   _fecha_nota,
				   _des_nota,
				   _user_added		   
			FROM legnotas
			WHERE no_demanda = a_no_demanda
			  
			RETURN v_compania_nombre,
			   _no_demanda,
			   _fecha_nota, 
			   _des_nota,
			   _user_added, 
			   a_desde, 
			   a_hasta
			   with resume;
		  
		END FOREACH	
	Else
		FOREACH
			SELECT no_demanda, 
				   fecha_nota, 
				   desc_nota, 
				   user_added
			  INTO _no_demanda,
				   _fecha_nota,
				   _des_nota,
				   _user_added		   
			FROM legnotas
			WHERE date(fecha_nota) >= a_desde 
			  AND date(fecha_nota) <= a_hasta 
			  AND no_demanda = a_no_demanda
			  
			RETURN v_compania_nombre,
			   _no_demanda,
			   _fecha_nota, 
			   _des_nota,
			   _user_added, 
			   a_desde, 
			   a_hasta
			   with resume;
		  
		END FOREACH	
    End If		
ELSE
	FOREACH
		SELECT no_demanda, 
			   fecha_nota, 
			   desc_nota, 
			   user_added
		  INTO _no_demanda,
			   _fecha_nota,
			   _des_nota,
			   _user_added		   
		FROM legnotas
		WHERE date(fecha_nota) >= a_desde 
		  AND date(fecha_nota) <= a_hasta
		
		RETURN v_compania_nombre,
			   _no_demanda,
			   _fecha_nota, 
			   _des_nota,
			   _user_added, 
			   a_desde, 
			   a_hasta
			   with resume;
		  
	END FOREACH
	  
END IF
		   
END PROCEDURE
