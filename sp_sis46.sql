-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

--drop procedure sp_sis46;

create procedure "informix".sp_sis46(a_usuario CHAR(20)) RETURNING CHAR(35);
--}
DEFINE _foto  CHAR(35);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


FOREACH WITH HOLD

	SELECT foto
	  INTO _foto
	  FROM wf_firmas
	 WHERE usuario = trim(a_usuario)
	 
	   LET _foto = "D:\CARNETS\" || _foto;

	RETURN _foto
		   WITH RESUME;

END FOREACH
end procedure;
