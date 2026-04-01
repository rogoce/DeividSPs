-- Procedimiento que returna la cantidad de impresion 
-- Corrige la cantidad de unidades que debe imprimir cada unidad por acreedor
-- Realizado por Henry 15/01/2011 se envia por campaña
drop procedure sp_sis389;
create procedure "informix".sp_sis389(a_poliza CHAR(10)) 
returning 	  smallint;

define _cantidad		smallint;
define _copia			smallint;
define _leasing         smallint;

let _leasing = 0;
LET _copia   = 0;	  -- contar el cliente		   

-- Determinar si es Leasing
select leasing
  into _leasing
  from emipomae
 where no_poliza = a_poliza ;
 
 -- Cuando tiene acreedor hipotecario 
 select count(distinct n.nombre)
  into _cantidad
  from emipoacr e, emiacre n
 where e.cod_acreedor = n.cod_acreedor
   and e.no_poliza =  a_poliza ;

if _cantidad is null then 
	LET _cantidad = 0 ;
end if

LET _copia = _copia + _cantidad ;
LET _cantidad = 0  ;

-- Cuando tiene acreedor hipotecario - unidad
if _leasing = 1 then 

	select count(distinct n.nombre)
	  into _cantidad
	  from  emipouni e, cliclien n
	 where e.cod_asegurado = n.cod_cliente
	   and e.no_poliza = a_poliza;			   

	if _cantidad is null then 
		LET _cantidad = 0;
	end if

	LET _copia = _copia + _cantidad;
	
end if

LET _cantidad = 0 ;

return _copia;

end procedure