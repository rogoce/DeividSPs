-- Conversion de la fecha de cumpleaños de la tabla de CAJS

drop procedure sp_par175;

create procedure "informix".sp_par175(a_cedula char(30))
returning char(30);

define _ced_prov		char(2);
define _ced_av			char(2);
define _ced_tomo		char(4);
define _ced_folio		char(5);

define _tomo_int		integer;
define _folio_int		integer;
define _prov_int		integer;

define _cedula_deivid	char(30);

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

	let _cedula_deivid = trim(_ced_av) || "-" || _tomo_int || "-" || _folio_int;

else

	let _cedula_deivid = _prov_int || "-" || _tomo_int || "-" || _folio_int;

end if

return _cedula_deivid;

end procedure
