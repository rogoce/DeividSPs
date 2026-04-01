-- Verificacion de los productos de salud que tienen vida

-- Creado    : 06/05/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_par215 - DEIVID, S.A.

drop procedure sp_par215;

create procedure "informix".sp_par215()
returning char(5),
          char(5),
          char(50),
	  dec(16,2);

define _cod_producto	char(5);
define _nombre			char(50);
define _prima_vida		dec(16,2);
define _prod_nuevo		char(5);

foreach
 select cod_producto,
        nombre
   into _cod_producto,
        _nombre
   from prdprod
  where cod_ramo = "018"

	let _prima_vida = null;
	
	foreach
	 select prima_vida
	   into _prima_vida
	   from prdtaeda
	  where cod_producto = _cod_producto
		exit foreach;
	end foreach

	if _prima_vida is null then
		let _prima_vida = 0.00;
	end if

	if _prima_vida <> 0 then

		select producto_nuevo
		  into _prod_nuevo
		  from prdnewpro
		 where cod_producto = _cod_producto;

		return _cod_producto,
		       _prod_nuevo,
			   _nombre,
			   _prima_vida
			   with resume;

	end if

end foreach

end procedure
