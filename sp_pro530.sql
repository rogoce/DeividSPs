-- Creacion de las letras de pago de las polizas por nueva ley de seguros

-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro530;

create procedure sp_pro530(
a_no_poliza	char(10)
) returning	int, char(50);

define _letra			smallint;
define _fecha_pago		date;
define _periodo_gracia	date;
define _fecha_60_dias	date;
define _fecha_aviso		date;
define _monto_letra		dec(16,2);
define _no_recibo		char(10);
define _fecha_pagado	date;
define _letra_pagada	smallint;

define _mes_int			smallint;
define _mes_dec			dec(16,2);
define _mes_letra		smallint;
define _ano_letra		smallint;
define _mes_gracia		smallint;
define _ano_gracia		smallint;
define _mes_cancela		smallint;
define _ano_cancela		smallint;
define _dias_vigencia	smallint;
define _dias_letra		smallint;
define _dias_letra_dec	dec(16,2);

define _prima_bruta		dec(16,2);
define _fecha_1_pago	date;
define _no_pagos		smallint;
define _vigencia_final	date;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _vigencia_inic   date;
define _vigencia		date;
define _vigencia_f      date;

define _resto           dec(16,2);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_pro525.trc";
--trace on;

let _vigencia_inic = '01/01/1900';


delete from emiletra where no_poliza = a_no_poliza;

select prima_bruta,
       vigencia_inic,
	   no_pagos,
	   vigencia_final
  into _prima_bruta,
       _fecha_1_pago,
	   _no_pagos,
	   _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

let _monto_letra = _prima_bruta / _no_pagos;

let _dias_vigencia  = _vigencia_final - _fecha_1_pago;
let _dias_letra     = _dias_vigencia / _no_pagos;
let _dias_letra_dec = _dias_vigencia / _no_pagos;

if _dias_letra_dec > _dias_letra then
	let _dias_letra = _dias_letra + 1;
end if

let _mes_int = 12 / _no_pagos;
let _mes_dec = 12 / _no_pagos;

if _mes_dec > _mes_int then
	let _mes_int = _mes_int + 1;
end if

let _mes_letra = month(_fecha_1_pago);
let _ano_letra = year(_fecha_1_pago);

{
if _mes_letra = 12 then
	let _mes_letra = 1;
	let _ano_letra = _ano_letra + 1;
else
	let _mes_letra = _mes_letra + 1;
end if
}

let _resto = _prima_bruta;


for	_letra = 1 to _no_pagos

	-- Fecha del Pago de la Letra

	let _fecha_pago = _fecha_1_pago;
	
	-- Periodo de Gracia (30 dias)

	let _periodo_gracia	= _fecha_pago + 30;
	
	-- Cancelacion de la Poliza (60 dias despues del periodo de gracia)

	let _fecha_60_dias	= _periodo_gracia + 60;

	-- Envio Aviso Cancelacion (1 dias despues del periodo de gracia)

	let _fecha_aviso	= _periodo_gracia + 1;

	-- Nueva vigencia inicial
	
	if _vigencia_inic = '01/01/1900' then 
		let _vigencia_f  = _fecha_1_pago;
	end if
	
	let _vigencia   = _vigencia_f ;
	let _vigencia_f = _vigencia + _dias_letra;
	
	if _letra = _no_pagos then
		let _vigencia_f = _vigencia_final;
		let _dias_letra = _vigencia_f - _vigencia;
	end if
	

	insert into emiletra (
	   no_poliza,
	   no_letra,
	   fecha_vencimiento,
	   periodo_gracia,
	   fecha_aviso,
	   cancelar_poliza,
	   monto_letra,
	   dias_letra,
	   vigencia_inic,
	   vigencia_final)
	values (
	   a_no_poliza,
	   _letra,
	   _fecha_pago,
	   _periodo_gracia,
	   _fecha_aviso,
	   _fecha_60_dias,
	   _monto_letra,
	   _dias_letra,
	   _vigencia,
	   _vigencia_f);


	-- Calculo de la Nueva Letra

	let _fecha_1_pago = _fecha_1_pago + _dias_letra;

	let _resto = _resto - _monto_letra;
	
	-- Nueva vigencia inicial
	let _vigencia_inic = _fecha_1_pago;
end for

update emiletra	
   set monto_letra = monto_letra + _resto
 where no_poliza = a_no_poliza
   and no_letra  = _no_pagos;

end

return 0, "Actualizacion Exitosa";

end procedure
