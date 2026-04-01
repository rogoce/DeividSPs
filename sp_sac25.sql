-- Procedimiento que genera el detalle de las cuentas afectadas en SAC
-- 
-- Creado     : 24/12/2004 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac25;		

CREATE PROCEDURE "informix".sp_sac25(a_periodo1 char(7), a_periodo2 char(7), a_cuenta char(25))
returning integer,
	   	  char(15),
	      date,
	      char(50),
	      char(25),
	      dec(16,2),
	      dec(16,2),
	      char(100),
	      dec(16,2),
		  char(1);	

define _fecha1			date;
define _fecha2			date;

define _res_notrx		integer;
define _res_comprobante	char(15);
define _res_fechatrx	date;
define _res_descripcion	char(50);
define _res_cuenta		char(25);
define _res_debito		dec(16,2);
define _res_credito		dec(16,2);
define _res_neto		dec(16,2);
define _cta_auxiliar	char(1);

define _nombre_cuenta	char(100);

set isolation to dirty read;

let a_cuenta = trim(a_cuenta) || "%";
let _fecha1  = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]);
let _fecha2  = sp_sis36(a_periodo2);

foreach
 select res_notrx,
		res_comprobante,
		res_fechatrx,
		res_descripcion,
		res_cuenta,
		res_debito,
		res_credito
   into	_res_notrx,
		_res_comprobante,
		_res_fechatrx,
		_res_descripcion,
		_res_cuenta,
		_res_debito,
		_res_credito
   from cglresumen
  where res_fechatrx >= _fecha1
    and res_fechatrx <= _fecha2
	and res_cuenta   like a_cuenta
  order by res_cuenta, res_fechatrx, res_notrx --res_comprobante,

	select cta_nomexten,
	       cta_auxiliar
	  into _nombre_cuenta,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _res_cuenta;

--	if _cta_auxiliar = "N" then
--		continue foreach;
--	end if

	let _res_neto = _res_debito - _res_credito;

	return _res_notrx,
		   _res_comprobante,
		   _res_fechatrx,
		   _res_descripcion,
		   _res_cuenta,
		   _res_debito,
		   _res_credito,
		   _nombre_cuenta,
		   _res_neto,
		   _cta_auxiliar
		   with resume;

end foreach

end procedure