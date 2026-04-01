-- Actualizar las Primas Pendientes por Aplicar a Diciembre 2010
-- 
-- Creado    : 14/06/2011 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob282;

create procedure "informix".sp_cob282()
returning integer,
          char(50);

define _doc_suspenso	char(30);

define _error           integer;
define _error_isam      integer;
define _error_desc      char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
 select doc_suspenso
   into _doc_suspenso
   from deivid_tmp:suspenso201012
--  where doc_suspenso = "377014-01"

	update cobredet
	   set saldo = 0
	 where doc_remesa = _doc_suspenso
	   and tipo_mov   in ("E", "A");

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure