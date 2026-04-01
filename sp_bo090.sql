-- Procedure que realiza el calculo de la reserva de prima no devengada

create procedure sp_bo090(a_fecha date)
returning integer,
          char(50);

define _dias_pt			integer;
define _reserva_pnd		dec(16,2);
		  
define _dias_vigencia		integer;
define _vigencia_inic		date;
define _vigencia_final	date;

define _prima_suscrita	dec(16,2);		  
define _comision_agente	dec(16,2);
define _impuesto_2%		dec(16,2);

define _prima_diaria		dec(16,6);
		  
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

foreach
 select vigencia_inic,
        vigencia_final,
		prima_suscrita
   into _vigencia_inic,
        _vigencia_final,
		_prima_suscrita
   from endedmae
  where no_documento	= "0208-00449-01"
    and actualizado	= 1
	and vigencia_inic	<= a_fecha
	and vigencia_final	>= a_fecha
	and prima_suscrita	<> 0

	let _comision_agente	= 0;
	let _impuesto_2%		= 0;
	
	let _dias_vigencia	= _vigencia_final - _vigencia_inic;
	let _prima_diaria	= (_prima_suscrita - _comision_agente - _impuesto_2%) / _dias_vigencia;
	
	let _dias_pt		= _vigencia_final - a_fecha;
	let _reserva_pnd	= _prima_diaria * _dias_pt;
	
end foreach  
 
end

return 0, "Actualizacion Exitosa";

		  
end procedure



