-- Procedure que Actualiza los comprobantes de Mayor

-- Creado: 03/02/2007 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_che71;

create procedure sp_che71() 
returning char(10),
          dec(16,2),
          dec(16,2);

define _no_requis	char(10);
define _transaccion	char(10);
define _monto_trx	dec(16,2);
define _monto_chq	dec(16,2);
define _monto_tot	dec(16,2);

define _cantidad	smallint;

set isolation to dirty read;

--set debug file to 'sp_che71.trc';
--trace on;

foreach
 select no_requis,
        monto
   into _no_requis,
        _monto_chq
   from chqchmae
  where origen_cheque = 3
	and pagado        = 1
	and anulado = 0
	and periodo >= "2010-01"
	and no_requis not in("944926","342565","352640","372864","377847","537468","544490","556791")	 --se coloco provisional por investigacion 16/12/2010
	--and no_requis in ('717881')
  order by no_requis

	let _monto_tot = 0.00;
	let _monto_trx = 0.00;

	foreach
	 select transaccion
	   into _transaccion
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
		
	end foreach

	if _monto_tot <> _monto_chq then

{
		select count(*)
		  into _cantidad
		  from chqchrec
		 where no_requis = _no_requis;

		if _cantidad = 0 then
			
			delete from chqchdes
		     where no_requis = _no_requis;

			delete from chqchcta
		     where no_requis = _no_requis;

			update rectrmae
			   set no_requis = null
			 where no_requis = _no_requis;

			delete from chqchmae
		     where no_requis = _no_requis;
	
		end if
}

		return _no_requis,
		       _monto_chq,
			   _monto_tot
			   with resume;

	end if
		       
end foreach

return "",
       0.00,
	   0.00;

end procedure