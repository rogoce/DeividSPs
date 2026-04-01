drop procedure sp_che26;

create procedure "informix".sp_che26()
returning char(20),
          date,
		  char(10),
		  char(100),
		  dec(16,2),
		  char(255);

define _numrecla	char(20);
define _fecha		date;
define _transaccion	char(10);
define _nombre		char(100);
define _monto		dec(16,2);
define _no_tranrec	char(10);

define _desc_tran	char(100);
define _descripcion	char(255);
define _renglon		smallint;

define _no_requis	char(10);
define _anulado 	smallint;
define _pagado	 	smallint;

set isolation to dirty read;

foreach
 select r.numrecla, 
 		r.fecha, 
 		r.transaccion, 
 		c.nombre, 
 		r.monto,
		r.no_tranrec
   into _numrecla,
		_fecha,
		_transaccion,
		_nombre,
		_monto,
		_no_tranrec
  from rectrmae r, cliclien c
 where r.cod_cliente  = c.cod_cliente
   and r.actualizado  = 1
   and pagado         = 0
   and r.cod_tipopago = "004"
   and r.fecha        >= "01/01/2002"
 order by r.fecha

	let _anulado = null;

   foreach	
	select r.no_requis
	  into _no_requis
	  from chqchrec r
	 where r.transaccion = _transaccion
	 order by 1 desc

		select pagado,
			   anulado	
		  into _pagado,
		       _anulado
		  from chqchmae
		 where no_requis = _no_requis;

		if _pagado = 0 then
			continue foreach;
		end if

		exit foreach;

	end foreach

	if _anulado is null then
		let _anulado = 0;
	end if

	if _anulado = 1 then
		continue foreach;
	end if
		
--	update rectrmae
--	   set pagado     = 1
--	 where no_tranrec = _no_tranrec;

	let _descripcion = "";

	foreach
	 select desc_transaccion,
	        renglon
	   into _desc_tran,
	        _renglon
	   from rectrde2
	  where no_tranrec = _no_tranrec
	  order by renglon

		let _descripcion = trim(_descripcion) || " " || trim(_desc_tran);
	
	end foreach
	
	return _numrecla,
		   _fecha,
		   _transaccion,
		   _nombre,
		   _monto,
		   _descripcion
		   with resume;	

end foreach

end procedure