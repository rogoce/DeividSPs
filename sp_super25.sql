drop procedure sp_super25;

create procedure sp_super25()
returning varchar(100) as proveedor, 		   
 		  date as fecha_vinculacion,
          dec(16,2) as pagado,
		   varchar(50) as servicio;

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

	drop table tmp_26612;

			return _error,
					0.00,
					null, 
					null with resume;

end exception
 
create temp table tmp_26612(
numrecla			char(20),
transaccion		    char(10),
cod_cliente         char(10),
cod_concepto        char(3),
pagado				dec(16,2) default 0
) with no log;

set isolation to dirty read;

--trace off;
-- Cheques Pagados

foreach
	select r.numrecla,
	       r.transaccion,
	       r.monto
	  into _numrecla,
	       _transaccion,
	       _pagado
	  from chqchmae m, chqchrec r
	 where m.no_requis = r.no_requis 
	   and m.periodo   >= '2018-05'
	   and m.periodo   <= '2019-05'
	   and m.pagado	   = 1
	   and m.anulado   = 0
	   and r.monto	   <> 0
	   
	select no_tranrec,
	       cod_cliente,
		   cod_tipopago
	  into _no_tranrec,
	       _cod_cliente,
		   _cod_tipopago
	  from rectrmae
	 where transaccion = _transaccion;
	
    foreach	
		select cod_concepto
		  into _cod_concepto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		exit foreach;
	end foreach
	
	let _cantidad = 0;
	
{	select count(*)
	  into _cantidad
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta      = "26612";
	   
	if _cantidad is null then
		let _cantidad = 0;
	end if
}	   
    if _cod_tipopago = "001" then
		insert into tmp_26612 (numrecla, transaccion, cod_cliente, cod_concepto, pagado)
		values (_numrecla, _transaccion, _cod_cliente, _cod_concepto, _pagado);
	end if
end foreach

{foreach
	select transaccion,
	       cod_cliente,
	       cod_concepto,
		   pagado
	  into _transaccion,
	       _cod_cliente,
	       _cod_concepto,
		   _pagado
	  from tmp_26612
	-- group by 1,2
	-- order by 1,2
    
	 select nombre,
	        date_added
	   into _nombre_clien,
	        _date_added
	   from cliclien
	  where cod_cliente = _cod_cliente;
	  
	  select nombre
	    into _concepto
		from recconce
	   where cod_concepto = _cod_concepto;
		
	 return _transaccion,
	        _nombre_clien,
			_date_added,
			_pagado,
			_concepto
			with resume;

				
end foreach}

select * from tmp_26612
into temp prueba;

foreach
	select cod_cliente,
		   sum(pagado)
	  into _cod_cliente,
		   _pagado
	  from tmp_26612
	 group by 1
	 order by 1
    
	 foreach
		select a.cod_concepto
		  into _cod_concepto
		  from prueba a, recconce b
		 where a.cod_concepto = b.cod_concepto
		   and a.cod_cliente = _cod_cliente
		   and b.tipo_concepto = 1
		 
		exit foreach;
	 end foreach
	
	 select nombre,
	        date_added
	   into _nombre_clien,
	        _date_added
	   from cliclien
	  where cod_cliente = _cod_cliente;	  
	  
	  select nombre
	    into _concepto
		from recconce
	   where cod_concepto = _cod_concepto;
		
	 return _nombre_clien,
			_date_added,
			_pagado,
			_concepto
			with resume;
				
end foreach

drop table tmp_26612;
drop table prueba;
end 

 
end procedure
                                                                                                          
