-- Procedimiento para la Anulación de Pólizas que tengan una gestión de anulación en la estructura de campañas de call center
-- Creado    : 15/04/2015 - Autor: Román Gordón
-- Modificadi: 29/01/2016 - Autor: Román Gordón --Hacer que el proceso de anulación de pólizas renovadas tome en cuenta todos los endososos de la vigencia a anular. 
-- Modificadi: 07/03/2016 - Autor: Román Gordón --Se agregó el proceso de eliminar el endoso realizado en caso de error y permitir que continue con la siguiente póliza a anular.
-- SIS v.2.0 - d_cobr_sp_cob358_dw1 --llamado desde sis103 (Proceso Diario de Cobros) - DEIVID, S.A.

drop procedure sp_cob358a;
create procedure sp_cob358a()
returning	integer			as Codigo_Error,
			varchar(100)	as Poliza,
			char(5)			as No_Endoso;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _cod_campana			char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _usuario_firma		char(8);
define _usuario				char(8);
define _periodo				char(7);
define _no_endoso			char(5);
define _cod_cobrador		char(3);
define _cod_sucursal		char(3);
define _cod_gestion			char(3);
define _anula				char(3);
define _nueva_renov			char(1);
define _prima_bruta_end		dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _saldo				dec(16,2);
define _error_isam			integer;
define _error				integer;
define _estatus_poliza		smallint;
define _cnt_anula			smallint;
define _fecha_anula			date;
define _fecha_hoy			date;

--set debug file to "sp_cob358.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc,'00000';
end exception 

select firma_end_canc
  into _usuario_firma
  from parparam;

let _fecha_hoy = current;
let _periodo = sp_sis39(_fecha_hoy);

foreach
	select cod_campana,
		   cod_cliente,
		   cod_gestion,
		   no_documento,
		   date(date_added)
	  into _cod_campana,
		   _cod_cliente,
		   _cod_gestion,
		   _no_documento,
		   _fecha_anula
	  from cobanula
	 where date(date_added) = today
	   and cod_gestion = '045'

	let _anula = null;
	
	select cod_cobrador
	  into _cod_cobrador
	  from cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	select anula
	  into _anula
	  from cobcages
	 where cod_gestion = _cod_gestion;

	if _anula is null or _anula = '' then
		continue foreach;
	end if

	if _cod_cobrador is null then
		let _cod_cobrador = '';
	end if
	
	if _cod_cobrador = '' then
		let _usuario = _usuario_firma;
	else
		select usuario
		  into _usuario
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;
	end if

	select count(*)
	  into _cnt_anula
	  from cobgesti
	 where cod_pagador = _cod_cliente
	   and no_documento = _no_documento
	   and cod_gestion = _cod_gestion;

	if _cnt_anula is null then
		let _cnt_anula = 0.00;
	end if
	
	if _cnt_anula = 0 then
		continue foreach;
	end if
	
	call sp_sis21(_no_documento) returning _no_poliza;

	select cod_sucursal,
		   estatus_poliza,
		   nueva_renov
	  into _cod_sucursal,
		   _estatus_poliza,
		   _nueva_renov
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza not in (1,3) then
		continue foreach;
	end if

	if _nueva_renov = 'N' then

		call sp_cob33('001','001', _no_documento, _periodo, _fecha_hoy)
		returning   _por_vencer,
					_exigible,
					_corriente,
					_monto_30,
					_monto_60,
					_monto_90,
					_saldo;

		call sp_pro518(_no_poliza,_usuario,_saldo,_cod_sucursal,_anula) returning _error,_error_desc,_no_endoso;
	elif _nueva_renov = 'R' then
		select sum(prima_bruta)
		  into _prima_bruta_end
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1;

		--Endoso de Cancelación por Anulación de Póliza)
		call sp_par342(_no_poliza,_usuario,_prima_bruta_end,_cod_sucursal,_anula,_fecha_anula) returning _error, _error_desc,_no_endoso;
	end if

	if _error <> 0 then
		call sp_par27(_no_poliza,_no_endoso);
		return _error, trim(_no_documento) || trim(_error_desc),_no_endoso with resume;
		continue foreach;			
	end if
	
	delete from cobanula
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente
	   and no_documento = _no_documento;

	return 0,_no_documento,_no_endoso with resume;
end foreach
end
end procedure;