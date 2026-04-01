drop procedure sp_par39;

create procedure sp_par39(a_no_documento char(20))
returning char(10),
		  char(5),
		  char(2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(7),
		  dec(16,2),
		  dec(16,2);
		  	
define _prima_bruta			dec(16,2);
define _no_factura			char(10);
define _periodo				char(7);

define _numfact				char(5);
define _sucursal			char(2);
define _totalfact			dec(16,2);

define _monto_letra			dec(16,2);

foreach
 select no_factura[1,2],
		no_factura[4,10],
		no_factura,
		prima_bruta,
		periodo
   into	_sucursal,
		_numfact,
		_no_factura,
		_prima_bruta,
		_periodo
   from endedmae
  where no_documento = a_no_documento
    and actualizado  = 1
	and activa       = 1

		select totalfact
		  into _totalfact
		  from facturas
		 where numfact  = _numfact
		   and sucursal = _sucursal;

		select sum(monto_letra)
		  into _monto_letra
		  from primacob
		 where documento = _no_factura;

		return _no_factura,
		       _numfact,
			   _sucursal,
			   _prima_bruta,
			   _totalfact,
			   _monto_letra,
			   _periodo,
			   (_prima_bruta - _totalfact),
			   (_prima_bruta - _monto_letra)
			   with resume;
	
end foreach

end procedure;

