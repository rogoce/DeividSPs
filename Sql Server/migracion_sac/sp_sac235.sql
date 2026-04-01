-- Procedure que informa la cantidad de registros pendientes de mayorizar


drop procedure sp_sac235;

create procedure sp_sac235()
returning char(20),
          char(7),
		  integer;

define _periodo	char(7);
define _origen	char(20);
define _cant	integer;

define _mes		smallint;
define _ano		smallint;

let _origen = "Produccion";

foreach 
 select periodo,
        count(*)
   into _periodo,
        _cant
   from endedmae
  where actualizado  = 1
    and sac_asientos <> 2
  group by 1
  order by 1
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

let _origen = "Cobros";

foreach 
 select periodo,
        count(*)
   into _periodo,
        _cant
   from cobredet
  where actualizado  = 1
    and sac_asientos <> 2
  group by 1
  order by 1
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

let _origen = "Reclamos";

foreach 
 select periodo,
        count(*)
   into _periodo,
        _cant
   from rectrmae
  where actualizado  = 1
    and sac_asientos <> 2
  group by 1
  order by 1
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

let _origen = "Reaseguro";

foreach 
 select periodo,
        count(*)
   into _periodo,
        _cant
   from sac999:reacomp
  where sac_asientos <> 2
  group by 1
  order by 1
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

let _origen = "Cheques Pag";

foreach 
 select periodo,
        count(*)
   into _periodo,
        _cant
   from chqchmae
  where pagado        = 1
    and sac_asientos <> 2
  group by 1
  order by 1
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

let _origen = "Cheques Anu";

foreach 
 select year(fecha_anulado),
        month(fecha_anulado),
        count(*)
   into _ano,
        _mes,
        _cant
   from chqchmae
  where pagado        = 1
    and anulado       = 1
    and sac_anulados <> 2
  group by 1, 2
  order by 1, 2

	if _mes < 10 then
		
		let _periodo = _ano || "-0" || _mes;

	else

		let _periodo = _ano || "-" || _mes;
		 
	end if
  	
	return _origen,
	       _periodo,
		   _cant
		   with resume;

end foreach

return "Completado", "9999-99", 0;

end procedure
