-- Procedure que elimina las transacciones pendientes de actualizar

drop procedure sp_rec249;

create procedure sp_rec249()
returning char(10),
          char(20),
		  integer,
		  char(50);
		  
define _no_tranrec		char(10);
define _fecha			date; 
define _periodo			char(7); 
define _transaccion		char(10);
define _pagado			smallint;
define _anular_nt		char(10);
define _no_requis		char(10);
define _user_anulo		char(8);
define _fecha_anulo		date;
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _numrecla		char(20);

define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

let _cantidad	= 0;
		  
foreach		  
 select no_tranrec,
        fecha, 
        periodo, 
		transaccion, 
		pagado, 
		anular_nt, 
		no_requis, 
		user_anulo, 
		fecha_anulo, 
		monto, 
		variacion, 
		numrecla
   into _no_tranrec,
        _fecha, 
        _periodo, 
		_transaccion, 
		_pagado, 
		_anular_nt, 
		_no_requis, 
		_user_anulo, 
		_fecha_anulo, 
		_monto, 
		_variacion, 
		_numrecla	
   from rectrmae
  where actualizado		= 0
    and (today - fecha)	> 365
--    and monto			= 0
--    and variacion		= 0
    and no_requis		is null
    and anular_nt		is null
    and transaccion		is null
	and no_tranrec		not in ("422869", "627430", "1112410", "1186550")
  order by fecha

	let _cantidad	= _cantidad + 1;
  
	call sp_rec248(_no_tranrec) returning _error, _error_desc;
	
	return _no_tranrec,
	       _numrecla,
		   _error,
		   _error_desc
		   with resume;
		   
	if _cantidad >= 500 then
		exit foreach;
	end if
  
  end foreach
  
return "", "", 0, "Actualizacion Exitosa";

end procedure
