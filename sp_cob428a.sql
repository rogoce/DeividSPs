-- consulta de saldos
-- Creado		:  03/10/2022	- Autor: Henry Giron.
 DROP procedure sp_cob428a;
 CREATE procedure "informix".sp_cob428a( a_no_poliza CHAR(10))  
	RETURNING char(50)	as	cod_asegurado;
   

 BEGIN

DEFINE _nombre_asegurado  CHAR(50);  
define	v_cod_asegurado	char(10);
define v_cnt smallint;

SET ISOLATION TO DIRTY READ; 
let _nombre_asegurado = 'Ver Unidades';
let v_cnt = 0;

  SELECT count(*)
	INTO v_cnt
	FROM emipouni
   WHERE no_poliza = a_no_poliza	
	 and activo = 1;	

if v_cnt > 1 then 
else
	FOREACH        
	  SELECT cod_asegurado
		INTO v_cod_asegurado
		FROM emipouni
	   WHERE no_poliza = a_no_poliza	
		-- and activo = 1		   
		 order by 1
		 exit foreach;
	END FOREACH 			   

	SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = v_cod_asegurado; 	  

end if
--return v_cod_asegurado	 with resume;
return _nombre_asegurado	 with resume;  --Nueva solicitud segurn correo JEPEREZ 07/10/2022



END
END PROCEDURE;
