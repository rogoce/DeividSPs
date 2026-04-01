-- Detalle de Pago para los Proveedores
-- Proyecto Unificacion de los Cheques de Salud

-- Creado: 16/04/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec85;

create procedure "informix".sp_rec85(a_no_requis char(10))
returning char(3),
          char(50);

define _cod_no_cubierto	char(3);
define _nombre			char(50);

set isolation to dirty read;

foreach
 select cod_no_cubierto
   into _cod_no_cubierto
   from recunino
  where no_requis = a_no_requis
  group by cod_no_cubierto

	select nombre
	  into _nombre
	  from recnocub
	 where cod_no_cubierto = _cod_no_cubierto;

	return _cod_no_cubierto,
	       _nombre
		   with resume;

end foreach

end procedure
