-- Procedimiento que carga los datos para el presupuesto del 2010
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par287;		

create procedure "informix".sp_par287()
returning integer,
		  char(5),	
		  char(100),
		  char(100);


define _nombre_agente1	char(100);
define _nombre_agente2	char(100);

define _cod_agente		char(5);

define _cantidad		smallint;

let _cantidad = 0;

foreach
 select nombre_agente
   into _nombre_agente1
   from deivid_tmp:prom2010
  where cod_agente is null

	let _cantidad = _cantidad + 1;

	foreach
	 select nombre,
	        cod_agente
	   into _nombre_agente2,
	        _cod_agente
	   from agtagent

		if trim(_nombre_agente1) = trim(_nombre_agente2) then
	
			update deivid_tmp:prom2010
			   set cod_agente    = _cod_agente
			 where nombre_agente = _nombre_agente1;

			return 0, _cod_agente, _nombre_agente1, _nombre_agente2 with resume;

			exit foreach;			

		end if

	end foreach

--	if _cantidad >= 100 then
--		exit foreach;
--	end if

end foreach

return 0, "", "Actualizacion Exitosa", "";

end procedure