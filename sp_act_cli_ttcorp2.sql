--drop procedure sp_act_cli_ttcorp2;
-- copia de sp_actuario
create procedure "informix".sp_act_cli_ttcorp2()
	returning char(15);

BEGIN

define _codigo_inf				char(15);
define _cnt						integer;

set isolation to dirty read;


foreach
	select codigo
	  into _codigo_inf
	  from abc

	select count(*)
	  into _cnt
	  from def
	 where codigo = _codigo_inf;

	if _cnt > 0 then
	else
	 return _codigo_inf with resume;
	end if
end foreach

return 'Actualizacion Exitosa';	
end			
end procedure;