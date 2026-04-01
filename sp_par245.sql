--drop procedure sp_par245;

create procedure "informix".sp_par245()
returning integer,
          char(50);

define _cod_agente		char(5);
define _cod_agencia		char(3);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);

let _cod_ramo = "020";

foreach
 select cod_agente,
        cod_agencia,
		cod_ramo
   into _cod_agente,
        _cod_agencia,
		_cod_ramo
   from parpromo
  where cod_vendedor is null
    and cod_ramo     = _cod_ramo

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _cod_agencia
	   and cod_ramo    = "002";

	update parpromo
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente
	   and cod_agencia  = _cod_agencia
	   and cod_ramo     = _cod_ramo;

end foreach

return 0, "Actualizacion Exitosa";

end procedure