-- Fecha del Ultimo Pago para Subir a BO 
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo041;

create procedure "informix".sp_bo041()
returning integer,
          char(100);

define _fecha_ult_pago	date;
define _monto_ult_pago	dec(16,2);
define _no_documento	char(20);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

delete from boultpag;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc)||" poliza: "||_no_documento;
end exception

foreach
 select no_documento
   into _no_documento
   from emipoliza

	let _fecha_ult_pago = null;
	let _monto_ult_pago = 0.00;

	foreach
	 select fecha,
	        monto
	   into _fecha_ult_pago,
	        _monto_ult_pago
	   from cobredet
	  where doc_remesa  = _no_documento
	    and actualizado = 1
	    and tipo_mov    = "P"
	  order by fecha desc
		
		exit foreach;
		
	end foreach		

	if _fecha_ult_pago is null then

		select min(fecha_primer_pago)
		  into _fecha_ult_pago
		  from emipomae
		 where no_documento = _no_documento;

	end if 

	if _fecha_ult_pago is null then

		select min(fecha_suscripcion)
		  into _fecha_ult_pago
		  from emipomae
		 where no_documento = _no_documento;

	end if 

	insert into boultpag
	values (_no_documento, _fecha_ult_pago, _monto_ult_pago);

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure