drop procedure sp_par186;

create procedure sp_par186()

define _no_factura	char(10);
define _no_poliza	char(10);
define _no_endoso	char(5);

foreach
 select no_factura
   into _no_factura
   from cobinc0512
  where cancelada = 1

	select no_poliza,
	       no_endoso
	  into _no_poliza,
	       _no_endoso
	  from endedmae
	 where no_factura = _no_factura;

	delete from endedhis
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	CALL sp_pro100(_no_poliza, _no_endoso);
	
end foreach

end procedure
