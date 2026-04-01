-- Procedure que verifica que cuadre SAC Vs Deivid en Produccion

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac71;

create procedure sp_sac71()
returning integer,
          char(7),
		  char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_trx		integer;
define _monto1		dec(16,2);
define _monto2		dec(16,2);

define _mes			smallint;
define _ano			smallint;
define _periodo		char(7);
define _fecha		date;

define _notrx2		integer;
define _periodo2	char(7);
define _cuenta		char(25);
define _fechatrx	date;

set isolation to dirty read;

create temp table tmp_asientos(
no_trx		integer,
periodo		char(7),
cuenta		char(25),
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;


select par_mesfiscal,
       par_anofiscal
  into _mes,
       _ano
  from cglparam;

let _mes = 12;

if _mes < 10 then
	let _periodo = _ano || "-0" || _mes;
else
	let _periodo = _ano || "-" || _mes;
end if

let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);

let _notrx2 = 2900;

foreach
 select res_notrx,
		res_fechatrx,
		res_cuenta,
		sum(res_debito - res_credito)
   into _no_trx,
        _fechatrx,
		_cuenta,
		_monto1
   from cglresumen
  where res_fechatrx >= _fecha
	and res_cuenta   like ("411%")
  group by 1, 2, 3

	if _no_trx < _notrx2 then
--		let _no_trx = _notrx2;
	end if

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values (_no_trx, _periodo2, _cuenta, _monto1, 0.00);

end foreach

foreach
 select sac_notrx,
        periodo,
		cuenta,
        sum(debito + credito)
   into _no_trx,
        _periodo2,
		_cuenta,
        _monto2
   from endasien
  where periodo >= _periodo
	and cuenta  like ("411%")
  group by 1, 2, 3

	if _no_trx is null then
--		let _no_trx = 99999;
	end if

	if _no_trx < _notrx2 then
--		let _no_trx = _notrx2;
	end if

	insert into tmp_asientos
	values (_no_trx, _periodo2, _cuenta, 0.00, _monto2);

end foreach

foreach
 select no_trx,
		periodo,
		cuenta,
        sum(monto1),
        sum(monto2)
   into _no_trx,
        _periodo2,
		_cuenta,
        _monto1,
        _monto2
   from tmp_asientos
  group by 1, 2, 3
  order by 1, 2, 3
             
--	if _monto1 <> _monto2 then
	                           
		return _no_trx,
		       _periodo2,
			   _cuenta,
			   _monto1,
			   _monto2,
			   (_monto1 - _monto2)	
			   with resume;

--	end if

end foreach

drop table tmp_asientos;

return "0",
       "",
	   "",
	   0.00,
	   0.00,
	   0.00	
	   with resume;

end procedure