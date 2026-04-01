drop procedure sp_par137;

create procedure sp_par137()
returning char(10),
          dec(16,2);

define _no_requis	char(10);
define _monto		dec(16,2);
define _error		integer;
define _cantidad	integer;
define _ano			integer;
define _desc		char(50);
define _anulado     smallint;

set isolation to dirty read;

let _ano = year(today);

foreach
	select no_requis, anulado
	  into _no_requis, _anulado
	  from chqchmae
	 where pagado = 1
	   and year(fecha_impresion) >= _ano
	
    if _no_requis in('743735','1113376','1114773','1132291') then
		continue foreach;
	end if
	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis
	   and tipo      = 1;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	if _monto <> 0.00 then
		
		return _no_requis,
		       _monto
			   with resume;
   
	end if
	
	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis
	   and tipo      = 2;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	if _monto <> 0.00 then
		
		return _no_requis,
		       _monto
			   with resume;
   
	end if

	select count(*)
	  into _cantidad
	  from chqchcta
	 where no_requis = _no_requis;

	if _cantidad = 0 then
		
		return _no_requis, _monto with resume;

	end if
end foreach

foreach
	select no_requis
	  into _no_requis
	  from chqchmae
	 where pagado         = 1
	   and anulado        = 1
	   and fecha_anulado >= "01/08/2007"
	
	if _no_requis in('743735','1113376','1114773') then
		continue foreach;
	end if
	select count(*)
	  into _cantidad
	  from chqchcta
	 where no_requis = _no_requis
	   and tipo      = 2;

	if _cantidad = 0 then
	
--		call sp_par259(_no_requis) returning _error, _desc;
		
		return _no_requis, _cantidad with resume;

	end if

end foreach

return "0",
        0.00;

end procedure