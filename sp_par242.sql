-- Poner reserva para transacciones del 2007 para movimiento de los auditores

DROP PROCEDURE sp_par242;

CREATE PROCEDURE "informix".sp_par242()
returning char(20),
          char(50);

define _numrecla 	char(20);
define _no_reclamo	char(10);
define _transaccion	char(10);

define _error		integer;
define _error_desc	char(50);

foreach
 select reclamo
   into _numrecla
   from deivid_tmp:vardism0612

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	foreach
	 select transaccion
	   into _transaccion
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and periodo[1,4] = 2007
		and actualizado  = 1

		call sp_par241(_transaccion) returning _error, _error_desc;

		return _numrecla,
		       _transaccion
			   with resume;

	end foreach

end foreach

return "0", "Actualizacion Exitosa";

end procedure 
