-- ACTUALIZA UN AGENTE 

-- Creado    : 22/08/2024 - Autor: Amado Perez M

drop procedure sp_eco09;

create procedure "informix".sp_eco09(a_cod_agente char(5)) RETURNING integer;

define 	_error			integer;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION
--set debug file to "sp_yos16.trc"; 
--trace on;
update agtagent 
   set eco_integra		    = 1
 where cod_agente = a_cod_agente;
END
RETURN 0;
end procedure;
