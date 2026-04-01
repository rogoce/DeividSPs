--drop procedure sp_par150;

create procedure "informix".sp_par150()
returning char(10),
          dec(16,2),
          date,
          char(7);

define _no_requis	char(10);
define _monto		dec(16,2);
define _fecha		date;
define _periodo		char(7);

set isolation to dirty read;

foreach
 select no_requis,
        fecha_impresion,
		periodo
   into _no_requis,
        _fecha,
		_periodo
   from chqchmae
  where pagado = 1
  order by fecha_impresion

--  and year(fecha_impresion)  = year(today)
--	and month(fecha_impresion) = month(today)

	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis;

	if _monto <> 0.00 then
		
		return _no_requis,
		       _monto,
			   _fecha,
			   _periodo
			   with resume;

	end if
	
end foreach

end procedure