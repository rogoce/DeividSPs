-- Procedimiento que actualiza las polizas que son pronto pago

-- Creado    : 27/01/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_cob29 - DEIVID, S.A.

drop procedure sp_cob192;

create procedure sp_cob192(
a_no_documento	char(20),
a_fecha_pago	date default today,
a_monto			dec(16,2)
)

define _no_poliza	char(10);
define _cod_ramo	char(3);
define _fecha_sus	date;
define _saldo		dec(16,2);
define _periodo     char(7);
define _factor		dec(16,5);
define _cod_cliente	char(10);
define _nombre_ase	char(50);

let _no_poliza = sp_sis21(a_no_documento);

select cod_ramo,
       fecha_suscripcion,
	   cod_contratante
  into _cod_ramo,
       _fecha_sus,
	   _cod_cliente
  from emipomae
 where no_poliza = _no_poliza;

-- Solo polizas de Automovil

if _cod_ramo not in ("002") then
	return;
end if

-- Que el pago sea dentro de los 30 dias despues de la emision

if (a_fecha_pago - _fecha_sus) > 30 then
	return;
end if
	
let _periodo = sp_sis39(a_fecha_pago);
let _saldo   = sp_cob175(a_no_documento, _periodo);
let a_monto  = abs(a_monto);

if _saldo = 0.00 then
	let _factor  = 100;
else
	let _factor  = a_monto / _saldo * 100;
end if

-- Que el Pago sea del 95% de la Deuda

if _factor < 95 then
	return;
end if

-- Si el saldo al final del calculo es cero no envie el mensaje

If (_saldo - a_monto) = 0.00 then
	return;
end if

select nombre
  into _nombre_ase
  from cliclien
 where cod_cliente = _cod_cliente;

insert into cobpropa(
no_documento,
monto,
saldo,
fecha,
asegurado,
email_send
)
values(
a_no_documento,
a_monto,
_saldo,
a_fecha_pago,
_nombre_ase,
0
);


end procedure
