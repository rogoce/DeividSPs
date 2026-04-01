drop procedure sp_par40;

create procedure sp_par40()
returning char(20),
		  char(10),	
		  char(5),	
		  char(5),
          char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50);

define _no_documento	char(20);
define _no_factura		char(10);
define _cod_endomov		char(3);
define _no_unidad		char(5);
define _suma			dec(16,2);
define _suma2			dec(16,2);
define _suma3			dec(16,2);
define _suma4			dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _nombre_endomov	char(50);

foreach 
 select	no_documento,
        no_factura,
		cod_endomov,
		no_poliza,
		no_endoso
   into	_no_documento,
        _no_factura,
		_cod_endomov,
		_no_poliza,
		_no_endoso
   from endedmae
  where actualizado = 1
    and cod_endomov in ("001", "009", "010", "012", "013", "015", "017", "018", "019")
--  and periodo     = "2001-08"
--	and no_poliza   = "80728"
  order by 4, 5

	foreach
	 select suma_asegurada,
	        no_unidad
	   into _suma,
	        _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		if _suma is null then
			let _suma = 0;
		end if

--		if _suma <> 0 then
			
			select suma_asegurada
			  into _suma2
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			   
			 select sum(u.suma_asegurada)
			   into _suma3
			   from endeduni u, endedmae e
			  where u.no_poliza   = _no_poliza
			    and u.no_unidad   = _no_unidad
			    and u.no_poliza   = e.no_poliza
			    and u.no_endoso   = e.no_endoso
				and e.actualizado = 1
				and e.cod_endomov in ("011", "004" ,"005", "006");
				
			if _suma2 <> _suma3 then

				--{
				update endeduni
				   set suma_asegurada = 0
				 where no_poliza      = _no_poliza
				   and no_endoso      = _no_endoso
				   and no_unidad      = _no_unidad;

				update emipouni
				   set suma_asegurada = _suma3
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad;
				  
				select sum(suma_asegurada)
				  into _suma4
				  from emipouni
				 where no_poliza = _no_poliza;

				update emipomae
				   set suma_asegurada = _suma4
				 where no_poliza      =	_no_poliza;
				--}
							    			
				select nombre
				  into _nombre_endomov
				  from endtimov
				 where cod_endomov = _cod_endomov;
		
				return _no_documento,
				       _no_poliza,
					   _no_endoso,
					   _no_unidad,
				       _no_factura,
					   _suma,
					   _suma2, 
					   _suma3,
					   _nombre_endomov
					   with resume;
			end if

--		end if

	end foreach

end foreach

end procedure;