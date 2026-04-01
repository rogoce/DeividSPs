-- Reporte de polizas procesadas de Ducruet 
-- Creado    : 05/07/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

 Drop procedure sp_cob396;
create procedure 'informix'.sp_cob396(a_fecha date)
returning	char(20)		as no_documento,
            varchar(100)	as nom_cliente,
			dec(16,2)		as monto_recibo,
			char(10)		as no_recibo,
			dec(16,2)		as monto_descontado,
			dec(16,2)		as comis_desc,
			dec(16,2)		as comis_cobro,
			dec(16,2)		as comis_visa,
			dec(16,2)		as comis_clave,
			dec(16,2)		as monto_remesar,
			char(10)		as no_remesa_agt,
			integer			as secuencia,
			char(50)		as compania,
			varchar(3)		as pago_a,
			date			as fecha_pago;

--smallint,char(100); 

define _error_desc			varchar(100);
define _error_code			integer;
define _error_isam			integer;

define _nom_cliente			varchar(100);
define _cia					varchar(50);
define _no_documento		char(20);
define _no_remesa_agt		char(10);
define _no_recibo			char(10);
define _pago_a				char(3);
define _monto_descontado	dec(16,2);
define _monto_remesar		dec(16,2);
define _monto_recibo		dec(16,2);
define _comis_cobro			dec(16,2);
define _comis_clave			dec(16,2);
define _comis_desc			dec(16,2);
define _comis_visa			dec(16,2);
define _secuencia			integer;
define _fecha_pago			date;

set isolation to dirty read;
--set debug file to 'sp_cob396.trc';
--trace on ;
begin

on exception set _error_code, _error_isam, _error_desc 
 	return '',_error_desc,0,'',0,0,0,0,0,0,'',_error_code,'','',null;
end exception

-- Nombre de la Compania
LET  _cia = sp_sis01('001'); 
let _pago_a = null;

foreach
	select poliza,
	       cliente,
		   monto_cobrado,
		   no_recibo_agt,
		   monto_comis,
		   comis_desc,
		   comis_cobro,
		   comis_visa,
		   comis_clave,
		   monto_remesar,
		   no_remesa_agt,
		   secuencia,
		   pago_a,
		   fecha_pago
	  into _no_documento,
	       _nom_cliente,
		   _monto_recibo,
		   _no_recibo,
		   _monto_descontado,
		   _comis_desc,
		   _comis_cobro,
		   _comis_visa,
		   _comis_clave,
		   _monto_remesar,		   
		   _no_remesa_agt,
		   _secuencia,
		   _pago_a,
		   _fecha_pago
	  from deivid_cob:duc_cob
	 where procesado = 1
	   and date(fecha_procesado) = a_fecha
	 order by secuencia
	 
	return	_no_documento,
			_nom_cliente,
			_monto_recibo,
			_no_recibo,
			_monto_descontado,
			_comis_desc,
			_comis_cobro,
			_comis_visa,
			_comis_clave,
			_monto_remesar,		   
			_no_remesa_agt,
			_secuencia,
			_cia,
			_pago_a,
			_fecha_pago
			with resume;			 
	 
end foreach	 
	
end
end procedure;