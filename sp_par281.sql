-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por el Sr. Chamorro
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par281;

create procedure "informix".sp_par281()
returning integer,
          char(100);


define _limite		dec(16,2);
define _poliza		char(20);
define _saldo		dec(16,2);
define _saldo_acum 	dec(16,2);

define _mes			smallint;
define _ano			smallint;
define _periodo		char(7);

-- Seteos Iniciales

let _limite = 182000;

update deivid_tmp:cobinc2009
   set saldo_acum = 0.00,
       saldo      = 0.00;

let _saldo_acum = 0.00;

let _mes = 11;
let _ano = 2009;

if _mes < 10 then
	let _periodo = _ano || "-0" || _mes;
else
	let _periodo = _ano || "-" || _mes;
end if

foreach
 select poliza
   into _poliza
   from deivid_tmp:cobinc2009

	let _saldo = sp_cob174(_poliza);

	if _saldo <= 0 then
		let _saldo = 0.00;
	end if

	let _saldo_acum = _saldo_acum + _saldo;

	update deivid_tmp:cobinc2009
	   set saldo_acum = _saldo_acum,
	       saldo      = _saldo,
		   periodo    = _periodo,
		   cancelada  = 0
	 where poliza     = _poliza;

	if _saldo_acum >= _limite then

		if _mes = 12 then

			let _limite = 368000;

		else

			let _saldo_acum = 0.00;
			let _mes = _mes + 1;

			if _mes < 10 then
				let _periodo = _ano || "-0" || _mes;
			else
				let _periodo = _ano || "-" || _mes;
			end if

		end if

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure
