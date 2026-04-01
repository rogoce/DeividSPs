-- Validacion de la cuenta 26612

drop procedure sp_rec250;

create procedure sp_rec250()
returning char(10),
          dec(16,2);

define _transaccion	char(10);
define _no_tranrec	char(10);
define _cantidad	smallint;
define _monto		dec(16,2);

foreach
 select transaccion,
        no_tranrec,
		monto
   into _transaccion,
        _no_tranrec,
		_monto
   from rectrmae
  where periodo      = "2015-06" 
    and actualizado  = 1
	and cod_tipotran = "004"
	and monto        <> 0
  
	select count(*)
	  into _cantidad
	  from recasien
     where no_tranrec = _no_tranrec
	   and cuenta     = "26612";

	if _cantidad is null then
		let _cantidad = 0;
	end if
	
	if _cantidad <> 1 then
	
		return _transaccion,
		       _monto
		  with resume;
		  
	end if
   
end foreach

return "", 0;

foreach
 select transaccion
   into _transaccion
   from reccietr
  where periodo = "2015-06" 
  
	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where transaccion = _transaccion;

	select count(*)
	  into _cantidad
	  from recasien
     where no_tranrec = _no_tranrec
	   and cuenta     = "26612";

	if _cantidad is null then
		let _cantidad = 0;
	end if
	
	if _cantidad <> 1 then
	
		return _transaccion,
		       0
		  with resume;
		  
	end if
   
end foreach

return "", 0;

end procedure 

