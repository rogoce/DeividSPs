-- Procedure que verifica las requisiciones de ach de reclamos para buscar posible inconsistencia.

-- Creado: 01/03/2021 - Autor: Armando Moreno M.
drop procedure sp_sis467;
create procedure sp_sis467(a_no_requis char(10)) 
returning char(10),
          dec(16,2),
          dec(16,2);

define _no_requis	char(10);
define _transaccion	char(10);
define _monto_trx	dec(16,2);
define _monto_chq	dec(16,2);
define _monto_tot	dec(16,2);
define _monto_chqchrec dec(16,2);
define _monto_tot_chrec dec(16,2);

define _cantidad	smallint;

set isolation to dirty read;

--set debug file to 'sp_sis467.trc';
--trace on;

--foreach
	select no_requis,
		   monto
	  into _no_requis,
		   _monto_chq
	  from chqchmae
	 where pagado  = 0
	   and anulado = 0
	   and origen_cheque = 3
	   and no_requis = a_no_requis
	   and tipo_requis = 'A';
--	 order by no_requis

	let _monto_tot = 0.00;
	let _monto_trx = 0.00;
	let _monto_chqchrec = 0.00;
	let _monto_tot_chrec = 0.00;

	foreach
	 select transaccion,
	        monto
	   into _transaccion,
	        _monto_chqchrec
	   from chqchrec
	  where no_requis = _no_requis

		select sum(monto)
		  into _monto_trx
		  from rectrmae
		 where transaccion = _transaccion
		   and cod_tipotran not in ("013");

		if _monto_trx is null then
			let _monto_trx = 0;
		end if 

		let _monto_tot = _monto_tot + _monto_trx;
		let _monto_tot_chrec = _monto_tot_chrec + _monto_chqchrec;
		
	end foreach

	if _monto_tot <> _monto_chq then

		return _no_requis,
		       _monto_chq,
			   _monto_tot;

	end if
	if _monto_tot_chrec <> _monto_chq then

		return _no_requis,
		       _monto_chq,
			   _monto_tot_chrec;

	end if
	if _monto_tot_chrec <> _monto_tot then

		return _no_requis,
		       _monto_tot,
			   _monto_tot_chrec;

	end if
		       
--end foreach

return "",
       0.00,
	   0.00;

end procedure