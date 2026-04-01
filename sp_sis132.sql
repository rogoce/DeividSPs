-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_sis132;

create procedure "informix".sp_sis132(a_aplicacion CHAR(3), a_tipo CHAR(2))
returning     CHAR(30);

define _error	 integer;
define _descripcion CHAR(30);

--SET DEBUG FILE TO "sp_rwf78.trc";
--TRACE ON ;

set isolation to dirty read;


begin
on exception set _error
	return _error;
end exception
 
	SELECT descripcion
 	  INTO _descripcion   
	  FROM insauto
	 WHERE tipo_autoriza =	a_tipo
	   AND aplicacion = a_aplicacion; 

return _descripcion;

end


end procedure
