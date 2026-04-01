-- Procedimiento que 
-- Creado    : 14/08/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob367;

CREATE PROCEDURE "informix".sp_cob367(a_numero_cuenta varchar(20))
RETURNING CHAR(4); 
		      
define _no_ultimo_final	varchar(4);

if a_numero_cuenta <> '' then
	let _no_ultimo_final = substr(a_numero_cuenta,-4);
end if

RETURN _no_ultimo_final with resume;
	  
END PROCEDURE;