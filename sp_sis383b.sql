-- Copia del sp_sis383, se elimina la copia del acreeedor para el proceso de impresion de renovaciones desde el pool de impresion.
-- Creado    : 18/12/2012 - Autor: Roman Gordon 

drop procedure sp_sis383b;

create procedure "informix".sp_sis383b(a_poliza CHAR(10)) 
returning 	  smallint;

define _cantidad		smallint;
define _copia			smallint;
define _leasing         smallint;

let _leasing = 0;
LET _copia   = 1;	  -- contar el cliente

-- determinar si es leasing

select leasing
  into _leasing
  from emipomae
 where no_poliza = a_poliza;

-- Cuando el corredor es diferente a directo

select count(*)
into _cantidad
from  emipoagt
where no_poliza = a_poliza
and cod_agente <> '00099';

if _cantidad is null then 
	LET _cantidad = 0;
end if

LET _copia = _copia + _cantidad;
LET _cantidad = 0  ;

-- Cuando el corredor tiene coaseguro mayoritario

select count(distinct cod_coasegur)
into _cantidad
from  emicoama
where no_poliza = a_poliza
and cod_coasegur <> '036';

if _cantidad is null then 
	LET _cantidad = 0;
end if

LET _copia = _copia + _cantidad;
LET _cantidad = 0;


return _copia;

end procedure

			  
	