-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

--drop procedure sp_rec170;

create procedure "informix".sp_rec170()
returning char(1),
          char(100);

define _no_requis 	char(10);
define _fecha		date;
define _transaccion	char(10);

define _cantidad	smallint;


let _no_requis = "323437";
let _fecha     = mdy(12,29,2009);

foreach
 select nt
   into _transaccion
   from deivid_tmp:panamotor

	select count(*)
	  into _cantidad
	  from rectrmae
	 where transaccion = _transaccion;

	if _cantidad <> 1 then
		return 1, "Cantidad de transacciones Erradas " || _cantidad;
	end if

	update rectrmae
	   set pagado       = 1,
		   no_requis    = _no_requis,
		   fecha_pagado = _fecha
	 where transaccion  = _transaccion;

end foreach

return 0, "Actualizacion Exitosa";

end procedure