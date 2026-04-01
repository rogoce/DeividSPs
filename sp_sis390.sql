-- Procedimiento que retorna el intervalo de tiempo entre 2 fechas
-- Creado    : 22/07/2011 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis390;

create procedure "informix".sp_sis390(a_fecha_desde	datetime year to fraction(5),a_fecha_hasta	datetime year to fraction(5))
 returning interval day to second;


define _intervalo_completo	interval day to second;

--set debug file to "sp_sis390.trc"; 
--trace on;                                                                

set isolation to dirty read;

let _intervalo_completo = a_fecha_hasta - a_fecha_desde;

return _intervalo_completo;
end procedure;  
	