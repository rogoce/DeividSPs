
-- Proceso que genera la cantidad de salvados
-- Creado: 01/09/2010  -Autor: Roman Gordon

DROP PROCEDURE sp_rec714;

CREATE PROCEDURE "informix".sp_rec714(a_user char(8))
returning integer;

define _cod_ajustador	char(3);
define _fecha			date;
define _guardados		integer;

let _fecha = date(current);

select cod_ajustador 
  into _cod_ajustador
  from recajust
 where usuario=a_user;

select count(*)
  into _guardados
  from atcdocde
 where cod_ajustador	= _cod_ajustador
   and date(fecha_completado) = _fecha;
   
return _guardados;

end procedure
		   
