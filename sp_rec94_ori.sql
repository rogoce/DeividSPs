-- Verificacion del Incurrido para los Excesos de Perdida

-- Creado    : 11/08/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec94;

create procedure "informix".sp_rec94()
returning integer,
		  char(20),
          char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(7);

define _porc_retencion	dec(16,2);
define _suma_max_ret	dec(16,2);
define _cod_tipotran	char(3);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _transaccion		char(10);
define _numrecla		char(20);
define _monto_tr		dec(16,2);
define _variacion_tr	dec(16,2);

define _incurrido_bruto dec(16,2);
define _incurrido_neto  dec(16,2);
define _inc_neto_acum   dec(16,2);

define _porc_coas		dec(7,4);
define _porc_reas		dec(7,4);

define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _monto_inc		dec(16,2);
define _fecha			date;
define _ano				smallint;
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _periodo			char(7);

foreach
 select no_tranrec,
		transaccion,
		no_reclamo,
		fecha,
		monto,
		variacion,
		periodo
   into	_no_tranrec,
		_transaccion,
		_no_reclamo,
		_fecha,
		_monto_tr,
		_variacion_tr,
		_periodo
   from rectrmae
  where	actualizado = 1
--    and periodo     = "2004-07"
--  and no_reclamo  = "42274"
	and numrecla    = "02-0304-00428-01"
  order by no_reclamo, no_tranrec

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _ano = year(_fecha);

	select monto
	  into _suma_max_ret
	  from reaexper
	 where cod_ramo = _cod_ramo
	   and ano      = _ano;

	if _suma_max_ret is null then
		let _suma_max_ret = 0.00;
	end if

	if _suma_max_ret = 0.00 then
		continue foreach;
	end if

	select numrecla
	  into _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select porc_partic_coas
	  into _porc_coas
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0.00;
	end if

	let _inc_neto_acum = 0.00;

   foreach	
	select monto,
	       variacion,
	       cod_tipotran
	  into _monto,
	       _variacion,
	       _cod_tipotran
	  from rectrmae
	 where actualizado = 1 
	   and no_reclamo  = _no_reclamo
	   and transaccion <= _transaccion

		if _cod_tipotran = "004" or
		   _cod_tipotran = "005" or
		   _cod_tipotran = "006" or
		   _cod_tipotran = "007" then

			let _monto_inc = _monto;

		else

			let _monto_inc = 0.00;

		end if

		let _incurrido_bruto = _monto_inc + _variacion;
		let _incurrido_bruto = _incurrido_bruto * _porc_coas / 100;

		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1;

		if _porc_reas is null then
			let _porc_reas = 0.00;
		end if		

		let _incurrido_neto = _incurrido_bruto * _porc_reas / 100;
		let _inc_neto_acum  = _inc_neto_acum + _incurrido_neto;

	end foreach
	
	if _inc_neto_acum > _suma_max_ret then

		return 1,
		       _numrecla,
			   _transaccion,
			   _inc_neto_acum,
			   _monto_tr,
			   _variacion_tr,
			   _periodo
			   with resume;

	end if

end foreach

end procedure