drop procedure sp_par109;

create procedure "informix".sp_par109()
returning char(10),
          dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(10),
		  char(5),
		  char(5);

define _prima_suscrita_endoso	dec(16,2);
define _prima_suscrita_unidad	dec(16,2);
define _no_poliza				char(10);
define _no_endoso				char(5);
define _no_factura				char(10);
define _cod_ramo				char(3);
define _no_unidad				char(5);
define _no_motor				char(30);
define _cod_tipomov				char(3);
define _nombre_mov				char(50);
define _procesar				integer;
define _cod_marca				char(5);

set isolation to dirty read;

foreach
 select prima_suscrita,
        no_poliza,
		no_endoso,
		no_factura,
		cod_endomov
   into _prima_suscrita_endoso,
        _no_poliza,
		_no_endoso,
		_no_factura,
		_cod_tipomov
   from endedmae
  where actualizado    = 1
--	and periodo[1,4]   = 2004
    and prima_suscrita <> 0.00
--	and no_factura     = "01-271310"

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "002" then
		continue foreach;
	end if

	let _procesar = 0;

   foreach
	select prima_suscrita,
	       no_unidad
	  into _prima_suscrita_unidad,
	       _no_unidad
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso

		select no_motor
		  into _no_motor
		  from endmoaut
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad; 		

		if _no_motor is null then

			let _procesar = 1;

			select nombre
			  into _nombre_mov
			  from endtimov
			 where cod_endomov = _cod_tipomov;

			return _no_factura,
			       _prima_suscrita_endoso,
				   _prima_suscrita_unidad,
				   _cod_tipomov,
				   _nombre_mov,
				   _no_poliza,
				   _no_endoso,
				   _no_unidad
				   with resume;
		else

			select cod_marca
			  into _cod_marca
			  from emivehic
			 where no_motor = _no_motor;

			if _cod_marca is null then

				select nombre
				  into _nombre_mov
				  from endtimov
				 where cod_endomov = _cod_tipomov;

				return _no_factura,
				       _prima_suscrita_endoso,
					   _prima_suscrita_unidad,
					   _cod_tipomov,
					   _nombre_mov,
					   _no_poliza,
					   _no_endoso,
					   _no_unidad
					   with resume;
			
			end if

		end if

	end foreach

{
	if _procesar = 1 then
		call sp_sis57(_no_poliza, _no_endoso);
	end if
}

end foreach

end procedure