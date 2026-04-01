-- Procedure que retorna los contadores para SAC

-- Creado: 05/02/2007 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_sac54;

create procedure "informix".sp_sac54(
a_compania	char(3),
a_apl_id	char(3),
a_apl_vers	char(3),
a_codigo	char(50)
) returning integer,
            char(50),
            integer;

define _no_registro	integer;
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, 0;
end exception

select param_valor
  into _no_registro
  from sigman25
 where param_comp     = a_compania
   and param_apl_id   = a_apl_id
   and param_apl_vers = a_apl_vers
   and param_codigo   = a_codigo;

if _no_registro is null then

	let _no_registro = 0;
	 
	insert into sigman25(
	param_comp,
	param_apl_id,
	param_apl_vers,
	param_codigo,
	param_valor
	)
	values(
	a_compania,
	a_apl_id,
	a_apl_vers,
	a_codigo,
	_no_registro
	);

end if

let _no_registro = _no_registro + 1;

update sigman25
   set param_valor    = _no_registro
 where param_comp     = a_compania
   and param_apl_id   = a_apl_id
   and param_apl_vers = a_apl_vers
   and param_codigo   = a_codigo;

return 0, "Actualizacion Exitosa", _no_registro;

end

end procedure