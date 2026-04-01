-- Procedimiento que verifica si el reclamo fue abierto por el proceso de panama asistencia
-- creado 09/03/2021 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec206f;		
create procedure "informix".sp_rec206f(a_no_documento varchar(21), a_no_unidad char(5), a_fecha_siniestro date)
returning	integer;
			
define _cantidad		smallint;

	select count(*)
	  into _cantidad
	  from recpanasi
	 where no_documento 	= a_no_documento
	   and no_unidad 		= a_no_unidad
	   and fecha_siniestro 	= a_fecha_siniestro
	   and procesado 		= 1;
	   
	if _cantidad is null then
		let _cantidad = 0;
	end if
	
return	_cantidad;

end procedure