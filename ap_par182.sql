--drop procedure ap_par182;

create procedure "informix".ap_par182()
returning char(20),
          char(5),
		  char(3),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);
define _no_unidad		char(10);
define _cod_perpago		char(3);
define _nombre_perpago	char(50);
define _no_documento	char(20);
define _prima_neta		dec(16,2);
define _prima_total		dec(16,2);
define _prima_asegurado	dec(16,2);
define _recargo			dec(16,2);
define _descuento		dec(16,2);
define _meses			integer;

set isolation to dirty read;

foreach
 select no_poliza,
		cod_perpago,
		no_documento
   into _no_poliza,
		_cod_perpago,
		_no_documento
   from emipomae
  where cod_ramo       = "018"
    and actualizado    = 1
	and estatus_poliza = 1
--	and cod_perpago    = "002"

	select nombre,
	       meses
	  into _nombre_perpago,
	       _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;
	
	if _meses = 0 then
		let _meses = 1;
	end if
	 
	foreach
	 select no_unidad,
	        prima_neta,
	        prima_total,
			prima_asegurado,
			descuento,
			recargo
	   into _no_unidad,
	        _prima_neta,
	        _prima_total,
			_prima_asegurado,
			_descuento,
			_recargo
	   from emipouni
	  where no_poliza = _no_poliza
	    and activo    = 1
	  
		if (_prima_asegurado * _meses) <> _prima_total then

--		if _prima_total <> _prima_asegurado then

{
			update emipouni
			   set prima_total = _prima_asegurado * _meses
			 where no_poliza   = _no_poliza
			   and no_unidad   = _no_unidad;
}

			return _no_documento,
			       _no_unidad,
				   _cod_perpago,
				   _nombre_perpago,
--				   ((_prima_asegurado  * _meses) - _descuento + _recargo),
                   _prima_asegurado  * _meses,
				   _prima_total,
				   _prima_asegurado,
				   _descuento,
				   _recargo
				   with resume;

--		end if

		end if

	end foreach            	

end foreach

return "0",
       "0",
	   "0",
	   "",
	   0.00,
	   0.00,
	   0.00,
	   0.00,
	   0.00;

end procedure