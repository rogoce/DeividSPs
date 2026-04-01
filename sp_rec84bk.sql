
drop procedure sp_rec84;

create procedure "informix".sp_rec84(
a_compania 		char(3), 
a_no_reclamo 	char(20),
a_todos			smallint,
a_fecha_desde	char(10),
a_fecha_hasta	char(10),
a_tran			char(10) default '*'
) 
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

set isolation to dirty read;

select no_reclamo
  into _no_reclamo
  from recrcmae
 where numrecla = a_no_reclamo;

if a_todos = 0 then

	let _fecha_desde  = a_fecha_desde;
	let _fecha_hasta  = a_fecha_hasta;

end if

foreach
 select cod_cpt,
		no_tranrec,
		fecha_factura
   into	_cod_cpt,
		_no_tranrec,
		_fecha_factura
   from rectrmae
  where no_reclamo   = _no_reclamo
    and transaccion  matches a_tran
    and actualizado  = 1
	and (cod_tipotran = "004"
	 or  cod_tipotran = "013")

	if _fecha_factura is null then
		continue foreach;
	end if

	if a_todos = 0 then

		if _fecha_factura >= _fecha_desde and
		   _fecha_factura <= _fecha_hasta then
		else
			continue foreach;
		end if

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
