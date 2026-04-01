-- Actualizadion masiva de los datos de promotorias

-- Creado    : 04/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 04/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par91;

create procedure "informix".sp_par91()
returning smallint, char(100);

define _ret_desc		char(100);
define _ret_valor		smallint;

define _cod_agente 		char(5);

foreach
 select	cod_agente
   into _cod_agente
   from agtagent

	call sp_par82(_cod_agente, "informix") returning _ret_valor, _ret_desc;

	if _ret_valor <> 0 then
		return _ret_valor, trim(_ret_desc) || _cod_agente with resume;
	end if

end foreach

return 0, "Proceso Completado";

end procedure;
