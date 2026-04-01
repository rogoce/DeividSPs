-- proceso que realiza la modificacion de unidad en negativo tecnica de seguros

-- Creado: 11/08/2017 - Autor: Federico Coronado

drop procedure sp_end15b;

create procedure "informix".sp_end15b()
returning varchar(45),
          decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2);



define _prima					decimal(16,2);
define _por_vencer				decimal(16,2);
define _exigible				decimal(16,2);
define _corriente 				decimal(16,2);
define _monto_30 				decimal(16,2);
define _monto_60    			decimal(16,2);
define _monto_90				decimal(16,2); 
define _saldo					decimal(16,2);
define _no_factura_deivid       varchar(45);


set isolation to dirty read;
--SET DEBUG FILE TO "sp_end15.trc"; 
--TRACE ON;


	foreach
		select no_factura
		  into _no_factura_deivid
		  from facturas_duplicada
		  order by 1 desc
		 -- where no_factura in ('09-167066','09-167067')
		 -- where no_factura in ('09-159305','09-159306')
		 
		call sp_cob33('001','001',_no_factura_deivid,'2017-09','25/09/2017') returning _por_vencer, _exigible, _corriente, _monto_30, _monto_60, _monto_90, _saldo;
		return  _no_factura_deivid,
				_por_vencer, 
				_exigible, 
				_corriente, 
				_monto_30, 
				_monto_60, 
				_monto_90, 
				_saldo
	    with resume;
	end foreach
end procedure