-- Procedimiento para listar endosos especiales a imprimir por ramo -- 
-- Creado    : 17/08/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe56a;
CREATE PROCEDURE "informix".sp_proe56a(a_no_poliza CHAR(10))
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
DEFINE a_no_endoso     CHAR(5);
DEFINE _link           VARCHAR(100);

SET ISOLATION TO DIRTY READ;
LET _seleccion = 0; -- Permitir que el tecnico seleccione los endosos especial a imprimir
LET a_no_endoso = '00000';

LET _link = null;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

foreach
  select cod_endoso
    into _cod_endoso
    from endesppol
   where no_poliza = a_no_poliza
     and no_endoso = a_no_endoso
     and cod_ramo  = _cod_ramo

  SELECT cod_endoso,   
         cod_ramo,   
         nombre_endoso,   
         user_added,   
         date_added,   
         activo,
         reporte,
         link  
	INTO _cod_endoso,   
         _cod_ramo,   
         _nombre_endoso,   
         _user_added,   
         _date_added,   
         _activo,
         _reporte,
		 _link
    FROM endespimp  
   WHERE cod_ramo   = _cod_ramo
     AND cod_endoso = _cod_endoso;

	if _activo = 1 and _link is not null then

		RETURN _cod_endoso,   
			   _cod_ramo,   
			   _nombre_endoso, 
			   _user_added,   
			   _date_added,   
			   _activo,
			   _seleccion,
			   _reporte  	   		   
			   WITH RESUME;
	end if
end foreach

END PROCEDURE	

