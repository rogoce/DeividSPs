-- Procedure que determina que transacciones de reclamos de reaseguro no se les genero asientos

-- Creado:	27/09/2013	Autor:	Demetrio Hurtado Almanza

drop procedure sp_rea055;

create procedure "informix".sp_rea055()
returning smallint,
          char(50);

define _no_registro	char(10);
define _cantidad	smallint;

foreach
 select no_registro
   into _no_registro
   from sac999:reacomp
  where periodo       = "2013-09"
    and sac_asientos  = 2
	and tipo_registro = 3

	select count(*)
	  into _cantidad
	  from sac999:reacompasie
	 where no_registro = _no_registro;

	if _cantidad = 0 then

		update sac999:reacomp
		   set sac_asientos = 0
		 where no_registro  = _no_registro;

		return 1, "Registro de Reaseguro " || _no_registro with resume;

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure