
drop procedure sp_rec742c;

create procedure "informix".sp_rec742c(a_no_tranrec char(10)) 
returning varchar(255);

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
define _descripcion     varchar(255);


foreach
 select fecha_factura,
        no_tranrec
   into	_fecha_factura,
        _no_tranrec
   from rectrmae
  where no_tranrec   = a_no_tranrec

	if _fecha_factura is null then
		continue foreach;
	end if

	foreach
	 select	monto_no_cubierto,
			cod_no_cubierto
	   into	_gastos_no_cub,
			_cod_no_cubierto
	   from rectrcob
	  where no_tranrec = _no_tranrec

		if _cod_no_cubierto is null then
			continue foreach;
		end if

		 foreach	
			select descripcion
			  into _descripcion
			  from blobcobe
			 where no_tranrec = _no_tranrec

			return _descripcion
				   with resume;
		end foreach
	end foreach

end foreach

end procedure
