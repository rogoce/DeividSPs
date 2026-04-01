-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 10/02/2004 - Autor: Armando Moreno M.

drop procedure sp_sis378;

create procedure "informix".sp_sis378(a_usuario CHAR(10)) RETURNING VARCHAR(60);
--}
DEFINE _firma  VARCHAR(60);

set isolation to dirty read;

let _firma = "";

	SELECT firma
	  INTO _firma
	  FROM wf_firmas
	 WHERE usuario = a_usuario;
	 
	   LET _firma = "\\mainserver\deivid\" || _firma;

	RETURN trim(_firma);

end procedure;
