-- Proceso que verifica y realiza el descuento de pronto pago cuando la póliza es cambiada a forma de pago electrónica.
-- Creado    : 08/04/2015 - Autor: Román Gordón
--execute procedure sp_cob373('','MARILUZ')

drop procedure sp_cob373;
create procedure sp_cob373(a_no_poliza char(10),a_user char(8))
returning	integer,
			varchar(100),
			dec(16,2);

define _error_desc			varchar(100);
define _no_documento		char(19);
define _nueva_renov			char(1);
define _cod_subramo			char(3);
define _cod_tipoprod		char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _cod_grupo			char(5);
define _monto_cobrado		dec(16,2);
define _prima_bruta			dec(16,2);
define _monto_desc			dec(16,2);
define _monto_visa			dec(16,2);
define _monto_pen			dec(16,2);
define _porc_desc			dec(16,2);
define _tipo_produccion		smallint;
define _cnt_no_pagada		smallint;
define _facultativo			smallint;
define _declarativa			smallint;
define _existe_end			smallint;
define _existe_rev			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _manzana,_tiene_prod smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _estatus_poliza      smallint;
define _prima_anual		    dec(16,2);
--set debug file to "sp_cob373.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc,0.00;
end exception

let _porc_desc = 5;
let _prima_anual = 0;

--Verifica si ya se le aplico descuento de pronto pago
select count(*)
  into _existe_end
  from endedmae
 where no_poliza	= a_no_poliza
   and cod_endomov	= '024'
   and actualizado  = 1;

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza	= a_no_poliza
   and cod_endomov	= '025'
   and actualizado  = 1;

if (_existe_end - _existe_rev) > 0 then
	let _error_desc = 'Esta póliza ya tiene el endoso de descuento aplicado, Por Favor Verifique...';
	return 1,_error_desc,0.00;
end if

select nueva_renov,
	   no_documento,
	   prima_bruta,
	   fecha_suscripcion,
	   cod_ramo,
	   cod_subramo,
	   fronting,
	   no_pagos,
	   declarativa,
	   cod_perpago,
	   cod_tipoprod,
	   cod_grupo,
	   estatus_poliza
  into _nueva_renov,
	   _no_documento,
	   _prima_bruta,
	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_subramo,
	   _fronting,
	   _no_pagos,
	   _declarativa,
	   _cod_perpago,
	   _cod_tipoprod,
	   _cod_grupo,
	   _estatus_poliza
  from emipomae
 where no_poliza = a_no_poliza;
 
 let _tiene_prod = sp_emi04(a_no_poliza,'10602');	--Caso 11713, AMM 7/10/2024
if _tiene_prod = 1 then	--Tiene el producto en la unidad.
	return 1,'Producto 10602, Ctes. sin siniestros, no aplica descuento.',0.00;
end if
 
 if _fecha_suscripcion < '13/07/2015' then
	let _error_desc = 'No Aplica. La póliza fue emitida luego de la fecha estipulada...';
	return 1,_error_desc,0.00;
end if
 
 if _estatus_poliza = 2 then  -- CASO: 36042 USER: JAQUELIN -- 07/12/2020
	let _error_desc = 'No Aplica. La póliza está cancelada...';
	return 1,_error_desc,0.00;
end if
--Pólizas con Pago Inmediato
if _cod_perpago = '006' and _no_pagos = 1 then --pago inmediato no aplica pronto pago
	let _error_desc = "Póliza con pago INMEDIATO, NO APLICA.";
	return 1,_error_desc,0.00;
end if
 
if _cod_grupo in ('124','78020') then --Banisi - Lizzy Bernal
	return 1,'El Grupo de la Póliza no Aplica para el descuento.',0.00;
end if   
if _cod_grupo = '125' or _cod_grupo = '148' or _cod_grupo = '1122' or _cod_grupo = '77960'  then --Banisi - Bac, Abadia, Ducruet 15/01/2019 CASO: 30140, 30295 USER: ASTANZIO     -- SD#3010 07/04/2022 4:00pm   
	return 1,'El Grupo de la Póliza no Aplica para el descuento.',0.00;
end if   

if _cod_grupo <> '1117' then
	--Pólizas con primas menores de bl. 300 no aplican
	if _prima_bruta <= 300 then
		let _error_desc = 'Esta póliza no aplica para este descuento. La prima es menor de b/.300.00.';
		return 1,_error_desc,0.00;
	end if
end if

if _cod_ramo in ('004','008','016','019','018','023') then	--si es forma de pago ach/tcr, hacer endoso de pronto pago SD#10812 JEPEREZ 270624 HG agrega 001 -- Ahora si se le descuenta a incendio SD#13432 Amado 24-04-2025-- '
	let _error_desc = 'No Aplica. El ramo de la póliza no participa del descuento...';
	return 1,_error_desc,0.00;
end if
if _cod_ramo in ('004') and _cod_subramo in ('008') then	--si es forma de pago ach/tcr, hacer endoso de pronto pago SD#10812 JEPEREZ 270624 HG agrega 001
	let _error_desc = 'No Aplica. El ramo de la póliza no participa del descuento...';
	return 1,_error_desc,0.00;
end if
--Pólizas declarativas de transporte
if _cod_ramo = '009' and _declarativa = 1 then
	let _error_desc = 'No Aplica. La Póliza es Declarativa de Transporte.';
	return 1,_error_desc,0.00;
end if

--if (_cod_ramo = '003' and _cod_subramo = '005') or  (_cod_ramo in ('001') and _cod_subramo = '006') then
if _cod_ramo = '003' and _cod_subramo = '005' then -- Ahora si se le descuenta a incendio SD#13432 Amado 24-04-2025--
	let _error_desc = 'No Aplica. La Pólizas de Zona Libre/France Field no participan del descuento...';
	return 1,_error_desc,0.00;
end if

--Excepcion de Coaseguros
select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion in (3) then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Coaseguro.";
	return 1,_error_desc,0.00;
end if

--Excepcion Facultativos
let _facultativo = 0;
let _facultativo = sp_sis439(a_no_poliza);

if _facultativo = 1 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Facultativa.";
	return 1,_error_desc,0.00;
end if

--Verifica si la manzana es Zona Libre
call sp_pro857(a_no_poliza) returning _manzana;
if _manzana = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Unidad(es) con ubicación en Zona Libre.';
	return 1,_error_desc,0.00;
end if

if _fronting = 1 then
	let _error_desc = 'No Aplica. Las Pólizas Fronting no participan del descuento...';
	return 1,_error_desc,0.00;
end if

let _monto_desc = _prima_bruta * (_porc_desc/100);
call sp_pro862b(a_no_poliza, a_user, _monto_desc) returning _error, _error_desc; -- creacion del endoso de pronto pago

if _error <> 0 then
	return _error,_error_desc,0.00;
end if

select count(*),
	   sum(monto_pen)
  into _cnt_no_pagada,
	   _monto_pen
  from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0;

if _monto_pen is null then
	let _monto_pen  = 0;
	let _monto_visa = 0;
else
	let _monto_visa = _monto_pen / _cnt_no_pagada;	
end if

return 0,'Endoso Aplicado con Exito',_monto_visa;

end 
end procedure;