-- Procedure que elimina los registros de boendedmae

-- Creado: 17/11/2010 - Autor: Demetrio Hurtado Almanza

--drop procedure sp_bo072;

create procedure "informix".sp_bo072()
returning integer,
          char(100);

define _no_poliza		char(10);
define _no_endoso		char(5);
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
  from deivid_bo:boendedmae;

if _cant_reg = 0 then
	return 0, "Exito";
end if

let _cant_reg = 0;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from deivid_bo:boendedmae

	let _cant_reg = _cant_reg + 1;
	
    delete from deivid_bo:boendedmae
     where no_poliza = _no_poliza
       and no_endoso = _no_endoso;

	if _cant_reg >= 10000 then
		exit foreach;
	end if

end foreach

end

return 1, "Exito";

end procedure