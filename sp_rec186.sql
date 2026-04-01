-- Procedimiento que verifica las reservas de reclamos de un periodo vs el periodo anterior
 
-- Creado     :	04/12/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec186;		

create procedure "informix".sp_rec186(a_periodo char(7))
returning char(20),
          char(10),
          dec(16,2),
          char(7);

define _no_reclamo	char(10);
define _numrecla	char(20);
define _reserva_act	dec(16,2);
define _fecha		date;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc

	return _error,
	       _error_isam,
	       0,
		   ""
		   with resume; 

end exception

--set debug file to "sp_rec186.trc";
--trace on;

set isolation to dirty read;

--let _numrecla = "02-0410-00334-10";

-- Reservas Periodo Actual

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _reserva_act
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= a_periodo 
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) < 0 

	select numrecla,
	       fecha_siniestro
	  into _numrecla,
	       _fecha
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	if year(_fecha) = 2010 then

		return _numrecla,
		       _no_reclamo,
			   _reserva_act,
			   a_periodo 
			   with resume; 

	end if

end foreach

end 

return "",
       "",
       0,
	   a_periodo; 

end procedure
