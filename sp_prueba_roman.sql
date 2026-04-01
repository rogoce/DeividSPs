-- procedimiento para realizar la facturacion automatica de polizas que tenian morosidad de 61 dias o mas (SALUD)

-- creado    : 15/11/2010 - autor: roman gordon

drop procedure sp_prueba_roman;

create procedure "informix".sp_prueba_roman()
returning	smallint,char(100);

define _fecha1			date;
define _error			integer;
define _error_isam		integer;
define _cont			smallint;
define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _usuario			char(8);
define _periodo			char(7);
define _cod_no_renov	char(3);
define _saldo			dec(16,2);
define _monto			dec(16,2);
define _por_vencer		dec(16,2);
define _exigible  		dec(16,2);
define _corriente 		dec(16,2);
define _monto_30  		dec(16,2);
define _monto_60  		dec(16,2);
define _monto_90  		dec(16,2);
									 

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception


set isolation to dirty read;
begin

--SET DEBUG FILE TO "sp_pro350.trc"; 
--TRACE ON;


foreach
	select no_remesa,
		   user_posteo
	  into _no_remesa,
	  	   _usuario
	  from cobremae
	 where date_posteo between date('01/02/2012') and date('24/04/2012')

	call sp_pro350(_no_remesa,_usuario) returning _error,_error_desc;
			
end foreach

return 0,"Actualizacion exitosa";	
end
end procedure