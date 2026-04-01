-- Reporte de polizas procesadas Excepciones de Ducruet 
-- Creado    : 05/07/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

Drop procedure sp_cob397;
create procedure 'informix'.sp_cob397(a_fecha date)
returning	char(20)		as no_documento,
			varchar(100)	as nom_cliente,
			dec(16,2)		as monto_cobrado,
			char(10)		as no_recibo,
			varchar(100)	as motivo_error,
			char(10)		as no_remesa_agt,
			integer			as secuencia,
			char(50)		as compania;

define _motivo_error	varchar(100);
define _nom_cliente		varchar(100);
define _error_desc		varchar(100);
define _cia				varchar(50);
define _no_documento	char(20);
define _no_remesa_agt	char(10);
define _no_recibo		char(10);
define _monto_cobrado	dec(16,2);
define _error_code		integer;
define _error_isam		integer;
define _secuencia		integer;


set isolation to dirty read;
--set debug file to 'sp_cob397.trc'; 
--trace on ;
		   
begin
on exception set _error_code, _error_isam, _error_desc 
 	return '',_error_desc,0,'','','',_error_code,'';
end exception

-- Nombre de la Compania
LET  _cia = sp_sis01('001'); 
let _nom_cliente = '';

foreach
	select distinct no_remesa_agt		   
	  into _no_remesa_agt		   
	  from deivid_cob:duc_cob
	 where date(fecha_procesado) = a_fecha
	   and procesado = 1 	 
	 
	foreach
		select poliza,
			   secuencia,
			   monto_cobrado,
			   motivo_error
		  into _no_documento,
			   _secuencia,
			   _monto_cobrado,
			   _motivo_error
		  from deivid_cob:duc_excep_cob
		 where no_remesa_agt = _no_remesa_agt		   
		   
		foreach
			select trim(cliente),
				   no_recibo_agt
			  into _nom_cliente,
				   _no_recibo		      
			  from deivid_cob:duc_cob
			 where no_remesa_agt = _no_remesa_agt
			   and trim(poliza) =  _no_documento
			exit foreach;
		end foreach

		return	_no_documento,
				_nom_cliente,
				_monto_cobrado,
				_no_recibo,		   
				_motivo_error,	   
				_no_remesa_agt,
				_secuencia,
				_cia
				with resume;				
		end foreach
end foreach
end
end procedure;