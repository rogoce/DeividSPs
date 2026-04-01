-- Reclamos Perdida Total y Robo

-- 


drop procedure sp_rec201;

create procedure "informix".sp_rec201()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _numrecla	char(20);
define _no_reclamo	char(20);
define _reserva		dec(16,2);
define _monto		dec(16,2);

foreach
 select numrecla,
        no_reclamo
   into _numrecla,
        _no_reclamo
   from recrcmae
  where actualizado = 1
--  and year(fecha_siniestro) = 2012
--	and month(fecha_siniestro) = 11
    and (cod_evento = "008" or perd_total = 1)

	select sum(monto)
	  into _reserva
	  from rectrmae
	 where actualizado  = 1
	   and no_reclamo   = _no_reclamo
	   and cod_tipotran = "001";

	if _reserva is null then
		let _reserva = 0;
	end if

	select sum(monto)
	  into _monto
	  from rectrmae
	 where actualizado  = 1
	   and no_reclamo   = _no_reclamo
	   and cod_tipotran = "004";

	if _monto is null then
		let _monto = 0;
	end if

	return _numrecla,
	       _monto,
		   _reserva
		   with resume;

end foreach

end procedure