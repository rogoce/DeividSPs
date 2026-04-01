
drop procedure sp_par66;
create procedure sp_par66()
returning char(10), 
          char(20),
		  char(5),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_factura		char(10);
define _prima1			dec(16,2);
define _prima2			dec(16,2);
define _cod_ramo		char(3);

foreach
 select no_poliza,
        no_endoso,
		prima_suscrita,
		no_factura
   into _no_poliza,
        _no_endoso,
		_prima1,
		_no_factura
   from endedmae
  where periodo = "2002-11"
    and actualizado = 1

	select cod_ramo 
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

--	if _cod_ramo <> "002" then
--		continue foreach;
--	end if
	
	select sum(prima)
	  into _prima2
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima1 <> _prima2 Then
		return _no_factura,
		       _no_poliza,
			   _no_endoso,
			   _prima1,
			   _prima2
			   with resume;
	end if

end foreach

end procedure