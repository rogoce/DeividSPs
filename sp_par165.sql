-- Procedimiento que retorna el Codigo y el Nombre de los Terceros
-- 
-- Creado     : 13/01/2005 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par165;		

create procedure "informix".sp_par165()
returning char(5),
          char(50);

define _codigo	char(5);
define _nombre	char(50);

set isolation to dirty read;

foreach

select ter_codigo,
       ter_descripcion
  into _codigo,
       _nombre
  from cglterceros

return _codigo,
       _nombre
  with resume;
	
end foreach

end procedure