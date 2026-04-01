-- Porcedure que verifica integredidad entre las coberturas y la transaccion a nivel de reclamos

drop procedure sp_par116;

create procedure sp_par116()
returning char(10)	as transaccion,
       	  date		as fecha,
	      char(7)	as periodo,
	      dec(16,2)	as monto_tran,
	      dec(16,2)	as monto_cob,
	      char(1)	as flag;

define _transaccion		char(10);
define _no_tranrec		char(10);
define _periodo			char(7);
define _cod_cobertura	char(5);
define _variacion_tran	dec(16,2);
define _variacion_cob	dec(16,2);
define _monto_tran		dec(16,2);
define _monto_cob		dec(16,2);
define _cantidad		smallint;
define _fecha			date;

set isolation to dirty read;

foreach
	select no_tranrec,
		   monto,
		   variacion,
		   transaccion,
		   fecha,
		   periodo
	  into _no_tranrec,
		   _monto_tran,
		   _variacion_tran,
		   _transaccion,
		   _fecha,
		   _periodo
	  from rectrmae
	 where actualizado = 1
	   --and fecha = '12/02/2017'
	   --and transaccion = '01-143346'

	select sum(monto),
	       sum(variacion)
	  into _monto_cob,
	       _variacion_cob
	  from rectrcob
	 where no_tranrec = _no_tranrec;

	if _monto_tran <> _monto_cob then
		if _monto_tran = 0.00 then
			update rectrcob
			   set monto      = 0
			 where no_tranrec = _no_tranrec;
		else
			select count(*)
			  into _cantidad
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0;

			if _cantidad = 1 then
				update rectrcob
				   set monto      = _monto_tran
				 where no_tranrec = _no_tranrec
				   and monto <> 0;
			else
				update rectrcob
				   set monto      = 0.00
				 where no_tranrec = _no_tranrec;

				foreach
					select cod_cobertura
					  into _cod_cobertura
					  from rectrcob
					 where no_tranrec = _no_tranrec

					update rectrcob
					   set monto         = _monto_tran
					 where no_tranrec    = _no_tranrec
					   and cod_cobertura = _cod_cobertura;
					exit foreach;
				end foreach
			end if
		end if

		return _transaccion,
		       _fecha,
			   _periodo,
			   _monto_tran,
			   _monto_cob,
			   '1'
			   with resume;
	end if

	if _variacion_tran <> _variacion_cob then
		if _variacion_tran = 0.00 then
			update rectrcob
			   set variacion  = 0
			 where no_tranrec = _no_tranrec;
		else
			select count(*)
			  into _cantidad
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and variacion <> 0;

			if _cantidad = 1 then
				update rectrcob
				   set variacion  = _variacion_tran
				 where no_tranrec = _no_tranrec
				   and variacion <> 0;
			end if
		end if

		return _transaccion,
		       _fecha,
			   _periodo,
			   _variacion_tran,
			   _variacion_cob,
			   '2'
			   with resume;
	end if
end foreach

return	'0',
		null,
		null,
		0.00,
		0.00,
		'0' with resume;
end procedure;