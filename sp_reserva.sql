-- Actualizacion para Reclamos de Salud

-- Creado    : 05/10/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/11/2001 - Autor: Demetrio Hurtado Almanza

drop procedure sp_reser;

create procedure sp_reser()
 returning integer,
          	char(100);

define _no_reclamo			char(10);
define _reserva_inicial		dec(16,2);
define _reserva_actual		dec(16,2);
define _error     	    	integer; 

--SET DEBUG FILE TO "sp_rec56.trc";  
--TRACE ON;                                                                 

begin

on exception set _error 
 	return _error, "Error al Actualizar las Reservas en recrcmae";         
end exception           

foreach
	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where actualizado = 1
	   and numrecla[1,2] = "18"

	select sum(reserva_inicial),
	       sum(reserva_actual)
	  into _reserva_inicial,
		   _reserva_actual
	  from recrccob
	 where no_reclamo = _no_reclamo;

	update recrcmae
	   set reserva_inicial = _reserva_inicial,
		   reserva_actual  = _reserva_actual
	 where no_reclamo      = _no_reclamo;

end foreach


end

return 0, "Actualizacion Exitosa ...";

end procedure