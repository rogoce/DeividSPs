-- Procedimiento que muestra los promotores activos

drop procedure sp_par111;

create procedure "informix".sp_par111()
returning char(3),
          char(50);

define _cod_vendedor	char(3);
define _nombre			char(50);

foreach
 select cod_vendedor,
        nombre
   into _cod_vendedor,
        _nombre
   from agtvende
  where activo = 1
  order by cod_vendedor

	return _cod_vendedor,
	       _nombre
		   with resume;

end foreach

end procedure