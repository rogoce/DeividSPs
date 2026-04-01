-- Buscar la prima anual de la poliza

-- Creado    : 09/06/2010 - Autor: Amado Perez M. 

drop procedure sp_sis114a;
create procedure "informix".sp_sis114a(a_poliza	char(10))
returning char(10);

define _no_evaluacion	char(10);

SET ISOLATION TO DIRTY READ;

let _no_evaluacion = null;

foreach
select no_evaluacion
  into _no_evaluacion
  from emievalu
 where no_poliza = a_poliza
 exit foreach;
end foreach 

if _no_evaluacion is null then
	let _no_evaluacion = '';
end if
return trim(_no_evaluacion);

end procedure 
