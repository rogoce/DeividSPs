-- Procedure que elimina los registros de ef_cglresumen

-- Creado: 17/11/2010 - Autor: Demetrio Hurtado Almanza

drop procedure sp_bo074;

create procedure "informix".sp_bo074()
returning integer,
          char(100);

define _res_noregistro	integer;
define _res_cia_comp	char(3);
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
  from sac999:ef_cglresumen;

if _cant_reg = 0    or
   _cant_reg = 5120 then 
	return 0, "Exito";
end if

let _cant_reg = 0;

foreach
 select res_noregistro,
		res_cia_comp
   into _res_noregistro,
		_res_cia_comp
   from sac999:ef_cglresumen
  group by res_noregistro, res_cia_comp

	let _cant_reg = _cant_reg + 1;
	
    delete from sac999:ef_cglresumen
     where res_noregistro = _res_noregistro
       and res_cia_comp   = _res_cia_comp;

	if _cant_reg >= 10000 then
		exit foreach;
	end if

end foreach

end

return 1, "Exito";

end procedure