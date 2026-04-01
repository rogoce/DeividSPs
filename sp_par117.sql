-- Procedure que verifica integredidad entre las coberturas y la transaccion a nivel de reclamos

drop procedure sp_par117;

create procedure "informix".sp_par117()
returning smallint;

define _no_tranrec		char(10);
define _monto_tran		dec(16,2);
define _variacion_tran	dec(16,2);
define _monto_cob		dec(16,2);
define _variacion_cob	dec(16,2);

define _transaccion		char(10);
define _fecha			date;
define _periodo			char(7);

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

	select sum(monto),
	       sum(variacion)
	  into _monto_cob,
	       _variacion_cob
	  from rectrcob
	 where no_tranrec = _no_tranrec;

	if _monto_tran <> _monto_cob then

		return 1;

	end if

	if _variacion_tran <> _variacion_cob then

		return 1;

	end if

end foreach

return 0;

end procedure

