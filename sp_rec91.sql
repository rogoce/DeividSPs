-- Cerrar reclamos de automovil previos a enero del 2003 con reserva en cero

-- Creado    : 10/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec91;

create procedure "informix".sp_rec91()
returning char(20),
          dec(16,2);

define _no_reclamo	char(10);
define _numrecla	char(20);
define _variacion	dec(16,2);

foreach
 select no_reclamo,
		numrecla
   into	_no_reclamo,
		_numrecla
   from recrcmae
  where estatus_reclamo = "A"
    and periodo         <= "2002-12"
	and actualizado     = 1
	and numrecla[1,2]	= "02"

	select sum(variacion)
	  into _variacion
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;

	if _variacion <= 0 then
	
{
		update recrcmae
		   set estatus_reclamo = "C"
		 where no_reclamo      = _no_reclamo;
}

--{
		return _numrecla,
		       _variacion
			   with resume;
--}
		
	end if
	  

end foreach

return "0", 0.00;

end procedure