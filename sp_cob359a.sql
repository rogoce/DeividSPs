-- Procedimiento para la Anulación de Pólizas que cumplan 45 días sin Pagos en su primera letra
-- Creado    : 15/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob359;
create procedure sp_cob359()
returning	char(20)		as Poliza,
			date			as Fecha_Aviso,
			varchar(100)	as Contratante,
			varchar(50)		as Correo,
			dec(16,2)		as Por_Vencer,
			dec(16,2)		as Exigible,
			dec(16,2)		as Corriente,
			dec(16,2)		as Monto_30,
			dec(16,2)		as Monto_60,
			dec(16,2)		as Monto_90,
			dec(16,2)		as Saldo;

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _email				varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _periodo				char(8);
define _por_vencer_n		dec(16,2);
define _corriente_n			dec(16,2);
define _por_vencer			dec(16,2);
define _exigible_n			dec(16,2);
define _monto_90_n			dec(16,2);
define _monto_60_n			dec(16,2);
define _monto_30_n			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _saldo_n				dec(16,2);
define _saldo				dec(16,2);
define _error_isam			integer;
define _error				integer;
define _fecha_aviso_canc	date;
define _fecha_actual		date;

--set debug file to "sp_cob359.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return '','01/01/1900',_error_desc,'',_error,0.00,0.00,0.00,0.00,0.00,0.00;
end exception 

let _fecha_actual = current;
let _periodo = sp_sis39(_fecha_actual);

foreach
	select distinct no_documento,
		   fecha_aviso_canc
	  into _no_documento,
		   _fecha_aviso_canc
	  from emipomae
	 where carta_aviso_canc = 1
	   and estatus_poliza = 1

	call sp_cob245a("001","001",_no_documento,_periodo,_fecha_actual)	 
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;

	let _monto_90 = _monto_90 + _monto_120 + _monto_150 + _monto_180;

	call sp_cob33('001','001',_no_documento,_periodo,_fecha_actual)
	returning	_por_vencer_n, 
				_exigible_n,      
				_corriente_n,    
				_monto_30_n,      
				_monto_60_n,      
				_monto_90_n,
				_saldo_n;

	if (_por_vencer + _exigible + _corriente + _monto_30 + _monto_60 + _monto_90 + _saldo) <> (_por_vencer_n + _exigible_n + _corriente_n + _monto_30_n + _monto_60_n + _monto_90_n + _saldo_n) and (_monto_60_n + _monto_90_n <= 5 )then

		call sp_sis21(_no_documento) returning _no_poliza;
		
		select cod_contratante
		  into _cod_contratante
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre,
			   e_mail
		  into _nom_cliente,
			   _email
		  from cliclien
		 where cod_cliente = _cod_contratante;
			   
		return _no_documento,
			   _fecha_aviso_canc,
			   _nom_cliente,
			   _email,
			   _por_vencer_n,
			   _exigible_n,
			   _corriente_n,
			   _monto_30_n,
			   _monto_60_n,
			   _monto_90_n,
			   _saldo_n
			   with resume;
	end if
end foreach
end
end procedure;