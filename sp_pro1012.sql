-- Procedure que actualiza emirepo al imprimir las facturas.
-- Creado    : 02/12/2009 - Autor: Henry Giron

-- SIS v.2.0 - DEIVID, S.A.
--Drop procedure sp_pro1012;

Create procedure sp_pro1012(a_no_poliza char(10),a_status smallint)
RETURNING integer, 
          varchar(50);

define _cantidad	 smallint;
define _error        integer;

let _cantidad = 0;
	
set lock mode to wait;
	
BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al actualizar emirepo";         
	END EXCEPTION 

	Update emirepo
	Set estatus   = 9,
		status_imp = a_status -- cambia el estado a 9, las polizas impresas
	Where no_poliza = a_no_poliza;	
				
end

set isolation to dirty read;

return 0, "Actualizaciion Exitosa";
end procedure  