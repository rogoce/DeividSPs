-- Procedure que Genera el Asiento de Diario en el Mayor General para 
-- Asegurador Ancon NIIF

-- Creado    : 03/09/2013 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
-- drop procedure sp_sac229;

create procedure sp_sac229(
a_compania	char(3), 
a_notrx		integer 
a_usu_act	char(8)
) returning integer,
            char(100);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

if a_compania <> "001" then -- SAC GAAP

	return 0, "Actualizacion Exitosa";

end if

-- Actualizacion para SAC NIIF

call sp_sac64("010", _notrx, a_usu_act) returning _error, _error_desc;

if _error <> 0 then

	if _error_desc is null then
		let _error_desc = "Error en sp_sac64";
	end if

	return _error, _error_desc;

end if

return 0, "Actualizacion Exitosa";

end procedure