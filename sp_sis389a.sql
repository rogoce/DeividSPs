-- Procedimiento que returna la cantidad de impresion 
-- Corrige la cantidad de unidades que debe imprimir cada unidad por acreedor - Backup se corrigue para que envie la cantidad de acreedor de la carta
-- Realizado por Henry 15/01/2011
--drop procedure sp_sis389;
create procedure "informix".sp_sis389(a_poliza CHAR(10)) 
returning 	  smallint;

define _cantidad		smallint;
define _copia			smallint;
define _leasing         smallint;

let _leasing = 0;
LET _copia   = 1;	  -- contar el cliente

-- Determinar si es Leasing

select leasing
  into _leasing
  from emipomae
 where no_poliza = a_poliza ;

-- Cuando el corredor es diferente a directo

select count(*)
into _cantidad
from  emipoagt
where no_poliza = a_poliza
and cod_agente <> '00099' ;

if _cantidad is null then 
	LET _cantidad = 0 ;
end if

LET _copia = _copia + _cantidad ;
LET _cantidad = 0  ;

-- Cuando el corredor tiene acreedor hipotecario

select count(distinct cod_acreedor)
into _cantidad
from  emipoacr
where no_poliza = a_poliza;

if _cantidad is null then 
	LET _cantidad = 0;
end if

if _cantidad = 0 and _leasing = 1 then
	LET _copia = _copia + 1;
end if

LET _copia = _copia + _cantidad;
LET _cantidad = 0 ;
return _copia;

end procedure