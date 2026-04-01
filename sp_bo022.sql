-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

--drop procedure sp_bo022;

create procedure "informix".sp_bo022()
returning integer,
          char(50);

define _periodo			char(7);
define _no_documento	char(20);
define _cantidad		integer;

let _cantidad = 0;

foreach
 select no_documento,
        periodo
   into _no_documento,
        _periodo
   from cobmoros
  where monto_ult_pago is null
  	
	let _cantidad       = _cantidad + 1;

	update cobmoros
	   set monto_ult_pago = 0.00
	 where no_documento   = _no_documento
	   and periodo		  = _periodo;

end foreach

return _cantidad, " Registros Procesados";

end procedure