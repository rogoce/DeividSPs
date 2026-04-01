-- Auto Completa solo RC


drop procedure sp_rec228;

create procedure "informix".sp_rec228()
returning char(20),
          smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _numrecla	CHAR(20);
define _no_reclamo	char(10);
define _no_tranrec	char(10);
define _cantidad	smallint;

define _monto		dec(16,2);
define _monto_dpa	dec(16,2);
define _monto_ase	dec(16,2);
define _reserva_ini	dec(16,2);

define _cod_cobertura	char(5);


foreach
 select reclamo
   into _numrecla
   from deivid_tmp:tmp_autocomp

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	select count(*)
	  into _cantidad
	  from recterce
	 where no_reclamo = _no_reclamo;

	if _cantidad <> 0 then

		let _monto_dpa   = 0;
		let _monto_ase   = 0;

		select variacion
		  into _reserva_ini
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1
		   and cod_tipotran = "001";

		if _reserva_ini is null then
			let _reserva_ini = 0;
		end if
					
		foreach
		 select no_tranrec
		   into	_no_tranrec
		   from rectrmae
		  where no_reclamo   = _no_reclamo
		    and actualizado  = 1
			and cod_tipotran = "004"

			foreach
			 select monto,
			        cod_cobertura
			   into	_monto,
			        _cod_cobertura
			   from rectrcob
			  where no_tranrec = _no_tranrec
			    and monto      <> 0

				if _cod_cobertura in ("00102", "00113") then

					let _monto_dpa = _monto_dpa + _monto;

				else

					let _monto_ase = _monto_ase + _monto;

				end if				

			end foreach

		end foreach

		if _monto_ase  = 0 and
		   _monto_dpa <> 0 then

			return _numrecla,
			       _cantidad,
				   _reserva_ini,
				   _monto_dpa,
				   _monto_ase
			       with resume;
		       
		end if			

	end if			

end foreach

end procedure