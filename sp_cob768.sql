-- Procedure que actualiza la estafeta en la tabla de clientes													   
-- Creado por: Amado Perez 08/10/2014
-- Modificado por: Henry Giron 21/08/2019


drop procedure sp_cob768;
create procedure sp_cob768(a_tipo smallint, a_cod_cliente char(10), a_modificacion varchar(100))
returning integer, varchar(50);

define _descripcion		varchar(50);
define _error           integer;
define _retorno         integer;
define _title           char(20);   

--SET DEBUG FILE TO "sp_cob768.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

if a_tipo = 1 then
	let _title = 'estafeta';
elif a_tipo = 2 then
	let _title = 'cliente';
end if

begin

ON EXCEPTION SET _error 
RETURN _error, "Error al Actualizar "||_title;         
 	--RETURN _error, "Error al Actualizar la estafeta";         	
END EXCEPTION

let _error = 0;

if a_tipo = 1 then
	update cliclien
	   set cod_estafeta = a_modificacion
	 where cod_cliente = a_cod_cliente;
elif a_tipo = 2 then
	
	if a_modificacion is not null and a_modificacion <> '' then
		update cliclien
		   set e_mail = a_modificacion
		 where cod_cliente = a_cod_cliente;
	end if
end if


return 0, "Actualizacion Exitosa" ;


end
end procedure