-- procedimiento para realizar la facturacion automatica de polizas que tenian morosidad de 61 dias o mas (SALUD)

-- creado    : 15/11/2010 - autor: roman gordon

drop procedure sp_pro350;

create procedure "informix".sp_pro350(a_no_remesa char(10),a_usuario char(8))
returning	smallint,char(100);

define _fecha1			date;
define _error			integer;
define _error_isam		integer;
define _cont			smallint;
define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
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

let _fecha1 = today;
call sp_sis39(_fecha1) returning _periodo; 

foreach
	select d.doc_remesa,
		   d.monto
	  into _no_documento,
		   _monto
	  from cobredet d, emipomae e
	 where d.no_poliza = e.no_poliza
	   and d.no_remesa = a_no_remesa
	   and d.tipo_mov = 'P'
	   and e.cod_no_renov = '027'
	
		--call sp_cob115b('001','001',_no_documento,a_no_remesa) returning _saldo;		

		call sp_cob33d('001', '001', _no_documento, _periodo, _fecha1)
		returning _por_vencer,
		 		  _exigible,
				  _corriente,
				  _monto_30,
				  _monto_60,
				  _monto_90,
				  _saldo;
		
		let _monto_60 = _monto_60 + _monto_90;
		--let _saldo = _monto_60 - _monto;
		{let _no_poliza = sp_sis21(_no_documento);
		
		Select cod_no_renov
	   	  into _cod_no_renov
	   	  from emipomae
	   	 where no_poliza = _no_poliza;}

		--if _cod_no_renov = '027' then  --saldo pend. y fact. atrasada
			if _monto_60 < 5.00 then
				select count(*)
				  into _cont
				  from emifacsa
				 where no_documento = _no_documento;

				if _cont = 0 then
					insert into emifacsa(no_documento,user_added)
					values (_no_documento,a_usuario);
				end if
			end if
		--end if
end foreach

return 0,"Actualizacion exitosa";	
end
end procedure 
