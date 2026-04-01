
drop procedure sp_rec742b;

create procedure "informix".sp_rec742b(a_tran char(10)) 
returning char(100),
            date,
			dec(16,2),
			char(3),
			char(50);

define _no_reclamo		char(10);
define _cod_cpt			char(10);
define _no_tranrec		char(10);
define _fecha_factura	date;
define _gastos_no_cub	dec(16,2);
define _cod_no_cubierto	char(3);
define _nombre_cpt		char(100);
define _nombre_no_cub	char(50);
define _fecha_desde		date;
define _fecha_hasta		date;
--define a_tran           char(10);

foreach
 select cod_cpt,
		fecha_factura
   into	_cod_cpt,
		_fecha_factura
   from rectrmae
  where no_tranrec  = a_tran

	if _fecha_factura is null then
		continue foreach;
	end if

	foreach
	 select	monto_no_cubierto,
			cod_no_cubierto
	   into	_gastos_no_cub,
			_cod_no_cubierto
	   from rectrcob
	  where no_tranrec = a_tran

		if _cod_no_cubierto is null then
			continue foreach;
		end if

		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;

		select nombre
		  into _nombre_no_cub
		  from recnocub
		 where cod_no_cubierto = _cod_no_cubierto;

		return _nombre_cpt,
			   _fecha_factura,
			   _gastos_no_cub,
			   _cod_no_cubierto,
			   _nombre_no_cub
			   with resume;

	end foreach

end foreach

end procedure
