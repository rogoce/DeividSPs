drop procedure sp_par187;

create procedure sp_par187()

define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_factura	char(10);
define _no_factura2	char(10);
define _cantidad	integer;

foreach 
 select no_poliza,
        no_endoso,
		no_factura
   into _no_poliza,
        _no_endoso,
		_no_factura
   from endedmae
  where actualizado  = 1
    and cod_endomov  = "014"
--    and no_factura   = "01-329313"           

	select count(*)
	  into _cantidad
	  from endedmae
	 where no_factura = _no_factura;

	if _cantidad > 1 then

		let _no_factura2 = trim(_no_factura) || "F";
		
		update endedmae
		   set no_factura = _no_factura2
		 where no_poliza  = _no_poliza
		   and no_endoso  = _no_endoso;
		     	
		update endedhis
		   set no_factura = _no_factura2
		 where no_poliza  = _no_poliza
		   and no_endoso  = _no_endoso;

	end if

end foreach

end procedure