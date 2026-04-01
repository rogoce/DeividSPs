

drop procedure sp_par195;

create procedure "informix".sp_par195()
returning char(10),
          dec(16,2),
		  dec(16,2),
		  char(10);

define _transaccion	char(10);
define _no_tranrec	char(10);
define _monto		dec(16,2);
define _variacion	dec(16,2);
define _cantidad	integer;
define _cant_coas	integer;
define _no_reclamo	char(10);

foreach
 select	transaccion,
        monto,
		variacion,
		no_tranrec,
		no_reclamo
   into _transaccion,
        _monto,
		_variacion,
		_no_tranrec,
		_no_reclamo
   from rectrmae
  where periodo     = "2005-12"
    and actualizado = 1

	if _monto     = 0 and
	   _variacion = 0 then
		continue foreach;
	end if
	
	select count(*)
	  into _cantidad
	  from recasien
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then

		select count(*)
		  into _cantidad
		  from reccoas
		 where no_reclamo   =  _no_reclamo
		   and cod_coasegur <> "036"; 
		
		if _cantidad <> 0 then
	
			return _transaccion,
			       _monto,
				   _variacion,
				   _no_tranrec 
				   with resume;

		end if

		select count(*)
		  into _cantidad
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato <> 1;

		if _cantidad <> 0 then
	
			return _transaccion,
			       _monto,
				   _variacion,
				   _no_tranrec 
				   with resume;

		end if

	end if

end foreach

end procedure

