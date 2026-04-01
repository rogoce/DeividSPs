
create procedure sp_par198()
returning char(10),
          char(10),
		  char(5),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cantidad		smallint;
define _prima_suscrita	dec(16,2);
define _prima_bruta		dec(16,2);
define _no_factura		char(10);

foreach
 select no_poliza,
        no_endoso,
		prima_suscrita,
		prima_bruta,
		no_factura
   into _no_poliza,
        _no_endoso,
		_prima_suscrita,
		_prima_bruta,
		_no_factura
   from endedmae
  where periodo = "2005-12"
    and actualizado = 1

	select count(*)
	  into _cantidad
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cantidad = 0 then

		return _no_factura,
		       _no_poliza,
			   _no_endoso,
			   _prima_suscrita,
			   _prima_bruta
			   with resume;

	end if

end foreach


end procedure
