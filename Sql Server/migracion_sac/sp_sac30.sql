-- Procedimiento que retorna el Codigo y el Nombre de los Terceros
-- 
-- Creado     : 13/01/2005 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac30;		

create procedure "informix".sp_sac30(a_cuenta char(25))
returning char(5),
          char(50);

define _codigo	char(5);
define _nombre	char(50);

set isolation to dirty read;

foreach
 select aux_tercero
   into _codigo
   from cglauxiliar
  where aux_cuenta = a_cuenta

	select ter_descripcion
	  into _nombre
	  from cglterceros
	 where ter_codigo = _codigo;

	return _codigo,
	       _nombre
		   with resume;
	
end foreach

end procedure