-- Conversion de la fecha de cumpleaños de la tabla de CAJS

drop procedure sp_par177;

create procedure "informix".sp_par177()

define _numero			integer;
define a_cedula 		char(30);
define _ced_prov		char(2);
define _ced_av			char(2);
define _ced_tomo		char(4);
define _ced_folio		char(5);

define _tomo_int		integer;
define _folio_int		integer;
define _prov_int		integer;

foreach
 select numero,
       	cedula
   into _numero,
        a_cedula
   from cajs
--  where numero = 1

	let _ced_prov = a_cedula[1,2];
	let _ced_av   = a_cedula[4,5];

	if _ced_av in ("E", "N") then

		let _ced_tomo  = a_cedula[6,9];
		let _ced_folio = a_cedula[11,15];

	else

		let _ced_tomo  = a_cedula[7,10];
		let _ced_folio = a_cedula[12,16];

	end if

	let _prov_int  = _ced_prov;
	let _tomo_int  = _ced_tomo;
	let _folio_int = _ced_folio;

	if _ced_av in ("E", "N", "PE") then

		update cajs
		   set ced_prov    = "",
		       ced_av      = _ced_av,
			   ced_tomo    = _tomo_int,
			   ced_asiento = _folio_int
		 where numero      = _numero;

	else

		update cajs
		   set ced_prov    = _prov_int,
		       ced_av      = "",
			   ced_tomo    = _tomo_int,
			   ced_asiento = _folio_int
		 where numero      = _numero;


	end if

end foreach

end procedure
