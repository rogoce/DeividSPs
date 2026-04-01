-- Procedure que valida excepciones al imprimir desde el pool de impresion.
-- Creado    : 02/12/2009 - Autor: Henry Giron

-- SIS v.2.0 - DEIVID, S.A.
Drop procedure sp_pro1011;

Create procedure sp_pro1011()
RETURNING integer, varchar(50);

define _error        integer;
define _descripcion  varchar(50);

set lock mode to wait;

BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, _descripcion;         
	END EXCEPTION 

	--/*Borrar EMIREPOL*/
	
	let _descripcion = 'Error al Borrar EMIREPOL';
	
	Delete  From emirepol
	where emirepol.no_poliza in (Select no_poliza From emirepo
	where emirepo.estatus = 9
		and status_imp = 3);		

	--/*Borrar EMIREPO*/
	
	let _descripcion = 'Error al Borrar EMIREPO';
	
	Delete  From emirepo
	where emirepo.estatus = 9
		and status_imp = 3;
		
end

return 0, "Actualizacion Exitosa";
end procedure  