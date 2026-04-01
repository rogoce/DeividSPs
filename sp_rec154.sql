-- Procedure que marca los bloques de salud que se trabajaron por fuera luego
-- de que la tabla atcdocde se daño el 4 de abril del 2008

drop procedure sp_rec154;

create procedure sp_rec154()
returning integer,
          char(50);

define _no_bloque	char(10);
define _monto_tot	dec(16,2);
define _cantidad	smallint;
define _cod_asig	char(10);
define _fecha		datetime year to second;

let _cantidad = 0;

foreach
 select bloque
   into _no_bloque
   from deivid_tmp:bloques
--  where bloque = "16693"

	let _no_bloque = trim(_no_bloque);
	 
	foreach
	 select cod_asignacion,
	        date_added
	   into _cod_asig,
	        _fecha
	   from atcdocde
	  where cod_entrada = _no_bloque

		let _cantidad = _cantidad + 1;

		update atcdocde
	       set titulo             = "SCAN_FILE.pdf",
			   escaneado          = 1,
			   fecha_scan         = _fecha,
			   user_scan          = "informix",
			   imagen_nueva       = 1,
			   completado         = 1,
			   ajustador_fecha    = _fecha,
			   ajustador_asignado = 1,
			   fecha_completado   = ajustador_fecha
		 where cod_asignacion     = _cod_asig;

	end foreach

	SELECT sum(monto)
	  INTO _monto_tot
	  FROM atcdocde
	 WHERE cod_entrada = _no_bloque;

	update atcdocma
	   set procesado   = 1, 
	       completado  = 1,
		   monto       = _monto_tot
	 where cod_entrada = _no_bloque;

end foreach

return 0, "Actualizacion Exitosa " || _cantidad;

end procedure