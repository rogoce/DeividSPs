-- Procedimiento que crea los registros para programa de 3 opciones en renovacion.

-- CREADO: 14/11/2001 POR: Amado
-- CREADO: 26/11/2004 POR: Armando

drop procedure sp_pro82a;

create procedure "informix".sp_pro82a(v_poliza char(10),a_no_unidad char(5))
returning char(3),		--cod_descuento
		  char(50),	
		  dec(5,2); 	--% descuento

--- Actualizacion de Polizas

DEFINE _cod_descuen	   char(3);
DEFINE _porc_descuento dec(5,2);
define _nombre		   char(50);

define _cantidad	   smallint;
					
--SET DEBUG FILE TO "sp_pro82.trc"; 
--trace on;

BEGIN

	foreach
	 SELECT cod_descuen,
			porc_descuento
	   INTO _cod_descuen,
			_porc_descuento
	   FROM emiunide
	  WHERE no_poliza = v_poliza
	    AND no_unidad = a_no_unidad

     select nombre
	   into _nombre
	   from emidescu
	  where cod_descuen = _cod_descuen;

	end foreach

	return _cod_descuen,
		   _nombre,
	       _porc_descuento WITH RESUME;

END
end procedure;
