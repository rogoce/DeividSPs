-- Procedimiento que carga los pagos diarios de un corredor
-- Creado    : 06/05/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob331;

create procedure sp_cob331(a_cod_agente char(5), a_fecha date)
returning	varchar(8),		--_fecha_pago_char,
			varchar(100),	--_nom_cliente,
			varchar(50),	--_nom_ramo,
			varchar(21),	--_no_documento,
			varchar(8),		--_vigencia_inic_char,
			varchar(8),		--_vigencia_final_char,
			dec(16,2),		--_monto,
			dec(16,2),		--_saldo
			varchar(10),	--_no_remesa,
			varchar(10);

define _nom_cliente			varchar(100);
define _nom_ramo			varchar(50);
define _no_documento	   	varchar(20);
define _no_recibo			varchar(10);
define _no_remesa			varchar(10);
define _vigencia_inic_char 	varchar(8);
define _vigencia_final_char	varchar(8);
define _fecha_pago_char		varchar(8);
define _error_desc			char(100);
define _cod_cliente			char(10);
define _cod_ramo			char(3);
define _monto				dec(16,2);
define _saldo				dec(16,2);
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_cob331.trc";
--trace on;

begin

{on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception}

foreach
	select to_char(fecha_pago,"%Y%m%d"),
		   trim(no_remesa),
		   cod_cliente,
		   cod_ramo,
		   trim(no_documento),
		   to_char(vigencia_inic,"%Y%m%d"),
		   to_char(vigencia_final,"%Y%m%d"),
		   monto_pago,
		   saldo,
		   trim(no_recibo)
	  into _fecha_pago_char,
		   _no_remesa,
		   _cod_cliente,
		   _cod_ramo,
		   _no_documento,
		   _vigencia_inic_char,
		   _vigencia_final_char,
		   _monto,
		   _saldo,
		   _no_recibo
	  from cobpagt
	 where cod_agente = a_cod_agente
	   and fecha_pago = a_fecha
	
	if _cod_ramo = '020' then
		let _cod_ramo = '002';
	end if
	
	select trim(nombre)
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	select trim(nombre)
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	
	return	_fecha_pago_char,
			_nom_cliente,
			_nom_ramo,
			_no_documento,
			_vigencia_inic_char,
			_vigencia_final_char,
			_monto,
			_saldo,
			_no_remesa,
			_no_recibo
			with resume;
end foreach
end 
end procedure

