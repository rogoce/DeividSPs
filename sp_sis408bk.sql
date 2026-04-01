--****************************************************************
-- Procedimiento que actualiza en recrcmae el codigo de producto
--****************************************************************

-- Creado    : 14/08/2013 - Autor: Armando Moreno M.
-- Modificado: 14/08/2013 - Autor: Armando Moreno M.

drop procedure sp_sis408bk;

create procedure "informix".sp_sis408bk()
RETURNING char(18),char(10),char(10),char(5),char(30);

--- Actualizacion de Polizas

define _no_reclamo     char(10);
define _cod_producto   char(5);
define _no_poliza      char(10);
define _no_unidad      char(5);
define _numrecla       char(18);


--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN


set isolation to dirty read;


foreach

	select no_poliza,no_unidad,no_reclamo,numrecla
	  into _no_poliza,_no_unidad,_no_reclamo,_numrecla
	  from recrcmae
	 where actualizado = 1
	   and periodo >= '2012-01'

	let _cod_producto = null;

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _cod_producto is null then

		select cod_producto
		  into _cod_producto
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad;

		if _cod_producto is null then

			foreach
				select cod_producto
				  into _cod_producto
				  from endeduni
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad

				exit foreach;
			end foreach

		end if

	end if

	if _cod_producto is null then
		return _numrecla,_no_reclamo,_no_poliza,_no_unidad,' Producto No Conseguido' with resume;
	else
		update recrcmae
		   set cod_producto = _cod_producto
		 where no_reclamo   = _no_reclamo;
	end if

end foreach

return "","","","","Actualizacion Terminada.";

END
end procedure;