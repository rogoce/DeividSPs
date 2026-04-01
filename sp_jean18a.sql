--Caso 12283   Generación Datos de Morosidad Anual para Calculo y Monitoreo de Cobros
--Armando Moreno M.

DROP procedure sp_jean18a;
CREATE procedure sp_jean18a()
RETURNING char(7),char(3),char(50),char(5),char(50), dec(16,2), dec(16,2), dec(16,2), dec(16,2);

define _periodo         char(7);
define _cod_vendedor  char(3);
define _n_zona,_n_agente        char(50);
define _cod_agente    char(5);
define _ventas_nuevas,_ventas_renovadas,_ventas_total,_cobros   dec(16,2);


foreach
	select periodo,
	       cod_vendedor,
		   cod_agente,
		   ventas_nuevas,
		   ventas_renovadas,
		   ventas_total,
		   cobros
	  into _periodo,
	       _cod_vendedor,
		   _cod_agente,
		   _ventas_nuevas,
		   _ventas_renovadas,
		   _ventas_total,
		   _cobros
      from deivid_bo:preventas 
	 where periodo between '2023-01' and '2024-12' 
	   and cobros <> 0
	   
	select nombre 
	  into _n_zona
	  from agtvende
	 where cod_vendedor = _cod_vendedor;
	 
	 select nombre
	   into _n_agente
	   from agtagent
	  where cod_agente = _cod_agente;

	return _periodo,_cod_vendedor,_n_zona,_cod_agente,_n_agente,_ventas_nuevas,_ventas_renovadas,_ventas_total,_cobros with resume;
	
end foreach
END PROCEDURE;