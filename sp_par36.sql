-- Procedimiento que arregla la Cobertura de Reaseguro para las Fianzas

--drop procedure sp_par36;

create procedure sp_par36()
returning char(10),
		  char(5),
		  smallint;	

define _no_poliza      char(10);
define _no_unidad      char(5); 
define _no_cambio      smallint;
define _cod_cober_reas char(3); 

foreach
 select no_poliza,
 		no_unidad,
		no_cambio
   into	_no_poliza,
 		_no_unidad,
		_no_cambio
   from emireama
  where cod_cober_reas in ("023", "024")

	select cod_cober_reas
	  into _cod_cober_reas
	  from emireama
	 where no_poliza      = _no_poliza
	   and no_unidad      = _no_unidad
	   and no_cambio      = _no_cambio
	   and cod_cober_reas = "008";

	if _cod_cober_reas is not null then
		return _no_poliza,
			   _no_unidad,
			   _no_cambio
			   with resume;
	end if
	
end foreach
		
end procedure;