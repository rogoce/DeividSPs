-- Eliminar de cobcapen el registro si el saldo es = 0
-- 
-- Creado    : 27/09/2010 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob254;

CREATE PROCEDURE "informix".sp_cob254()
Returning integer,char(50);


define _error   		 integer;
define _mensaje          CHAR(50);
define _cod_cobrador     char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,_mensaje;         
END EXCEPTION

foreach

	select cod_cobrador
	  into _cod_cobrador
	  from cobcapen
	 where saldo = 0
	 group by cod_cobrador

	delete from cobcapen
	 where cod_cobrador = _cod_cobrador;

end foreach

return 0, "Actualizacion Exitosa";

end

end procedure