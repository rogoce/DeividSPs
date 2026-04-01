-- Proveedores administrativos

drop procedure sp_super26;

create procedure sp_super26()
returning char(10) as cod_cliente,
          varchar(100) as proveedor, 		   
 		  date as fecha_vinculacion,
          dec(16,2) as pagado;

define _numrecla        char(20);		   
define _transaccion		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
define _fecha_tran		date;
define _fecha_anul		date;
define _no_requis		char(10);
define _cheque_pagado	smallint;
define _cheque_anulado	smallint;
define _cheque_periodo	char(7);
define _monto_tran		dec(16,2);
define _fecha_anulado	date;
define _periodo_anulado	char(7);
define _tran_pagada		smallint;
define _generar_cheque		smallint;

define _pagado			dec(16,2);

define _cantidad		smallint;
define _cod_cliente     char(10);
define _nombre_clien    char(100);
define _cod_concepto    char(3);
define _concepto        varchar(50);
define _date_added      date;
define _cod_tipopago    char(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);


let _transaccion = "";



--set debug file to "sp_rec252.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc

--	drop table tmp_26612;

			return _error,
			        null,
					0.00,
					null with resume;

end exception
 

set isolation to dirty read;

--trace off;
-- Cheques Pagados

foreach
	select m.cod_cliente,
	       sum(m.monto)
	  into _cod_cliente,
	       _pagado
	  from chqchmae m, tmp_proveedores r
	 where m.cod_cliente = r.cod_cliente 
	   and m.periodo   >= '2018-05'
	   and m.periodo   <= '2019-05'
	   and m.pagado	   = 1
	   and m.anulado   = 0
	   and m.monto	   <> 0
	  group by cod_cliente
	  
	 select nombre,
	        date_added
	   into _nombre_clien,
	        _date_added
	   from cliclien
	  where cod_cliente = _cod_cliente;	  
	  
	 return _cod_cliente,
	        _nombre_clien,
			_date_added,
			_pagado
			with resume;
	   
end foreach


end 

 
end procedure
                                                                                                          
