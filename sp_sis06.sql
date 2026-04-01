-- Validar el monto de cobremae vs la sumatoria del monto en cobredet sea igual
--Valida tambien si hay que bloquear algun recibo.

-- Armando Moreno 26/01/2012


drop procedure sp_sis06;

create procedure sp_sis06(a_no_remesa char(10))
RETURNING smallint;

Define _monto_chequeo   decimal(16,2);
define _monto           decimal(16,2);
define _monto_descontado decimal(16,2);
define _monto_afec      decimal(16,2); 
define _tipo_remesa     char(1);
define _cnt             smallint;

set isolation to dirty read;

BEGIN

let _monto_chequeo = 0;
let _monto         = 0;
let _monto_descontado = 0;
let _monto_afec       = 0;


--****Bloquear Recibos****
--se bloquea esta secuencia segun correo de Nimia del 05/08/2024, AMM.
select count(*)
  into _cnt
  from cobredet
 where no_remesa = a_no_remesa
   and no_recibo >= '1948879'
   and no_recibo <= '1948900';
   
 if _cnt is null then
	let _cnt = 0;
 end if
 if _cnt > 0 then
	return 2;
 end if
  
select monto_chequeo,
       tipo_remesa
  into _monto_chequeo,
       _tipo_remesa
  from cobremae
 where no_remesa = a_no_remesa;

if _tipo_remesa = "B" or _tipo_remesa = "C" then
	return 0;
end if

select sum(monto - monto_descontado)
  into _monto
  from cobredet
 where no_remesa = a_no_remesa;

select sum(monto)
  into _monto_afec
  from cobredet
 where no_remesa = a_no_remesa
   and tipo_mov  = 'M';

--let _monto = _monto - _monto_afec;

if _monto_chequeo <> _monto then
	return 1;
end if

return 0;

END
end procedure