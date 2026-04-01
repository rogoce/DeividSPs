-- Obtener el modo de procesamiento de cobros electronico.(Proceso Normal/Rechazos)
-- Creado    : 26/11/2010 - Autor: Roman Gordon 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis414;
create procedure "informix".sp_sis414(a_parametro smallint)
returning smallint;

define _estatus	smallint;

let _estatus = 0;

if a_parametro = 1 then --Visa

	select estatus_visa
	  into _estatus
	  from parparam
	 where cod_compania = '001';

elif a_parametro = 2 then --Ach

	select estatus_ach
	  into _estatus
	  from parparam
	 where cod_compania = '001';

end if

return _estatus;

end procedure



