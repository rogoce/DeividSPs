-- Procedure que Verifica las reservas de salud que no se afectaron por transacciones

drop procedure sp_rec145;

create procedure sp_rec145()
returning char(20),
          char(10),
          dec(16,2),
          dec(16,2),
		  dec(16,2);

define _numrecla	char(20);
define _no_tranrec  char(10);
define _no_reclamo	char(10);
define _transaccion	char(10);

define _reserva		dec(16,2);
define _monto		dec(16,2);
define _pagos		dec(16,2);

define v_filtros	char(255);

let v_filtros = sp_rec02("001", "001", "2007-03");

foreach
 select	numrecla,
        reserva_total,
		no_reclamo
   into _numrecla,
        _reserva,
		_no_reclamo
   from tmp_sinis
  where cod_ramo = "018"

	let _pagos = 0.00;

   foreach	
	select no_tranrec,
	       transaccion
	  into _no_tranrec,
	       _transaccion
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and fecha        < "27/03/2007"
	   and cod_tipotran = "004"
	
		select sum(monto)
		  into _monto
		  from rectrcob
		 where no_tranrec = _no_tranrec
		   and monto      > 0
		   and variacion  = 0; 	

		if _monto is null then
			let _monto = 0;
		end if

		let _pagos = _pagos + _monto;

{
		if _monto <> 0 then

			return _numrecla,
			       _transaccion,
			       _reserva,
				   _monto,
				   _pagos
				   with resume;

		end if
}

	end foreach

--{

	if _pagos > _reserva then
		let _pagos = _reserva;
	end if

	if _pagos <> 0 then

		return _numrecla,
		       "",
		       _reserva,
			   0.00,
			   _pagos
			   with resume;

	end if

--}

end foreach	   

drop table tmp_sinis;

end procedure