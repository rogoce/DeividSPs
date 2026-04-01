-- Ajuste de las letras de pago de las polizas por nueva ley de seguros cuando la poliza recibe un endoso
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro541;

create procedure sp_pro541(a_no_poliza char(10), a_no_endoso char(5))
returning	int,
			char(50);

define _error_desc			char(50);
define _no_documento		char(20);
define _monto_pendiente		dec(16,2);
define _letra_residuo		dec(16,2);
define _monto_residuo		dec(16,2);
define _monto_pagado		dec(16,2);
define _monto_letra			dec(16,2);
define _prima_bruta			dec(16,2);
define _nuevo_monto			dec(16,2);
define _monto_pen			dec(16,2);
define _resto           	dec(16,2);
define _cnt_no_pagada		smallint;
define _ult_letra			smallint;
define _no_letra			smallint;
define _pagada				smallint;
define _activa				smallint;
define _dias_transcurridos	integer;
define _error_isam			integer;
define _error				integer;
define _fecha_hoy			date;
define _fecha_emision		date;
define _vigencia_inic		date;
define _fecha_calculo		date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(a_no_poliza) || ' no_endoso: ' || trim(a_no_endoso);
	return _error, _error_desc;
end exception

--set debug file to "sp_pro541.trc";
--trace on;

let _error = 0;
let _fecha_hoy = current;

select prima_bruta,
	   activa
  into _prima_bruta,
	   _activa
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _activa = 0 then
	return 0,'El Endoso no Aplica para Afectar Emiletra';
end if

select no_documento,
	   vigencia_inic,
	   fecha_suscripcion
  into _no_documento,
	   _vigencia_inic,
	   _fecha_emision
  from emipomae
 where no_poliza = a_no_poliza;

if _fecha_emision > _vigencia_inic then
	let _fecha_calculo = _fecha_emision;
else
	let _fecha_calculo = _vigencia_inic;
end if

let _dias_transcurridos = _fecha_hoy - _fecha_calculo;

if _dias_transcurridos > 30 and _prima_bruta <> 0.00 then
	--Proceso de Actualización de fecha de cobertura
	call sp_ley002(_no_documento,1) returning _error,_error_desc;

	if _error < 0 then
		let _error_desc = _error_desc || '. Proceso de Ley de Seguros.';
		return _error,_error_desc;
	end if
end if
   
select max(no_letra),
	   count(*)
  into _ult_letra,
	   _cnt_no_pagada
  from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0;

if _cnt_no_pagada is null then
	let _cnt_no_pagada = 0;
end if

if _cnt_no_pagada = 0 then
	select max(no_letra)
	  into _ult_letra
	  from emiletra
	 where no_poliza = a_no_poliza;
	
	update emiletra
	   set pagada = 0
	 where no_poliza = a_no_poliza
	   and no_letra = _ult_letra;

	let _cnt_no_pagada = 1;
end if

let _nuevo_monto = _prima_bruta / _cnt_no_pagada;
let _resto = _prima_bruta;

foreach
	select no_letra,
		   monto_pen,
		   monto_letra,
		   monto_pag
	  into _no_letra,
		   _monto_pendiente,
		   _monto_letra,
		   _monto_pagado
	  from emiletra
	 where no_poliza = a_no_poliza
	   and pagada = 0
	
	let _monto_letra = _monto_letra + _nuevo_monto;
	let _monto_residuo = _nuevo_monto + _monto_pendiente;
	let _monto_pen = _monto_pendiente;
	let _monto_pendiente = _monto_pendiente + _nuevo_monto;
	let _pagada = 0;
	let _letra_residuo = _nuevo_monto;
	
	if _monto_pendiente <= 0 and _no_letra <> _ult_letra then

		select count(*)
		  into _cnt_no_pagada
		  from emiletra
		 where no_poliza = a_no_poliza
		   and no_letra > _no_letra;
		
		if _cnt_no_pagada is null then
			let _cnt_no_pagada = 0;
		end if
		
		let _pagada = 1;
		let _monto_pendiente = 0;
		let _monto_letra = _monto_pagado;
		let _monto_residuo = _monto_residuo /_cnt_no_pagada;	
		let _nuevo_monto = _nuevo_monto + _monto_residuo;
		let _letra_residuo = _monto_pen * -1;
	elif _no_letra = _ult_letra then
		
	end if
	
	update emiletra
	   set pagada = _pagada,
		   monto_pen = _monto_pendiente,
		   monto_letra = _monto_letra
	 where no_poliza = a_no_poliza
	   and no_letra = _no_letra;
		
	{if _monto_residuo <= 0 then
		
		let _letra_residuo = _monto_pagado + _nuevo_monto;
		let _nuevo_monto = _nuevo_monto + (_letra_residuo/(_cnt_no_pagada - 1));
		
		update emiletra
		   set pagada = 1,
			   monto_letra = monto_pag,
			   monto_pen = 0			   
		 where no_poliza = a_no_poliza
		   and no_letra = _no_letra;
	else
		update emiletra
		   set monto_letra = monto_letra + _nuevo_monto,
			   monto_pen = monto_pen + _nuevo_monto
		 where no_poliza = a_no_poliza
		   and no_letra = _no_letra;
	end if}
	
	let _monto_residuo = 0.00;
	
	--let _resto = _resto - _nuevo_monto;
	let _resto = _resto - _letra_residuo;
end foreach

update emiletra	
   set monto_letra = monto_letra + _resto,
	   monto_pen = monto_pen + _resto
 where no_poliza = a_no_poliza
   and no_letra  = _ult_letra;

select monto_pen
  into _monto_pendiente
  from emiletra
 where no_poliza = a_no_poliza
   and no_letra  = _ult_letra;

if _monto_pendiente <= 0 then
	update emiletra
	   set pagada = 1
	 where no_poliza = a_no_poliza
	   and no_letra  = _ult_letra;
end if
end

return 0,'Actualización Exitosa';
end procedure;