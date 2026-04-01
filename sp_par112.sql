-- Procedimiento que muestra los promotores activos

drop procedure sp_par112;

create procedure "informix".sp_par112()
returning char(5),
          char(50);

define _cod_agente   	char(5);
define _nombre			char(50);

return "*",
       "TODOS LOS CORREDORES"
	   with resume;

foreach
 select cod_agente,
        nombre
   into _cod_agente,
        _nombre
   from agtagent
  order by nombre

	return _cod_agente,
	       _nombre
		   with resume;

end foreach

end procedure