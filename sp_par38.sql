drop procedure sp_par38;

create procedure sp_par38()
returning char(5), 
          char(5),
          char(10);

define _no_unidad	char(5);
define _cod_endomov	char(3);
define _no_poliza 	char(10);
define _no_endoso	char(5);
define _no_factura 	char(10);

let _no_poliza = "64440";

foreach
 select no_unidad
   into _no_unidad
   from endeduni
  where no_poliza = _no_poliza
    and no_endoso = "00000"

	foreach
	 select no_endoso  
	   into _no_endoso
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso <> "00000"
		and no_unidad = _no_unidad

		select cod_endomov,
			   no_factura	
		  into _cod_endomov,
			   _no_factura	
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		if _cod_endomov not in ("002", "003") then
			return _no_unidad,
			       _no_endoso,
				   _no_factura
				   with resume;
		end if

	end foreach

end foreach

end procedure;
