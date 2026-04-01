-- Procedure que carga los registros de imagenes respaldadas

drop procedure sp_bo048;

create procedure sp_bo048()
returning integer,
          char(50);

{returning integer,
          char(50),
          integer,
          char(20),
          char(7);}
define _error_desc		char(50);
define _no_documento	char(20);
define _periodo			char(7);
define _cantidad		smallint;
define _cant_reg		integer;
define _cant_pro		integer;
define _cant_tot		integer;
define _error			integer;
define _error_isam		integer;

begin
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc;
--	return _error, _error_desc, _error_isam, _no_documento, _periodo;
end exception

let _cant_reg = 0;
let _cant_tot = 0;
let _cant_pro = 1000;

foreach	with hold
	select no_documento,
		   periodo
	  into _no_documento,
		   _periodo
	  from deivid_cob:cobmoros4
  	
	if _cant_reg = 0 then
	   --begin work;
	end if

	let _cant_tot = _cant_tot + 1;
	let _cant_reg = _cant_reg + 1;

	delete from deivid_cob:cobmoros4
	 where no_documento = _no_documento
	   and periodo      = _periodo;

	if _cant_reg >= _cant_pro then
		--commit work;
		--return 0, "Actualizacion Exitosa ", _cant_tot, _no_documento, _periodo with resume;
		let _cant_reg = 0;
	end if

	{if _cant_tot >= 5000 then
		exit foreach;
	end if--}

end foreach

if _cant_reg < _cant_pro and _cant_reg <> 0 then
	--commit work;
	--return 0, "Actualizacion Exitosa ", _cant_tot, _no_documento, _periodo with resume;
	let _cant_reg = 0;
end if

end 

return 0, "Actualizacion Exitosa ";
--return 0, "Actualizacion Exitosa ", _cant_tot, _no_documento, _periodo;
 
end procedure