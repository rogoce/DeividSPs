-- Buscar la prima anual de la poliza

-- Creado    : 09/06/2010 - Autor: Amado Perez M. 

--drop procedure sp_sis114;

create procedure "informix".sp_sis114(
a_poliza	char(10)
) returning dec(16,2);

define _no_reclamo	char(10);
define _numero		integer;
define _error     	smallint;
define _prima_anual dec(16,2); 

SET ISOLATION TO DIRTY READ;

select sum(prima_anual) 
  into _prima_anual
  from emipocob where no_poliza = a_poliza;

return _prima_anual;

end procedure 
