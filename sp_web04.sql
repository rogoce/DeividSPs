-- Procedure que carga los registros para el WEB

-- Creado: 25/10/2010 - Autor: Demetrio Hurtado Almanza

drop procedure sp_web04;

create procedure "informix".sp_web04()
returning integer,
          char(100);

define _cod_cliente		char(10);
define _cant_reg		integer;

define _error	   		integer;
define _error_isam 		integer;
define _error_desc 		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

--SET DEBUG FILE TO "sp_web04.trc";
--TRACE ON ;

select count(*)
  into _cant_reg
  from web_cliente;

if _cant_reg = 0 then
	return 0, "Exito";
end if

let _cant_reg = 0;

foreach
 select cod_cliente
   into _cod_cliente
   from web_cliente

	let _cant_reg = _cant_reg + 1;
	
    delete from web_cliente
    where cod_cliente = _cod_cliente;

	if _cant_reg >= 10000 then
		exit foreach;
	end if

end foreach

end

return 1, "Exito";

end procedure