-- consulta de saldos
-- Creado		:  03/10/2022	- Autor: Henry Giron.
 DROP procedure sp_cob428a;
 CREATE procedure "informix".sp_cob428a( a_no_poliza CHAR(10))  
	RETURNING char(10)	as	cod_asegurado;
   

 BEGIN


define	v_cod_asegurado	char(10);

SET ISOLATION TO DIRTY READ; 

FOREACH        
  SELECT cod_asegurado
	INTO v_cod_asegurado
	FROM emipouni
   WHERE no_poliza = a_no_poliza	
	 and activo = 1		   
	 order by 1
	 exit foreach;
END FOREACH 			   

return v_cod_asegurado	 with resume;


END
END PROCEDURE;
