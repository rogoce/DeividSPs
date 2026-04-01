-- Procedimiento que retorna el vendedor dada la poliza
 
-- Creado     :	28/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo066;		

create procedure "informix".sp_bo066(_no_poliza char(10))
returning char(3),
		  char(100);

define _cod_ramo		char(3);
define _cod_agencia 	char(3);
define _suc_promotoria	char(3);
define _cod_agente		char(5);
define _cod_vendedor	char(3);

select cod_ramo,
       sucursal_origen
  into _cod_ramo,
       _cod_agencia
  from emipomae
 where no_poliza = _no_poliza;

select sucursal_promotoria
  into _suc_promotoria
  from insagen
 where codigo_agencia = _cod_agencia;

foreach
 select cod_agente
   into _cod_agente
   from emipoagt
  where no_poliza = _no_poliza
  order by porc_partic_agt desc
	exit foreach;
end foreach

select cod_vendedor
  into _cod_vendedor
  from parpromo
 where cod_agente  = _cod_agente
   and cod_agencia = _suc_promotoria
   and cod_ramo	   = _cod_ramo;

if _cod_vendedor is null then
	return "XXX", "No Existe Vendedor para " || _cod_agente || " " || _suc_promotoria || " " || _cod_ramo;
end if

return _cod_vendedor, "Actualizacion Exitosa";

end procedure