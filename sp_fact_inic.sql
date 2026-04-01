-- procedimiento para realizar la facturacion automatica de polizas que tenian morosidad de 61 dias o mas (SALUD)  
-- creado    : 15/11/2010 - autor: roman gordon

drop procedure sp_fac_inic;

create procedure "informix".sp_fac_inic()
returning	char(20),dec(16,2),char(10),date;


define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _user			char(8);
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
define _vigencia_final	date;
define _fecha1			date;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return '',0.00,_error_desc,'01/01/1900';
end exception


set isolation to dirty read;
begin

--SET DEBUG FILE TO "sp_pro350.trc"; 
--TRACE ON;

let _fecha1 = today;
call sp_sis39(_fecha1) returning _periodo; 

foreach
	select no_documento,
		   vigencia_final
	  into _no_documento,
		   _vigencia_final
	  from emipomae
	 where cod_no_renov = '027'

		foreach
			select no_remesa,
				   monto
			  into _no_remesa,
				   _monto
			  from cobredet
			 where doc_remesa = _no_documento 
			   and tipo_mov = 'P'
			 order by fecha desc
			exit foreach;
		end foreach 

		--call sp_cob115b('001','001',_no_documento,_no_remesa) returning _saldo;
		--let _saldo = _saldo - _monto;
		call sp_cob33('001', '001', _no_documento, _periodo, _fecha1)
		returning _por_vencer,
		 		  _exigible,
				  _corriente,
				  _monto_30,
				  _monto_60,
				  _monto_90,
				  _saldo;

		let _monto_60 = _monto_60 + _monto_90;
		let _saldo = _monto_60 - _monto;
				
		let _no_poliza = sp_sis21(_no_documento);

		Select cod_no_renov
		  into _cod_no_renov
		  from emipomae
		 where no_poliza = _no_poliza;

		if _saldo <= 0 then
			select user_posteo
			  into _user
			  from cobremae
			 where no_remesa = _no_remesa;

			{insert into emifacsa(user_added,no_documento)
			values (_user,_no_documento);}
			return _no_documento,_saldo,_no_remesa,_vigencia_final with resume;
   		end if
end foreach
end
end procedure