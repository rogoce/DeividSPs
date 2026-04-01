-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

drop procedure sp_sis80;

create procedure "informix".sp_sis80(a_poliza CHAR(10)) RETURNING CHAR(25),CHAR(20);
--}
DEFINE _firma        CHAR(25);
DEFINE _nueva_renov  CHAR(1);
DEFINE _impreso      SMALLINT;
DEFINE _usuario      CHAR(20);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


FOREACH WITH HOLD
	SELECT nueva_renov,
	       impreso
	  INTO _nueva_renov,
		   _impreso
	  FROM emipomae
	 WHERE no_poliza = a_poliza

	IF _nueva_renov = 'R' AND _impreso = 0 THEN
		SELECT firma
		  INTO _firma
		  FROM wf_firmas
		 WHERE usuario = "EDICTA";
		 
		   LET _firma = "C:\DEIVID\BIN\" || _firma;
		   LET _usuario = "EDICTA";
    ELSE
		   LET _firma = "";
		   LET _usuario = "";
	END IF

	RETURN _firma,
	 	   _usuario
		   WITH RESUME;

END FOREACH
end procedure;
