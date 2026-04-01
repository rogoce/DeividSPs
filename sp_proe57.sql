-- Procedimiento para listar endosos especiales a imprimir por ramo -- 
-- Creado    : 17/08/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe57;
CREATE PROCEDURE "informix".sp_proe57(a_ramo CHAR(3)) 
RETURNING   CHAR(5),    -- cod_endoso   
 			CHAR(3),    -- cod_ramo     
 			CHAR(255),	-- nombre_endoso
			CHAR(100),  -- user_added   
			DATE, 	    -- date_added   
 			CHAR(1),	-- activo   
 			CHAR(1),	-- seleccion    
 			CHAR(255);	-- reporte 

DEFINE _cod_endoso     CHAR(5);
DEFINE _cod_ramo       CHAR(3);
DEFINE _nombre_endoso  CHAR(255);
DEFINE _user_added     CHAR(100);
DEFINE _date_added     DATE;
DEFINE _activo         CHAR(1);
DEFINE _seleccion      CHAR(1);
DEFINE _reporte        CHAR(255);

SET ISOLATION TO DIRTY READ;
LET _seleccion = 0; -- Permitir que el tecnico seleccione los endosos especial a imprimir
FOREACH
  SELECT cod_endoso,   
         cod_ramo,   
         nombre_endoso,   
         user_added,   
         date_added,   
         activo,
         reporte  
	INTO _cod_endoso,   
         _cod_ramo,   
         _nombre_endoso,   
         _user_added,   
         _date_added,   
         _activo,
         _reporte  
    FROM endespimp  
   WHERE cod_ramo = a_ramo 
     AND activo = '1'

	RETURN _cod_endoso,   
		   _cod_ramo,   
		   _nombre_endoso, 
		   _user_added,   
		   _date_added,   
		   _activo,
		   _seleccion,
		   _reporte  	   		   
		   WITH RESUME;   	

END FOREACH
END PROCEDURE			   			   