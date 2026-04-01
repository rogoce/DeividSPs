  
--drop procedure sp_leyri06;

create procedure "informix".sp_leyri06()
returning char(10),	 
          char(10),	 
		  char(30);

define _cod_chequera 	char(3); 
define _nombre_caja		char(50);
define _fecha 			date; 
define _en_balance		smallint;

define _no_remesa		char(10);
define _recibi_de		char(50);
define _no_recibo		char(10);
define _tipo_mov		char(1);
define _doc_remesa		char(30);

define _contador		smallint;
define _cantidad		smallint;

define _tipo_pago		smallint;
define _tipo_tarjeta	smallint;
define _renglon			smallint;
define _importe			dec(16,2);
define _tipo_dato		smallint;
define _n_movimiento    char(50);
define _n_cobrador		char(30);
define _monto           dec(16,2);
define _cod_cobrador    char(3);
define _tipo_remesa		char(1);
define _recibo1         char(10);
define _recibo2         char(10);

set isolation to dirty read;

let _cod_cobrador = null;
let _n_cobrador   = null;

foreach

 select recibo
   into _recibo1
   from aaa

	foreach

		select no_remesa
		  into _no_remesa
		  from cobredet
		 where no_recibo = _recibo1
         group by no_remesa

		foreach

			 select tipo_pago
			   into _tipo_pago
			   from cobrepag
			  where no_remesa = _no_remesa

			if _tipo_pago = 1 then
			   let _n_cobrador = 'Efectivo';
			elif _tipo_pago = 2 then
			   let _n_cobrador = 'Cheque';
			elif _tipo_pago = 3 then
			   let _n_cobrador = 'Clave';
			elif _tipo_pago = 4 then
			   let _n_cobrador = 'Tarjeta Credito';

			end if

			return _no_remesa,
				   _recibo1, 
				   _n_cobrador
				   with resume;

		end foreach

	end foreach
end foreach


{foreach

 select recibo1
   into _recibo1
   from aa

	foreach

		select no_remesa,
		       no_recibo,
			   sum(monto)
		  into _no_remesa,
		       _no_recibo,
			   _monto
		  from cobredet
		 where no_recibo = _recibo1
         group by no_remesa,no_recibo
		 order by no_recibo

		 select fecha,
				tipo_remesa
		   into _fecha,
				_tipo_remesa
		   from cobremae
		  where no_remesa   = _no_remesa
			and actualizado = 1;

		return _no_remesa,
			   _no_recibo, 
			   _monto,
			   _fecha,
			   _tipo_remesa
			   with resume;


	end foreach
end foreach	 }


end procedure