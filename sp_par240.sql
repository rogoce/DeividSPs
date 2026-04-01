-- Actualizacion de los registros de morosidad y cobros para BO

-- Creado    : 28/08/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par240; 

create procedure "informix".sp_par240()
returning char(10),
          dec(16,2),
          dec(16,2);

define _no_tranrec	char(10);
define _no_reclamo	char(10);
define _transaccion	char(10);
define _monto1		dec(16,2);
define _monto2		dec(16,2);
define _porc_coas	dec(16,2);
define _porc_reas	dec(16,6);

foreach
 select no_tranrec,
        no_reclamo,
		transaccion,
		variacion
   into _no_tranrec,
        _no_reclamo,
		_transaccion,
		_monto1
   from rectrmae
  where actualizado = 1
    and periodo     >= "2008-04"
	and periodo     <= "2008-04"

	select porc_partic_coas
	  into _porc_coas
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = "036"; 

	select porc_partic_suma
	  into _porc_reas
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato = 1;

	if _porc_reas is null then
		let _porc_reas = 0;
	end if;

	let _monto1 = _monto1 / 100 * _porc_coas;
	let _monto1 = _monto1 / 100 * _porc_reas;

	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta     like "553%";

	if _monto2 is null then
		let _monto2 = 0.00;
	end if

	if _monto1 <> _monto2 then

		return _transaccion,
			   _monto1,
			   _monto2
			   with resume;

	end if

end foreach

end procedure
