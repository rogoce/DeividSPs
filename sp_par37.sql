drop procedure sp_par37;

create procedure sp_par37()

define _no_poliza			char(10);
define _fecha_suscripcion	date;
define _fecha_impresion		date;

foreach
 select no_poliza,
        fecha_suscripcion,
	    fecha_impresion
   into _no_poliza,
        _fecha_suscripcion,
	    _fecha_impresion
   from emipomae
  where cod_ramo          = "018"
    and fecha_suscripcion > fecha_impresion
    and nueva_renov       = "N"
    and actualizado       = 1

	update emipomae
	   set fecha_impresion = fecha_suscripcion
	 where no_poliza       = _no_poliza;

	{
	update emipouni
	   set fecha_emision = _fecha_suscripcion
	 where no_poliza     = _no_poliza
	   and fecha_emision = _fecha_impresion;

	update emidepen
	   set date_added    = _fecha_suscripcion
	 where no_poliza     = _no_poliza
	   and date_added    = _fecha_impresion;
	}

end foreach

end procedure;