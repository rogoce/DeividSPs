drop procedure sp_rec229;

create procedure sp_rec229()
returning char(50),
          integer,
          dec(16,2);

define _numrecla	char(20);
define _no_reclamo	char(10);
define _no_orden	char(10);

define _cantidad	smallint;
define _cant_rep	integer;
define _tipo		smallint;

define _cod_ramo	char(2);
define _variacion	dec(16,2);
define _pagos		dec(16,2);


create temp table tmp_repuesto(
cod_ramo	char(2),
tipo		smallint,
cantidad	smallint,
incurrido	dec(16,2)
) with no log;

foreach
 select	numrecla,
		no_reclamo
   into	_numrecla,
		_no_reclamo
   from recrcmae
  where actualizado   = 1
    and periodo       >= "2014-01"
	and numrecla[1,2] in ("02", "23")
	and perd_total    = 0

	select count(*)
	  into _cantidad
	  from recordma
	 where no_reclamo    = _no_reclamo;

	if _cantidad = 0 then
		continue foreach;
	end if

	select sum(variacion)
	  into _variacion
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;
		
	select sum(monto)
	  into _pagos
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1
	   and cod_tipotran in ("004", "005", "006", "007");

	select count(*)
	  into _cantidad
	  from recordma
	 where no_reclamo    = _no_reclamo
	   and tipo_ord_comp = "C";

	if _cantidad = 0 then

		let _cant_rep = _cantidad;

		{
		select count(*)
		  into _cantidad
		  from recordma
		 where no_reclamo    = _no_reclamo
		   and tipo_ord_comp = "R";

		if _cantidad = 0 then 
			continue foreach;
		end if

		return _numrecla,
		       _cant_rep
			   with resume;
		--}

	else

--		continue foreach;

		let _cant_rep = 0;

		foreach
		 select	no_orden
		   into	_no_orden
		   from recordma
		  where no_reclamo    = _no_reclamo
	        and tipo_ord_comp = "C"

			select count(*)
			  into _cantidad
			  from recordde
			 where no_orden = _no_orden;
	
				let _cant_rep = _cant_rep + _cantidad;

		end foreach

	end if

	if _cant_rep = 0 then
		let _tipo = 0;
	elif _cant_rep = 1 then
		let _tipo = 1;
	elif _cant_rep >= 2 and _cant_rep <= 5 then
		let _tipo = 2;
	elif _cant_rep > 5 then
		let _tipo = 3;
	end if

	insert into	tmp_repuesto
	values (_numrecla[1,2], _tipo, 1, _pagos + _variacion);

	--{
	return _numrecla,
	       _cant_rep,
		   _pagos + _variacion
		   with resume;
	--}

end foreach

foreach
 select cod_ramo,
        tipo,
		sum(cantidad),
		sum(incurrido)
   into _cod_ramo,
        _tipo,
		_cant_rep,
		_pagos
   from tmp_repuesto
  group by 1, 2
  order by 1, 2

	if _tipo = 0 then
		let _numrecla = "Sin Repuesto";
	elif _tipo = 1 then
		let _numrecla = "1 Repuesto";
	elif _tipo = 2 then
		let _numrecla = "2 a 5 Repuestos";
	elif _tipo = 3 then
		let _numrecla = "Mas de 5 Repuestos";
	end if

	return _cod_ramo || " " || _numrecla,
	       _cant_rep,
		   _pagos
		   with resume;

end foreach

drop table tmp_repuesto;

return "0", 0, 0;

end procedure
