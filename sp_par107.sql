drop procedure sp_par107;

create procedure "informix".sp_par107()
returning char(5),
          char(30),
          char(1),
          char(3);

define _cod_producto	char(5);
define _cantidad		integer;
define _nombre			char(50);
define _tipo			char(1);
define _cod_subramo		char(3);

define _prima			dec(16,2);

set isolation to dirty read;

foreach
 select cod_producto,
        nombre,
		tipo_suscripcion,
		cod_subramo
   into _cod_producto,
        _nombre,
        _tipo, 
		_cod_subramo
   from prdprod
  where cod_ramo = "018"
    and cod_subramo in ("006", "007", "008", "009", "010", "011", "012", "013")
  order by 1

	select count(*)
	  into _cantidad
	  from prdpriex
	 where cod_producto = _cod_producto;

	if _cantidad = 0 then

		let _prima = null;

		if _cod_subramo = "008" then

			if _tipo = "1" then
				
				let _prima = 2.90;

			elif _tipo = "2" then

				let _prima = 5.80;

			elif _tipo = "3" then

				let _prima = 8.10;

			end if

		elif _cod_subramo = "012" or 
		     _cod_subramo = "007" then

			if _tipo = "1" then
				
				let _prima = 3.46;

			elif _tipo = "2" then

				let _prima = 6.93;

			elif _tipo = "3" then

				let _prima = 9.71;

			end if

		elif _cod_subramo = "013" then

			if _tipo = "1" then
				
				let _prima = 2.78;

			elif _tipo = "2" then

				let _prima = 4.45;

			elif _tipo = "3" then

				let _prima = 6.95;

			end if

		elif _cod_subramo = "009" then

			if _tipo = "1" then
				
				let _prima = 9.47;

			elif _tipo = "2" then

				let _prima = 18.85;

			elif _tipo = "3" then

				let _prima = 26.40;

			end if

		end if

		if _prima is not null then

			insert into prdpriex
			values (_cod_producto, _tipo, _prima, "2003-05");

		end if

		return _cod_producto,
		       _nombre,
			   _tipo,
			   _cod_subramo
		       with resume;

	end if

end foreach

end procedure