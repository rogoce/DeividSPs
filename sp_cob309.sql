-- Simulacion del Pago Adelantado de Comision (Polizas que Aplican)
 
-- Creado     : 08/10/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob309;

create procedure "informix".sp_cob309(a_no_poliza char(10), a_cod_agente char(5))
returning smallint

define _error_desc			char(100);													 
define _no_documento		char(20);													 
define _no_recibo			char(10);										 
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _tipo_agente			char(1);
define _status_lic			char(1);
define _comision_cancelada	dec(16,2);			
define _comision_adelanto	dec(16,2);			
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_neta_pro		dec(16,2);
define _prima_suscrita		dec(16,2);			
define _monto_recibo		dec(16,2);			
define _prima_neta			dec(16,2);			
define _porc_partic_agt		dec(5,2);			
define _porc_comis_agt		dec(5,2);			
define _poliza_cancelada	smallint;			
define _pago_comis_ade		smallint;			
define _adelanto_comis		smallint;			
define _status_poliza		smallint;
define _max_no_pagos		smallint;
define _cnt_cobredet		smallint;			
define _cnt_existe			smallint;
define _comis_desc			smallint;
define _meses_por			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _cnt_canc			smallint;			
define _aplica				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_proceso		date;

begin
on exception set _error
	return _error;
end exception

set isolation to dirty read;

let _no_documento		= '';
let	_no_recibo			= '';
let	_no_poliza			= '';
let _cod_agente			= '';
let _comision_cancelada	= 0.00;
let	_comision_adelanto	= 0.00;
let	_comision_ganada	= 0.00;
let _prima_neta_cob		= 0.00;
let _prima_neta_pro		= 0.00;	
let	_comision_saldo		= 0.00;
let	_prima_suscrita		= 0.00;
let	_monto_recibo		= 0.00;
let	_prima_neta			= 0.00;
let	_porc_partic_agt	= 0.00;	
let	_porc_comis_agt		= 0.00;
let _poliza_cancelada	= 0;
let _pago_comis_ade		= 0;
let	_adelanto_comis		= 0;
let	_status_poliza		= 0;
let	_cnt_existe			= 0;
let	_no_pagos			= 0;
let _cnt_canc			= 0;
let	_aplica				= 0;

--set debug file to "sp_cob309.trc";
--trace on;

select tipo_agente,
	   estatus_licencia,
	   max_no_pagos
  into _tipo_agente,
	   _status_lic,
	   _max_no_pagos
  from agtagent
 where cod_agente = a_cod_agente;	

if _max_no_pagos = 0 then
	let _max_no_pagos = 8;
end if
 
if _tipo_agente <> 'A' or _status_lic <> 'A' then	--Clausula 6
	return 0;
end if

-- Validaciones
select no_documento,
	   no_pagos,
	   estatus_poliza,
	   anticipo_comis,
       cod_formapag,
	   fronting,
	   cod_grupo,
	   cod_tipoprod,
	   cod_ramo
  into _no_documento,
  	   _no_pagos,
	   _status_poliza,
	   _pago_comis_ade,	
       _cod_formapag,
	   _fronting,
	   _cod_grupo,
	   _cod_tipoprod,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_canc
  from cobadecoh
 where no_documento = _no_documento
   and poliza_cancelada = 1;

if _cnt_canc is null then
	let _cnt_canc = 0;
end if

if _cnt_canc <> 0 then
	return 0;
end if

if _status_poliza <> 1 then
	return 0;
end if

if _pago_comis_ade is null then
	let _pago_comis_ade = 0;
end if

if _pago_comis_ade = 0 then 
	return 0;
end if

select count(*)
  into _cnt_existe
  from cobadeco						
 where no_documento = _no_documento;

if _cnt_existe is null then
	let _cnt_existe = 0;
end if

if _cnt_existe = 1 then
	return 0;
end if

-- Los Numeros de Pagos No Aplican para Salud y Vida Individual
if _cod_ramo not in ('018','019') then  
	-- Numero de Pagos
	if _no_pagos > _max_no_pagos then
		return 0;
	end if

	if _no_pagos = 1 then
		return 0;
	end if
end if

-- Solo Participan Pólizas de Forma de Pago TCR, ACH y COR
if _cod_formapag not in ("003", "005", "008") then
	return 0;
end if

-- Frontings
if _fronting = 1 then
	return 0;
end if

-- Polizas del Estado
if _cod_grupo in ("00000", "1000") then
	return 0;
end if

-- Coaseguro Minoritario
if _cod_tipoprod = "002" then
	return 0;
end if

-- Si Aplica para el Pago
return 1;

end
end procedure

