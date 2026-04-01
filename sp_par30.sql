-- Unidades Eliminadas sin eliminar emifacon para una poliza

drop procedure sp_par30;
 
create procedure sp_par30(a_no_poliza char(10))
returning char(5),
		  dec(16,2),	
          char(5),
		  dec(16,2);	

define _no_unidad 	char(5);
define _no_unidad2 	char(5);
define _prima_reas  dec(16,2);
define _prima_uni   dec(16,2);

set isolation to dirty read;

foreach
 select sum(prima),
 		no_unidad
   into _prima_reas,
   		_no_unidad
   from emifacon
  where no_poliza = a_no_poliza
    and no_endoso = "00000"
  group by no_unidad

	select no_unidad,
	       prima_neta
	  into _no_unidad2,
	       _prima_uni
	  from emipouni
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

--	if _no_unidad2 is null then

		return _no_unidad,
		       _prima_reas,
		       _no_unidad2,
			   _prima_uni
		       with resume;

--	end if

end foreach

end procedure
