--Procedure que graba el cod ramo en la unidad sacado de la relacion producto cobertura reaseguro
--Armando Moreno 14/06/2017
--drop procedure sp_sis503;		
create procedure "informix".sp_sis503(a_no_poliza char(10))
returning integer;

define _cod_producto char(10);
define _cod_ramo     char(3);
define _no_unidad    char(5);
define _error_desc	 char(50);
define _error 		 smallint; 

set isolation to dirty read;

begin
let _error_desc = "";
foreach
	select cod_producto,
	       no_unidad
	  into _cod_producto,
	       _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

    let _cod_ramo = sp_sis502(_cod_producto);
	
	update emipouni
	   set cod_ramo = _cod_ramo
	 where no_poliza = a_no_poliza
       and no_unidad = _no_unidad;
	   
end foreach
-- Se agrego para arreglar el valor del impuesto en emipolim al momento de actualizar la poliza. Federico 06/08/2021
CALL sp_proe03(a_no_poliza, '001') returning _error;  

if _error <> 0 then
	return _error;
end if

-- fin

return 0;
end
end procedure;