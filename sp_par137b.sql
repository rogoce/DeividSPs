--drop procedure sp_par137;

create procedure "informix".sp_par137b()
returning char(10),
          dec(16,2),
          char(1);

define _no_requis	char(10);
define _monto		dec(16,2);
define _error		integer;
define _tipo_requis char(1);

set isolation to dirty read;

foreach
 select no_requis,
        tipo_requis
   into _no_requis,
        _tipo_requis
   from chqchmae
  where pagado = 1
    and fecha_impresion  = today
--    and year(fecha_impresion)  = 2005
--    and year(fecha_impresion)  = year(today)
--    and month(fecha_impresion) = month(today)

	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	if _monto <> 0.00 then
		
--		call sp_che32(_no_requis) returning	_error;

		return _no_requis,
		       _monto,
			   _tipo_requis
			   with resume;

	end if
	
end foreach

return "0",
        0.00,
        "";

end procedure
