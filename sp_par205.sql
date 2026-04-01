-- Procedure que genere el registro contable de las comisiones

-- Creado    : 15/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_che06 - DEIVID, S.A.

drop procedure sp_par205;

create procedure "informix".sp_par205(a_no_requis char(10))
returning integer,
          char(50);

define _cod_agente			char(10);
define _tipo_agente			char(1);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

--set debug file to "sp_par205.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select cod_agente
  into _cod_agente
  from chqchmae
 where no_requis = a_no_requis;

select tipo_agente
  into _tipo_agente
  from agtagent
 where cod_agente = _cod_agente;

if _tipo_agente = "A" THEN -- Agentes Normales

	call sp_par276(a_no_requis, "2") returning _error, _error_desc;
	
	if _error <> 0 then
		return _error, _error_desc;
	end if

elif _tipo_agente = "E" THEN -- Agentes Especiales

	call sp_par276(a_no_requis, "7") returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
end if

end

return 0, "Actualizacion Exitosa";

end procedure