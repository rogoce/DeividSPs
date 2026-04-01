-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac192;

create procedure sp_sac192() 
returning integer,
          char(100);

define _notrx		integer;
define _usuario		char(8);

define _mayor_error	integer;
define _mayor_desc	char(100);

-- Mayorizacion

foreach
 select trx1_notrx,
        trx1_usuario
   into _notrx,
        _usuario
   from cgltrx1
  where trx1_usuario = "informix"
  order by trx1_notrx

	call sp_sac64("001", _notrx, _usuario) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		if _mayor_desc is null then
			let _mayor_desc = "Error en sp_sac64";
		end if

		return _mayor_error, _mayor_desc;

	end if

--	exit foreach;

end foreach

return 0, "Actualizacion Exitosa";

end procedure