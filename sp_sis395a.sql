--  Procedimiento para determinar si una poliza electronico aplica o no para el descuento de 5% 
-- Creado: 14/12/2011 - Autor: Armando Moreno M.

drop procedure sp_sis395a;
create procedure sp_sis395a(a_no_poliza char(10))
returning smallint,char(50),decimal(16,2);


define _nombre_asegurado	varchar(100);
define _nombre_producto		varchar(50);
define _nombre_agente		varchar(50);
define _no_documento		char(20);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _monto_descuento		dec(16,2);
define _porc_descuento		dec(16,2);
define _prima_bruta			dec(16,2);
define _monto_visa			dec(16,2);
define _no_pagos			smallint;
define _cnt_emifafac		smallint;
define v_existe_end			smallint;
define _existe_rev			smallint;
define _fecha_suscripcion	date;

set isolation to dirty read;

let _monto_descuento = 0.00;
let _monto_visa = 0.00;
let _porc_descuento = 5;
let _cnt_emifafac = 0;
let _prima_bruta = 0;

--set debug file to "sp_sis395.trc";
--trace on;

--let _ult_pago = 0;
--return 1,'SE DESACTIVA',_ult_pago;  lo quite el 16/07/2015 9:57 am

select fecha_suscripcion,
       cod_ramo,
	   cod_formapag,
	   no_pagos,
	   cod_subramo,
	   prima_bruta
  into _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _no_pagos,
	   _cod_subramo,
	   _prima_bruta
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo in ('001','004','008','016','019','018','020') then  --Inc. no aplica, Ramos Personales y SODA no aplican.
	return 1,'RAMO NO APLICA',0;
end if

select count(*)
  into _cnt_emifafac
  from emifafac
 where no_poliza = a_no_poliza;

if _cnt_emifafac > 0 then	--No aplica facultativos
	return 1,'FACULTATIVOS NO APLICAN',0;
end if

if _cod_formapag not in ('003','005') then	--Solo aplica tarjeta de credito y ach
	return 1,'SOLO APLICA TARJETA DE CREDITO Y ACH',0;
end if

select count(*)
  into v_existe_end
  from endedmae
 where no_poliza   = a_no_poliza
   and cod_endomov = "024";	     --Endoso de Descuento de Pronto Pago

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza   = a_no_poliza
   and cod_endomov = '025'		 --Endoso de Reversion de Descuento de Pronto Pago
   and actualizado = 1;

if (v_existe_end - _existe_rev) > 0 then
	return 1,'ENDOSO YA EXISTIA',0;
end if

if _cod_ramo = '003' and _cod_subramo = '005' then
	return 1,'NO APLICA ZONA LIBRE',0;
end if

let _monto_descuento = _prima_bruta * (_porc_descuento/100);
let _monto_visa = (_prima_bruta - _monto_descuento) / _no_pagos;

return 0,'SI APLICA',_monto_visa;
end procedure;