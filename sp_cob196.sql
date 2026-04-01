-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

--drop procedure sp_cob196;

create procedure "informix".sp_cob196(
a_no_documento	char(20),
a_periodo 		char(7)
) returning integer,
            char(50);

define _fecha_ult_pago	date;
define _monto_ult_pago	dec(16,2);

let _fecha_ult_pago = null;
let _monto_ult_pago = 0.00;

foreach
 select fecha,
        monto
   into _fecha_ult_pago,
        _monto_ult_pago
   from cobredet
  where doc_remesa  = a_no_documento
    and actualizado = 1
    and tipo_mov    = "P"
    and periodo     <= a_periodo
  order by fecha desc
	
	exit foreach;
	
end foreach		

update cobmoros
   set fecha_ult_pago = _fecha_ult_pago,
       monto_ult_pago = _monto_ult_pago
 where no_documento   = a_no_documento
   and periodo		  = a_periodo;

return 0, "Actualizacion Exitosa";

end procedure