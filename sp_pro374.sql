-- Proceso que genera la información del Archivo de Pólizas Nuevas y Renovaciones de Ducruet (Excepto Auto, Soda y Fianzas)
-- Creado    : 15/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro374;

create procedure "informix".sp_pro374(a_no_poliza char(10))
returning integer,
		  smallint,
		  char(30),
          char(120);

define _desc_error			char(100);
define _no_motor			char(30);
define _campo				char(30);
define _no_documento_dup	char(21);
define _no_documento		char(21);
define _cod_manzana			char(15);
define _cod_acreedor		char(10);
define _cod_producto		char(10);
define _cod_perpago			char(10);
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _cod_color			char(10);
define _user_added			char(8);
define _emi_periodo			char(7);
define _periodo				char(7);
define _tipo				char(6);
define _no_unidad_dup		char(5);
define _cod_grupo			char(5);
define _unidad				char(5);
define _cod_compania_user	char(3);
define _sucursal_origen		char(3);   
define _cod_compania		char(3);
define _cod_subramo			char(3);
define _cod_agente			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _modo				char(1);
define _porc_partic_agt		dec(5,2);
define _prima_suscrita		dec(16,2);
define _prima_retenida		dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta	   		dec(16,2);
define _impuesto			dec(16,2);
define _recargo				dec(16,2);
define _error_conoce_clte1	smallint;
define _error_conoce_clte2	smallint;
define _saldo_por_unidad	smallint;
define _estatus_poliza		smallint;
define _tiene_impuesto		smallint;
define _anos_pagador		smallint;
define _cnt_emiauto			smallint;
define _actualizado			smallint;
define _cnt_existe			smallint;
define _tipo_cober			smallint;
define _no_pagos			smallint;
define _ramo_sis			smallint;
define _cnt_agt				smallint;
define _cnt_uni				smallint;
define _cnt_cob				smallint;
define _cnt_rea				smallint;
define _return				smallint;
define _dias				smallint;
define _mes					smallint;
define _dia					smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _fecha_impresion		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_proceso		date;
define _vig_final_dup		date;

if a_no_poliza = '1774426' then

set debug file to "sp_pro374.trc";
trace on;
end if

set isolation to dirty read;

begin
on exception set _error,_error_isam,_desc_error
	return _error,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _desc_error;
end exception

let _dia = 0;
let _dias = 0;

select cod_compania,   
       sucursal_origen,
       cod_perpago,  
       cod_ramo,  
       no_documento,  
       prima_neta,   
       prima_suscrita,   
       prima_retenida,
       vigencia_inic,   
       vigencia_final,   
       no_pagos,   
       actualizado,      
       periodo, 
       saldo_por_unidad,
	   user_added,
	   tiene_impuesto
  into _cod_compania,   
       _sucursal_origen,
       _cod_perpago,  
       _cod_ramo,
       _no_documento, 
       _prima_neta,    
       _prima_suscrita,   
       _prima_retenida,  
       _vigencia_inic,   
       _vigencia_final,
       _no_pagos,    
       _actualizado,      
       _periodo,  
       _saldo_por_unidad,
	   _user_added,
	   _tiene_impuesto
  from emipomae  
 where no_poliza = a_no_poliza;

select codigo_compania
  into _cod_compania_user
  from insuser
 where usuario = _user_added;

call sp_pro336a(a_no_poliza) returning _return, _desc_error;

if _return <> 0 then
	return 1,1,'Información',_desc_error;
end if
 
if _actualizado = 1 then
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 276;
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if

if _cod_compania_user <> _sucursal_origen then
	
	select modo
	  into _modo
	  from insagen
	 where codigo_compania	= _cod_compania_user
	   and codigo_agencia	= _sucursal_origen;
	
	if _modo = '2' then
		if _no_documento is null then
			return 1,1,'Advertencia ','Debe digitar el número de póliza, o verifique la sucursal origen...';
		end if
	end if
end if

if _saldo_por_unidad = 0 then

	let _dias	= abs(_vigencia_inic - _vigencia_final);
	let _mes	= month(_vigencia_inic);
	
	if _cod_perpago = '001' then
		let _dia = _no_pagos * 15;
	elif _cod_perpago = '002' then
		let _dia = _no_pagos * 30;
	elif _cod_perpago = '003' then
		let _dia = _no_pagos * 60;
	elif _cod_perpago = '004' then
		let _dia = _no_pagos * 90;
	elif _cod_perpago in ('005','009') then
		let _dia = _no_pagos * 120;
	elif _cod_perpago = '007' then
		let _dia = _no_pagos * 180;
	elif _cod_perpago = '008' then
		let _dia = _no_pagos * 365;
	end if
	
	if (_dias = 28 or _dias = 29) and _mes = 2 Then --Febrero
		let _dias = 30;
	elif (_dias = 58 or _dias = 59) and _mes = 2 Then
		let _dias = 60;
	elif (_dias = 88 or _dias = 89) and _mes = 2 Then
		let _dias = 90;
	elif (_dias = 118 or _dias = 119) and _mes = 2 Then
		let _dias = 120;
	elif (_dias = 178 or _dias = 179) and _mes = 2 Then
		let _dias = 180;
	elif (_dias = 363 or _dias = 364) and _mes = 2 Then
		let _dias = 365;
	end if
	if _dia > _dias Then
		return 1,1,'Periodo de Pago ','El No. de Pagos excede a la vigencia de la poliza, verifique...';
	end if	
end if

--Verificacion de Prima Retenida Vs Prima Suscrita
let _prima_suscrita = abs(_prima_suscrita);
let _prima_retenida = abs(_prima_retenida);
if _prima_retenida > _prima_suscrita then
	return 1,1,'Emision de Polizas','Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
end if
-- Verificacion de Prima Neta Vs Prima Suscrita
let _prima_retenida = abs(_prima_neta);
if _prima_suscrita > _prima_retenida and (abs(_prima_suscrita - _prima_retenida) > 0.50)then
	return 1,1,'Emision de Polizas','Prima Suscrita No Puede Ser Mayor que Prima Neta, Por Favor Verifique ...';
end if

call sp_sis25(a_no_poliza) returning _return,_unidad;
if _return <> 0 then
	return 1,1,'Verificacion de Primas',_unidad;
end if

-- Verificaciones de Tablas
-- Agentes

select count(*)
  into _cnt_agt
  from emipoagt
 where no_poliza = a_no_poliza;
 
if _cnt_agt < 1  then
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 254;	   
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if

select sum(porc_partic_agt)
  into _porc_partic_agt
  from emipoagt
 where no_poliza = a_no_poliza;
 
if _porc_partic_agt <> 100.00 then 
	return 1,1,'Advertencia ','La suma de la participacion de los agentes debe ser de 100 %';
end if

-- Unidades por Poliza

select count(*)
  into _cnt_uni
  from emipouni
 where no_poliza = a_no_poliza;
 
if _cnt_uni < 1 then 
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 257;
	   
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if
-- Coberturas por Unidad

select count(*)
  into _cnt_cob
  from emipouni u ,emipocob c
 where u.no_poliza = a_no_poliza
   and u.no_poliza = c.no_poliza;
 
if _cnt_cob < 1 then
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 255;
	   
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if

call sp_proe20(a_no_poliza, null) returning _return, _unidad;
if _return = 1 then
	return 1,1,' ', "La Unidad No. " || Trim(_unidad) || "Tiene los valores de Orden en Cero(0).";
end if

-- Reaseguros por Unidad

select count(*)
  into _cnt_rea
  from emipouni u ,emifacon f
 where u.no_poliza = a_no_poliza
   and u.no_poliza = f.no_poliza;
   
if _cnt_rea < 1 then 
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 256;
	   
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if

call sp_sis109(a_no_poliza) returning _return,_unidad;

if _return = 1 Then
	return 1,1,' ',_unidad;
end if

--Verificar Auto

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis = 1 then -- auto
	select count(*)
	  into _cnt_emiauto
	  from emiauto
	 where no_poliza = a_no_poliza;
	 
	if _cnt_emiauto < 1 then 
		select descripcion
		  into _desc_error
		  from inserror
		 where tipo_error = 2
		   and code_error = 267;
	   
		return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
	end if
	
	foreach
		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = a_no_poliza
		
		call sp_proe23(a_no_poliza,_no_motor,_vigencia_inic) returning _return,_no_documento_dup,_vig_final_dup,_no_unidad_dup;
		if _return = 1 then
			return 1,1,'Advertencia','El No Motor ' || trim(_no_motor) || ' esta Asegurado en la Póliza ' || trim(_no_documento_dup) || ' y con la Vigencia Final del ' || trim(cast(_vig_final_dup as char(10))) || '.';
		end if
	end foreach	
end if
	
-- Verifica si el el asegurado en las unidades tenga cedula y telefono de casa Amado 24/11/2006
-- excepto las polizas de colectivo de vida que son renovaciones segun Memorando	006-2007
call sp_proe40(a_no_poliza) returning _return, _unidad, _desc_error;
if _return = 1 then
	return 1,1,' ', "El asegurado de la Unidad No. " || Trim(_unidad) ||" No tiene los valores de " || _desc_error || "Que son obligatorios";
end if

-- Verificar Periodo

select emi_periodo
  into _emi_periodo
  from parparam
 where cod_compania = _cod_compania;
 
if  _periodo < _emi_periodo Then
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
	   and code_error = 279;
   
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if


if _cod_ramo = '020' Then	
	call sp_imp12(a_no_poliza) returning _return, _desc_error;
	if _return = 1 Then
		return 1,1,'Advertencia ', _desc_error;
	end if
end if	
/*
select cod_agente
  into _cod_agente
  from emipoagt
 where no_poliza = a_no_poliza;  */

call sp_sis17(a_no_poliza) returning _return;

if _return <> 0 Then
	if _return = 2 then
	   return 1,1,'Información', 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
	elif _return = 3 then
		if _tiene_impuesto = 1 then
			let _desc_error = 'Esta Póliza NO debe llevar Impuesto, Por Favor Verifique ...';
		else
			let _desc_error = 'Esta Póliza DEBE llevar Impuesto, Por Favor Verifique ...';
		end if
		return 1,1,'Información', _desc_error;
	elif _return = 4 then
		let _desc_error = 'La Sumatoria de porcentajes de Prima/Suma diferente de 100%, por favor verifique ...';
	elif _return = 5 then
		let _desc_error = 'El Numero de Recibo de Pago es Obligatorio, por favor verifique ...';
	elif _return = 7 then
		let _desc_error = 'El porcentaje de participacion de los agentes debe sumar 100.00';
	elif _return = 9 then
		let _desc_error = 'La Póliza no se puede emitir porque el Vehículo esta Bloqueado';
	elif _return = 10 then
		let _desc_error = 'El sistema ha detectado una restricción con este cliente. Por favor verique...';
	else		
		select descripcion
		  into _desc_error
		  from inserror
		 where tipo_error = 2
		   and code_error = _return;	   
	end if
	
	return 1,1,'Error Al Actualizar Póliza' || _no_documento || '.',_desc_error;
end if
end 
end procedure