-- Procedure que busca los año auto maximo de un producto													   
-- Creado por: Amado Perez 05/05/2015

drop procedure sp_rwf140;

create procedure sp_rwf140(a_producto CHAR(5))
returning smallint;

DEFINE _ano_auto_max 		smallint;

define _error           integer;
define _descripcion		varchar(50);

--SET DEBUG FILE TO "sp_rwf137.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 --	RETURN _error, "Error al buscar las piezas";         
END EXCEPTION

let _error = 0;

let _descripcion = "Verificacion exitosa";

SELECT ano_auto_max
  INTO _ano_auto_max
  FROM prdprod
 WHERE cod_producto = a_producto;
 
return _ano_auto_max;	 

END
end procedure