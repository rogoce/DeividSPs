-- Procedimiento que devuelve los promotores para un corredor

drop procedure sp_par110;

create procedure "informix".sp_par110(a_cod_agente char(5))
returning char(3),
          char(50);

define _cod_vendedor	char(3);
define _nombre			char(50);

foreach
 select cod_vendedor
   into _cod_vendedor
   from parpromo
  where cod_agente matches a_cod_agente
  group by cod_vendedor
  order by cod_vendedor

	select nombre
	  into _nombre
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	return _cod_vendedor,
	       _nombre
		   with resume;

end foreach

end procedure