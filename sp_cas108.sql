-- Procedimiento para cargar Cascliente y Caspoliza luego de Activar la Campaña
-- Creado    : 12/10/2010 - Autor:Roman Gordon
-- DEIVID, S.A.

drop procedure sp_cas108;
create procedure sp_cas108(a_cod_campana char(10))
returning	smallint,
			char(100)	     

define _error_desc			char(250);
define _ultima_gestion 		char(100);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _cod_cobrador_ant	char(3);
define _cod_cobrador		char(3);
define _cod_gestion			char(3);
define _cod_pagos			char(3);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _a_pagar				dec(16,2);
define _cnt_caspoliza		smallint;
define _cnt_cas_prog		smallint;
define _dias_compara		smallint;
define _cnt_cobrador		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _dia_cobros3			smallint;
define _pendiente			smallint;
define _dias				smallint;
define _error_isam			integer;
define _error				integer;
define _cont				integer;
define _fecha_ult_pro		date;
define _fecha_hoy			date;
define _hora				datetime hour to minute;

on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error, _error_desc;--"Error al Ingresar los Registro en emipoliza";
end exception

--set debug file to "sp_cas108.trc";
--trace on;

set isolation to dirty read;

let _fecha_hoy = current;
let _dias_compara = 15;

foreach
	select no_documento,
		   exigible,
		   dia_cobros1,
		   dia_cobros2,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   saldo,
		   por_vencer,
		   cod_pagos
	  into _no_documento,
	  	   _exigible,
	  	   _dia_cobros1,
	  	   _dia_cobros2,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo,
		   _por_vencer,
		   _cod_pagos
	  from campoliza
	 where cod_campana = a_cod_campana

	let _no_documento = trim(_no_documento);
	let _no_poliza = sp_sis21(_no_documento);
	let _a_pagar = 0;
	let _fecha_ult_pro = current;

	select cod_pagador
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	let _a_pagar = _a_pagar + _exigible;

	select count(*)
	  into _cont
	  from cascliente
	 where cod_cliente = _cod_cliente
	   and cod_campana = a_cod_campana;

	if _cont = 0 then
		insert into cascliente(
				cod_cliente,
				dia_cobros1,
				dia_cobros2,
				procesado,
				fecha_ult_pro,
				cod_gestion,
				dia_cobros3,
				cod_cobrador_ant,
				ultima_gestion,
				cant_call,
				pago_fijo,
				mando_mail,
				cod_campana,
				corriente,
				exigible,
				monto_30,
				monto_60,
				monto_90,
				monto_120,
				monto_150,
				monto_180,
				saldo,
				por_vencer,
				cod_pagos,
				cod_cobrador,
				nuevo)
		values(	_cod_cliente,
				_dia_cobros1,
				_dia_cobros2,
				0,
				_fecha_ult_pro,
				null,
				0,
				null,
				'',
				0,
				0,
				0,
				a_cod_campana,
				_corriente,
				_exigible,
				_monto_30,
				_monto_60,
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo,
				_por_vencer,
				_cod_pagos,
				null,
				1);
	end if

	select count(*)
	  into _cnt_cas_prog
	  from cascliente_prog
	 where cod_cliente = _cod_cliente;

	if _cnt_cas_prog > 0 then
		select dia_cobros1, 				
			   dia_cobros2, 		
			   dia_cobros3, 		
			   cod_gestion, 		
			   cod_cobrador_ant,
			   ultima_gestion, 	
			   fecha_ult_pro,	
			   hora				
		  into _dia_cobros1, 	
			   _dia_cobros2, 	
			   _dia_cobros3, 	
			   _cod_gestion, 	
			   _cod_cobrador_ant,
			   _ultima_gestion, 	
			   _fecha_ult_pro,	
			   _hora
		  from cascliente_prog
		 where cod_cliente = _cod_cliente;

		let _dias = _fecha_hoy - _fecha_ult_pro;

		if _dias > _dias_compara then
			let _cod_gestion = null;
			let _cod_cobrador_ant = null;
			let _hora = null;
		end if

		update cascliente 
		   set dia_cobros1 		= _dia_cobros1,
			   dia_cobros2 		= _dia_cobros2, 
			   dia_cobros3 		= 0, 
			   --cod_gestion 		= _cod_gestion, 
			   cod_cobrador_ant	= _cod_cobrador_ant,
			   ultima_gestion 	= _ultima_gestion, 
			   fecha_ult_pro	= _fecha_ult_pro,
			   hora				= _hora
		 where cod_cliente 	= _cod_cliente;
	end if

	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = a_cod_campana
	   and cod_cliente = _cod_cliente
	   and no_documento = _no_documento;

	if _cnt_caspoliza = 0 then

		insert into caspoliza(
				no_documento,
				cod_cliente,
				dia_cobros1,
				dia_cobros2,
				a_pagar,
				cod_campana)
		values(	_no_documento,
				_cod_cliente,
				_dia_cobros1,
				_dia_cobros2,
				_a_pagar,
				a_cod_campana);
	end if
end foreach

foreach
	select cod_cobrador
	  into _cod_cobrador
	  from cobcobra
	 where cod_campana = a_cod_campana

	select count(*)
	  into _cnt_cobrador
	  from cobcadate
	 where cod_cobrador = _cod_cobrador
	   and fecha = _fecha_hoy;

	if _cnt_cobrador is null then
		let _cnt_cobrador = 0;
	end if

	if _cnt_cobrador > 0 then
		select count(*)
		  into _pendiente
		  from cascliente
		 where cod_campana = a_cod_campana
		   and cod_gestion is null;

		update cobcadate
		   set total = total + _pendiente,
			   pendientes = pendientes + _pendiente
		 where cod_cobrador = _cod_cobrador
		   and fecha = _fecha_hoy;
	end if
end foreach
		

--commit work;

return 0,"Actualizacion Exitosa";
end procedure;