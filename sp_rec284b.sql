-- Procedimiento que verifica los Reclamos para la Carga de Pma Asistencias
-- creado 05/02/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec284b;		
create procedure "informix".sp_rec284b(a_no_documento varchar(21), a_no_unidad char(5), a_fecha_siniestro date, a_hora datetime hour to second, a_estado char(1))
returning	integer;
			
define _cantidad		smallint;

	select count(*)
	  into _cantidad
	  from recpanasi_tmp2
	 where no_documento = a_no_documento
	   and no_unidad = a_no_unidad
	   and fecha_siniestro = a_fecha_siniestro
	   and hora_siniestro = a_hora;

	if _cantidad > 0 then
		update recpanasi_tmp2
		   set estado = a_estado
		 where no_documento = a_no_documento
		   and no_unidad = a_no_unidad
		   and fecha_siniestro = a_fecha_siniestro
		   and hora_siniestro = a_hora;
	end if
/*foreach	
select b.no_documento
  into _no_documento
  from recrcmae a inner join recpanasi b on a.no_documento = b.no_documento
 where b.date_added = '06/02/2014'
   and user_added = 'informix'
	
	update recpanasi
	   set procesado = 1
	 where no_documento = _no_documento;
end foreach	*/
return	_cantidad;

end procedure