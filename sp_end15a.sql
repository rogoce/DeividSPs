-- proceso que realiza la modificacion de unidad en negativo tecnica de seguros

-- Creado: 11/08/2017 - Autor: Federico Coronado

drop procedure sp_end15a;

create procedure "informix".sp_end15a()
returning varchar(15),
		  integer,
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2);


define _no_unidad_deivid		varchar(5);
define _no_factura_json			varchar(15);
define _prima					decimal(16,2);
define _prima_neta				decimal(16,2);
define _prima_bruta				decimal(16,2);
define _impuesto				decimal(16,2);
define _no_poliza_deivid        varchar(10);
define _no_factura_deivid	    varchar(15);
define _no_endoso_deivid        varchar(5);	
define _cnt_r                   integer;
define _no_existe                 integer;
define _num_carga               varchar(6);

set isolation to dirty read;
--SET DEBUG FILE TO "sp_end15.trc"; 
--TRACE ON;

let _prima_neta 	= 0;
let _impuesto   	= 0; 
let _prima_bruta	= 0;

	foreach
		select no_factura
		  into _no_factura_deivid
		  from facturas_duplicada
		 where trim(no_factura) in('09-65066')
		  order by 1 desc
		 -- where no_factura in ('09-167066','09-167067')
		 -- where no_factura in ('09-159305','09-159306')
		 
		select count(*)
		  into _cnt_r
		  from endedmae
		 where no_factura = _no_factura_deivid; 
		 
			if _cnt_r > 0 then
				select no_documento, 
					   prima_neta,
					   impuesto,
					   prima_bruta
				  into _no_poliza_deivid,
					   _prima_neta,
					   _impuesto,
					   _prima_bruta
				  from endedmae 
				 where no_factura = _no_factura_deivid;
				 
				let _no_existe = 1;
			else
				let _no_existe = 0;
			end if
		return  _no_factura_deivid,
				_no_existe,
				_prima_neta,
				_impuesto,
				_prima_bruta
	    with resume;
	end foreach
end procedure