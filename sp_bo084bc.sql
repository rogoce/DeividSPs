-- Procedimiento que calcula la prima devengada x periodo
-- Sacado del sp_bo043
-- Creado     :	10/01/2014 - Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo084bc;		

create procedure "informix".sp_bo084bc()
		returning integer, char(100);

define _ano				integer;
define _count			integer;


set isolation to dirty read;

let _count = 1900; 

for  _ano = 1900 to 3000

	INSERT INTO informix.emiano(ano_auto) 
		VALUES(_count);
	
	let _count = _count + 1 ;
end for
			 
return 0, "Actualizacion Exitosa";



end procedure
