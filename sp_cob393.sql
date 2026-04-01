-- Procedimiento carga ducruet_cob a deivid_cob   
-- Creado : 07/06/2017 - Autor: Henry Giron  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob393;
create procedure "informix".sp_cob393(a_numero 	char(10))
returning	integer,char(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_recibo_det		integer;
define _no_remesa			char(10);
define _cero                char(1);
define _monto_cobrado_det	dec(16,2);
define _monto_comis_det		dec(16,2);
define _monto_bruto_det		dec(16,2);
define _error_isam			integer;
define _secuencia           integer;
define _error				integer;
define _no_remesa_int       integer;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception

return 0,'Desactivado';

-- lectura de la tabla de pagos externos envio a duc_cuadre_cob
select no_remesa[2,5]	   
  into _no_remesa
  from cobpaex0
 where numero = a_numero;	   	
 
 let _error_desc	= "";
 let _cero   = _no_remesa[1,1]; 

 --if  _cero <> "0" then no funciono

foreach
	select no_documento,
		   monto_bruto,
		   monto_cobrado,
		   monto_comis,
		   no_recibo,
		   secuencia
	  into _no_documento,
		   _monto_bruto_det,
		   _monto_cobrado_det,
		   _monto_comis_det,
		   _no_recibo_det,
		   _secuencia		
	  from cobpaex1
	 where numero = a_numero      

	update deivid_cob:duc_cob
	   set no_remesa_agt = _no_remesa
	 where no_recibo_agt = _no_recibo_det
	   and poliza = _no_documento;

	insert into deivid_cob:duc_cuadre_cob(
			poliza,
			monto_cobrado,
			no_recibo_agt,
			monto_comis,
			no_remesa_agt,
			secuencia,
			monto_remesar,
			procesado)
	values(	_no_documento,
			_monto_cobrado_det,
			_no_recibo_det,
			_monto_comis_det,
			_no_remesa,
			_secuencia,
			_monto_bruto_det,
			0);  	
end foreach
--else
--	let _messg	= "formato de no_remesa_agt incorrecto.";	
--end if
return 0,_error_desc;
end
end procedure;
