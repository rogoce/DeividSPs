-- Procedure que elimina los registros de boindmul

-- Creado: 17/11/2010 - Autor: Demetrio Hurtado Almanza

--drop procedure sp_bo073;

create procedure "informix".sp_bo073()
returning integer,
          char(100);

define _no_documento	char(20);
define _cant_reg		integer;

define _error	   		integer;
define _error_isam 		integer;
define _error_desc 		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

select count(*)
  into _cant_reg
  from deivid_bo:boindmul;

if _cant_reg = 0 then
	return 0, "Exito";
end if

let _cant_reg = 0;

foreach
 select no_documento
   into _no_documento
   from deivid_bo:boindmul
  group by no_documento

	let _cant_reg = _cant_reg + 1;
	
    delete from deivid_bo:boindmul
     where no_documento = _no_documento;

	if _cant_reg >= 10000 then
		exit foreach;
	end if

end foreach

end

return 1, "Exito";

end procedure