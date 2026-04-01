-- Generacion de la información de la remesa actualizada de General Representative para generar el archivo de Excel que se les envía
-- creado por :    Roman Gordon	10/04/2013
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob326;

create procedure "informix".sp_cob326(a_no_remesa char(10))
returning	integer,
            char(50);				

define _cliente				char(100);
define _error_desc			char(50);
define _no_documento		char(21);
define _no_recibo_agt		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _numero				char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _ano_char			char(4);
define _mes_char			char(2);
define _monto_cobrado		dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _cnt_cobpaex			smallint;
define _weekday				smallint;
define _error_isam			integer;
define _secuencia			integer;
define _error				integer;
define _fecha_apertura		date;
define _fecha_corte			date;
define _fecha_pago			date;
define _fecha				date;
define _fec_apertura		date;

set isolation to dirty read;
--set debug file to "sp_cob326.trc";
--trace on;

--return 0,'';

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cod_agente	= '00161';
let _secuencia	= 0;
let _cnt_cobpaex = 0;

let _fecha = current;
let _weekday = weekday(_fecha);

if month(_fecha) < 10 then
	let _mes_char = '0'|| month(_fecha);
else
	let _mes_char = month(_fecha);
end if

let _ano_char = year(_fecha);
let _periodo  = _ano_char || "-" || _mes_char;

select count(*)
  into _cnt_cobpaex
  from cobpaex0
 where cod_agente = _cod_agente
   and no_remesa_ancon = a_no_remesa;
   
if _cnt_cobpaex = 0 then
	
	select max(secuencia)
	  into _secuencia
	  from cobpagr
	 where fecha_cierre is null;

	if _secuencia is null then
		let _secuencia = 0;
	end if
	
	foreach
		select no_poliza,
			   fecha,
			   monto
		  into _no_poliza,
			   _fecha_pago,
			   _monto_cobrado
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov in ('P','N','X')
		   and actualizado = 1
		
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			
			if  _cod_agente	= '00161' then
				exit foreach;
			end if
		end foreach
		
		if  _cod_agente	<> '00161' then
			continue foreach;
		end if
		
		let _secuencia = _secuencia + 1;
		
		select no_documento,
			   cod_pagador
		  into _no_documento,
			   _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		select nombre
		  into _cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;
		
		select max(fecha_cierre)
		  into _fecha_apertura
		  from cobpagr
		 where enviado = 1
			or fecha_cierre is null;
		
		if _fecha_apertura is null then
			select max(fecha_apertura)
			  into _fecha_apertura
			  from cobpagr
			 where fecha_cierre is null;
			
			if _fecha_apertura is null then			
				let _fecha_apertura = _fecha_pago;
			end if
		end if
		
		select max(fecha_cierre)
		  into _fecha_corte
		  from cobpagr
		 where enviado = 0;
		
		call sp_cob245(
			 "001",
			 "001",	
			 _no_documento,
			 _periodo,
			 _fecha
			 ) returning _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _monto_120,
						 _monto_150,
						 _monto_180,
						 _saldo;
		
		insert into cobpagr(
				cod_agente,
				secuencia,
				fecha_apertura,
				fecha_cierre,
				fecha_transaccion,
				no_remesa_ancon,
				no_recibo_agt,
				cliente,
				monto,
				saldo,
				no_documento)
		values	(_cod_agente,
				_secuencia,
				_fecha_apertura,
				null,
				_fecha_pago,
				a_no_remesa,
				null,
				_cliente,
				_monto_cobrado,
				_saldo,
				_no_documento);		
	end foreach
		
	--return 0,'La Remesa no es de Pago Externo';
elif _cnt_cobpaex > 0 then

	select periodo_desde,
		   periodo_hasta,
		   cod_agente,
		   numero
	  into _fecha_apertura,
		   _fecha_corte,
		   _cod_agente,
		   _numero
	  from cobpaex0
	 where no_remesa_ancon = a_no_remesa;

	if _cod_agente <> '00161' then
		return 0,'La Remesa no es de General Representatives';
	end if
	
	select max(fecha_apertura),
		   max(secuencia)
	  into _fec_apertura,
		   _secuencia
	  from cobpagr
	 where enviado = 0;
	 
	if _fec_apertura is not null and _fecha_apertura > _fec_apertura then
		let _fecha_apertura = _fec_apertura;
	end if
	
	if _secuencia is null then
		let _secuencia = 0;
	end if
	
	foreach
		select no_documento,
			   cliente,
			   fecha_pago,
			   no_recibo,
			   monto_cobrado
			   --renglon
		  into _no_documento,
			   _cliente,
			   _fecha_pago,
			   _no_recibo_agt,
			   _monto_cobrado
			   --_secuencia
		  from cobpaex1
		 where numero = _numero

		let _secuencia = _secuencia + 1;
		
		call sp_cob245(
			 "001",
			 "001",	
			 _no_documento,
			 _periodo,
			 _fecha
			 ) returning _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _monto_120,
						 _monto_150,
						 _monto_180,
						 _saldo;
		
		insert into cobpagr(
				cod_agente,
				secuencia,
				fecha_apertura,
				fecha_cierre,
				fecha_transaccion,
				no_remesa_ancon,
				no_recibo_agt,
				cliente,
				monto,
				saldo,
				no_documento)
		values	(_cod_agente,
				_secuencia,
				_fecha_apertura,
				_fecha_corte,
				_fecha_pago,
				a_no_remesa,
				_no_recibo_agt,
				_cliente,
				_monto_cobrado,
				_saldo,
				_no_documento);
	end foreach
	
	update cobpagr
	   set fecha_cierre = _fecha_corte
	 where enviado = 0
	   and fecha_cierre is null;
end if

return 0,'';
end
end procedure