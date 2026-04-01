-- Procedimiento que verifica los Reclamos para la Carga de Pma Asistencias
-- creado 05/02/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec206c;		
create procedure "informix".sp_rec206c()
returning	integer;
			
define _cantidad		smallint;
define _fecha_hoy	    date;
define _fecha_anterior	    date;
define _no_documento    char(21);
define _no_unidad       char(5);

set isolation to dirty read;

--set debug file to "sp_rec206c.trc"; 
--trace on;

let _fecha_hoy	= current;
let _fecha_anterior = _fecha_hoy - 1 units day;

foreach
	select no_documento, 
		   no_unidad
	  into _no_documento,
		   _no_unidad
	  from recpanasi
	 where date_added = _fecha_anterior
  order by no_documento
  
  select count(*)
    into _cantidad
	from recrcmae
   where no_documento = _no_documento
	 and no_unidad = _no_unidad
	 and user_added = 'informix'
	 and fecha_reclamo = _fecha_anterior;
	
	if _cantidad = 0 then
	   update recpanasi
		  set procesado = 0
			  --date_added = _fecha_hoy	  
		where no_documento = _no_documento
		  and no_unidad    = _no_unidad
		  and date_added   = _fecha_anterior;
	end if
	if _cantidad > 0 then
	   update recpanasi
		  set procesado = 1
			  --date_added = _fecha_hoy	  
		where no_documento = _no_documento
		  and no_unidad    = _no_unidad
		  and date_added   = _fecha_anterior;
	end if
end foreach
  
return	0;

end procedure