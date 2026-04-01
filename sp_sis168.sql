-- Procedure que retorna la promotoria dada la poliza

--drop procedure sp_sis168;

create procedure sp_sis168(a_no_poliza	char(10))
returning char(3);

define _cod_ramo		char(3);
define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_agente		char(5);
define _cod_vendedor	char(3);

set isolation to dirty read;

select cod_ramo,
       sucursal_origen
  into _cod_ramo,
       _cod_agencia
  from emipomae
 where no_poliza = a_no_poliza;

select sucursal_promotoria
  into _suc_promotoria
  from insagen
 where codigo_agencia = _cod_agencia;

foreach
 select cod_agente
   into _cod_agente
   from emipoagt
  where no_poliza = a_no_poliza
  order by porc_partic_agt desc
	exit foreach;
end foreach

select cod_vendedor
  into _cod_vendedor
  from parpromo
 where cod_agente  = _cod_agente
   and cod_agencia = _suc_promotoria
   and cod_ramo	   = _cod_ramo;

return _cod_vendedor;

end procedure
