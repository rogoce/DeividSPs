drop procedure sp_par137c;

create procedure "informix".sp_par137c()
returning char(10),
          dec(16,2),
          varchar(100),
          date;

define _no_requis	char(10);
define _monto		dec(16,2);
define _error		integer;
define _cantidad	integer;
define _ano			integer;
define _desc_cheque varchar(100);
define _fecha_desde date;
define _dia         char(2);
define _mes         char(2);
define _ano2         char(4);

set isolation to dirty read;

let _ano = year(today) - 1;

foreach
 select no_requis
   into _no_requis
   from chqchmae
  where pagado = 1
    and year(fecha_impresion) >= _ano

	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	if _monto <> 0.00 then
		
        select desc_cheque
		  into _desc_cheque
		  from chqchdes
		 where no_requis = _no_requis
		   and renglon = 1;

	     LET _dia = substring(_desc_cheque from 22 for 23);
	     LET _mes = substring(_desc_cheque from 25 for 26);
	     LET _ano2 = substring(_desc_cheque from 28 for 31);

	     LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);

  	  	 call sp_che32c(_no_requis, _fecha_desde) returning	_error;	

		return _no_requis,
		       _monto,
			   _desc_cheque,
			   _fecha_desde
			   with resume;
   
	end if
	
	select count(*)
	  into _cantidad
	  from chqchcta
	 where no_requis = _no_requis;

	if _cantidad = 0 then
		
        select desc_cheque
		  into _desc_cheque
		  from chqchdes
		 where no_requis = _no_requis
		   and renglon = 1;

	     LET _dia = substring(_desc_cheque from 22 for 23);
	     LET _mes = substring(_desc_cheque from 25 for 26);
	     LET _ano2 = substring(_desc_cheque from 28 for 31);

	     LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);

	   	call sp_che32c(_no_requis, _fecha_desde) returning	_error;

		return _no_requis,
		       _monto,
			   _desc_cheque,
			   _fecha_desde
			   with resume;

	end if

end foreach

return "0",
        0.00,
        "",
        date(current);

end procedure