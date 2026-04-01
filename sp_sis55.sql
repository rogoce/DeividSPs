-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis55;

create procedure "informix".sp_sis55()
returning char(20),
          char(10),
          dec(16,2),
          dec(16,2),
          dec(16,2);

define _no_poliza    char(10);
define _cantidad	 integer;
define _error		 integer;
define _porcentaje	 dec(16,2);
define _no_documento char(20);
define _no_factura   char(10);

define _prima_suscrita	dec(16,2);
define _prima_calc		dec(16,2);
define _prima_suma		dec(16,2);

set isolation to dirty read;

let _error = 0;

foreach 
 select no_poliza,
        prima_suscrita,
		no_documento,
		no_factura
   into _no_poliza,
        _prima_suscrita,
		_no_documento,
		_no_factura
   from endedmae
  where actualizado = 1
	and periodo >= "2003-01"
	and periodo <= "2003-12"

	let _prima_suma = 0.00;

   foreach
	select porc_partic_agt
	  into _porcentaje
	  from emipoagt
	 where no_poliza = _no_poliza

		let _prima_calc = _prima_suscrita * _porcentaje / 100;
		let _prima_suma = _prima_suma + _prima_calc;

	end foreach

--	if _prima_suma <> _prima_suscrita then
		
		let _prima_calc = _prima_suscrita - _prima_suma;

		return _no_documento,
		       _no_factura,
			   _prima_suscrita,
			   _prima_suma,
			   _prima_calc
			   with resume;

--	end if


end foreach

end procedure