--drop procedure sp_rec113;

create procedure "informix".sp_rec113()
RETURNING INTEGER, CHAR(100);
		  	
define _transaccion	char(10);
Define _no_tranrec  CHAR(10); 
Define _error_cod	INTEGER;
Define _error_desc	CHAR(100);

Set Isolation To Dirty Read;

foreach
 select transaccion
   into _transaccion
   from respen0512

	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where transaccion = _transaccion;

	delete from recasien
	 where no_tranrec = _no_tranrec;

--{
	Call sp_par71(_no_tranrec) RETURNING _error_cod, _error_desc;

	If _error_cod <> 0 then
		return _error_cod, _error_desc;
	end if
--}

End Foreach;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";	

return _error_cod, _error_desc;
	
end procedure