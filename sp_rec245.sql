-- Procedure que Anula las transacciones con mas de 90 dias
-- Inctrucciones Leyri Moreno, Correo del 11/06/2015

drop procedure sp_rec245;
create procedure sp_rec245()
returning char(10),
          dec(16,2),
          char(10),
		  char(10),
		  char(20);


define _numrecla	char(20);
define _no_tranrec2	char(10);
define _transaccion	char(10);
define _no_tranrec	char(10);
define _no_reclamo	char(10);
define _no_requis	char(10);
define _anular_nt	char(10);
define _valor_nvo	char(10);
define _no_orden	char(10);
define _user		char(10);
define _compania	char(3); 
define _sucursal	char(3); 
define _monto		dec(16,2);
define _ord_pagado	smallint;
define _pagado		smallint;
define _cant_sec	integer;
define _cantidad	integer;
define _error		integer;
define _dias		integer;
define _cant        smallint;

let _user     = "GERENCIA";
let _error    = 0;
let _cant_sec = 0;

--set debug file to "sp_rec245.trc";
--trace on;

set isolation to dirty read;

foreach with hold
 select pagado,
	    no_requis,
		numrecla,
		no_tranrec,
		no_reclamo,
		cod_compania,
		cod_sucursal,
		transaccion,
		monto,
		(today - fecha)
   into _pagado,
	    _no_requis,
		_numrecla,
		_no_tranrec,
	    _no_reclamo,
		_compania,
		_sucursal,
		_transaccion,
		_monto,
		_dias
   from rectrmae
  where cod_compania    	= "001"
    and actualizado     	= 1
    and cod_tipotran    	= "004"
	and periodo        	    >= "2014-01"
    and pagado          	= 0
    and monto           	> 0
    and (today - fecha)	    > 90
--	and periodo             <= '2018-04'
    and no_requis       	is null
    and anular_nt       	is null
    and numrecla[1,2]   	in("02","23","20")
  order by fecha, numrecla[6,7], numrecla[4,5], numrecla	

	begin
		on exception in(-535)
		end exception 	
		begin work;
	end

	let _cant = 0;
	
	select count(*)
	  into _cant
	  from rectrmae
	 where anular_nt = _transaccion
	   and actualizado = 0
	   and wf_aprobado = 3;	--N/T esperando para ser aprobada.
	   
	if _cant > 0 then
		continue foreach;
	end if
	  
	select pagado,
	       no_orden
	  into _ord_pagado,
	       _no_orden
      from recordma
     where trans_pend = _transaccion;	  
  
	if _ord_pagado is null then
		let _ord_pagado = 1;
	end if
  
	if _ord_pagado = 0 then
		if _dias > 180 then
			return _transaccion,
				   _monto,
				   2,
				   _no_orden,
				   _numrecla
				   with resume;
		end if
		
		commit work;
		continue foreach;		
	end if

	-- No Anula las transacciones que tienen cheques por procesar
	
	select count(*)
	  into _cantidad
	  from chqchrec r, chqchmae m
	 where r.no_requis	= m.no_requis
	   and pagado 			= 0
	   and transaccion		= _transaccion;
		
	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad <> 0 then
		commit work;
		continue foreach;
	end if

	-- No Anula las transacciones que tienen ajustes a ordenes

	select count(*)
	  into _cantidad
	  from recordad
	 where transaccion_alq = _transaccion;
		
	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad <> 0 then
		commit work;
		continue foreach;
	end if
	
--	let _cant_sec = _cant_sec + 1;
	
	let _valor_nvo = sp_sis13(_compania, "REC", "02", "par_tran_genera");

	call sp_rec127(_compania, _sucursal, _no_reclamo, _no_tranrec, _valor_nvo, "GERENCIA") returning _error, _anular_nt;

	if _error <> 0 then
		rollback work;
		return _transaccion,
		       _monto,
			   _error,
			   "Error",
			   _numrecla
		  with resume;
	else
		update rectrmae
		   set user_anulo = _user
		 where no_tranrec = _no_tranrec;
		
		update rectrmae
		   set user_anulo = _user,
			   user_added = _user
		 where no_tranrec = _valor_nvo;

		return _transaccion,
			   _monto,
			   0,
			   _anular_nt,
			   _numrecla
		  with resume;
		commit work;
	end if
end foreach

{begin
	on exception in(-535)

	end exception 	
	begin work;
end}
return "", 0, "99", "", "";
end procedure;