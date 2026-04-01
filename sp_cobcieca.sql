-- Creacion de las formas de pago de la Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cobcieca;

create procedure sp_cobcieca(
a_no_caja	char(10),
a_user_caja	char(8)	default null
) returning integer,
            char(100);

define _cod_chequera 	char(3); 
define _fecha 			date; 
define _no_remesa		char(10);

define _monto_chequeo	dec(16,2);
define _total_caja		dec(16,2);
define _total_pagos		dec(16,2);
define _importe			dec(16,2);
define _en_balance		smallint;

define _tipo_pago		smallint;
define _tipo_tarjeta	smallint;
define _renglon			smallint;

define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_banco		char(3);

define _cod_banco_visa	char(3);
define _cuenta_visa		char(25);
define _cta_nombre		char(50);

define _cantidad		integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_pagos;
	return _error, _error_desc;
end exception

select count(*)
  into _cantidad
  from cobcieca2
 where no_caja = a_no_caja;

if _cantidad <> 0 then
	return 0, "Actualizacion Exitosa";
end if	

create temp table tmp_pagos(
tipo_pago		smallint,
tipo_tarjeta	smallint,
importe			dec(16,2)
) with no log;

let _cod_banco = "146";

select fecha,
       cod_chequera
  into _fecha,
       _cod_chequera
  from cobcieca
 where no_caja = a_no_caja;

select cod_compania,
       cod_sucursal
  into _cod_compania,
       _cod_sucursal
  from chqchequ
 where cod_banco    = _cod_banco
   and cod_chequera = _cod_chequera;

delete from cobcieca2 where no_caja = a_no_caja;

let _total_caja  = 0.00;
let _total_pagos = 0.00;

foreach
 select no_remesa,
        monto_chequeo
   into _no_remesa,
        _monto_chequeo
   from cobremae
  where cod_chequera = _cod_chequera
    and fecha        = _fecha
	and actualizado  = 1

	let _total_caja = _total_caja + _monto_chequeo;

	foreach
	 select tipo_pago,
	        tipo_tarjeta,
			importe
	   into _tipo_pago,
	        _tipo_tarjeta,
			_importe
	   from cobrepag
	  where no_remesa = _no_remesa

		let _total_pagos = _total_pagos + _importe;

		insert into tmp_pagos
		values (_tipo_pago, _tipo_tarjeta, _importe);

	end foreach

end foreach

-- Creacion de los Pagos por Cada Caja

let _renglon = 0;

foreach
 select tipo_pago,
	    tipo_tarjeta,
		sum(importe)
   into _tipo_pago,
	    _tipo_tarjeta,
		_importe
   from tmp_pagos
  group by 1, 2
  order by 1, 2

	let _renglon = _renglon + 1;

	insert into cobcieca2 (no_caja, renglon, tipo_pago, tipo_tarjeta, cuenta, monto, original)
	values (a_no_caja, _renglon, _tipo_pago, _tipo_tarjeta, null, _importe, 1);

end foreach

-- Banco para las American Express

select banco_tarjeta
  into _cod_banco_visa
  from insagen
 where codigo_compania = _cod_compania
   and codigo_agencia  = _cod_sucursal;

let _cuenta_visa = sp_sis15('BACHEBL', '02', _cod_banco_visa); 

update cobcieca2
   set cuenta       = _cuenta_visa
 where no_caja      = a_no_caja
   and tipo_pago    = 4
   and tipo_tarjeta = 4;

-- Tarjetas Clave

update cobcieca2
   set cuenta       = _cuenta_visa
 where no_caja      = a_no_caja
   and tipo_pago    = 3;

-- Banco para las Visas, Dinners y Master Card

select banco_tarjeta2
  into _cod_banco_visa
  from insagen
 where codigo_compania = _cod_compania
   and codigo_agencia  = _cod_sucursal;

let _cuenta_visa = sp_sis15('BACHEBL', '02', _cod_banco_visa);

update cobcieca2
   set cuenta       = _cuenta_visa
 where no_caja      = a_no_caja
   and tipo_pago    = 4
   and tipo_tarjeta in (1, 2, 3);

-- Banco para Efectivo y Cheques

select banco_caja
  into _cod_banco_visa
  from insagen
 where codigo_compania = _cod_compania
   and codigo_agencia  = _cod_sucursal;

let _cuenta_visa = sp_sis15('BACHEBL', '02', _cod_banco_visa);

update cobcieca2
   set cuenta       = _cuenta_visa
 where no_caja      = a_no_caja
   and tipo_pago    in (1, 2);

-- Nombres de Cuenta

foreach
 select renglon,
        cuenta
   into _renglon,
        _cuenta_visa
   from cobcieca2
  where no_caja = a_no_caja
	   
	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = _cuenta_visa;

	update cobcieca2
	   set nombre  = _cta_nombre
	 where no_caja = a_no_caja
	   and renglon = _renglon;

end foreach           

-- Total de la Caja

if _total_caja = _total_pagos then
	let _en_balance = 1;
else
	let _en_balance = 0;
end if

update cobcieca
   set total_caja  = _total_caja,
       en_balance  = _en_balance,
	   user_caja   = a_user_caja,
	   total_pagos = _total_pagos
 where no_caja     = a_no_caja;

end 

drop table tmp_pagos;

return 0, "Actualizacion Exitosa";

end procedure