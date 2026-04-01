-- Procedimiento que verifica los Reclamos si ya existe un reclamo abierto
-- creado 05/02/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_yos11;		
create procedure "informix".sp_yos11(a_no_poliza varchar(10), a_fecha_siniestro date)
returning	varchar(18);
			
define 	_numrecla		varchar(18);
let 	_numrecla    	= null;

	foreach 
		select numrecla
		  into _numrecla
		  from recrcmae
		 where no_poliza 	= a_no_poliza
		   and fecha_siniestro 	= a_fecha_siniestro

		return	_numrecla
		with resume;
	end foreach
	if _numrecla is null then
		return	_numrecla
		with resume;
	end if
end procedure