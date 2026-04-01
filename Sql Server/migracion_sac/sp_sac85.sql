drop procedure sp_sac85;

create procedure sp_sac85()
returning char(5),
          dec(16,2),
          dec(16,2),
		  dec(16,2);

define _no_reclamo			char(10);
define _cod_coasegur 		char(3);
define _cod_auxiliar		char(5);
define _porc_coas_otras		dec(16,2);
define _monto				dec(16,2);
define _monto2				dec(16,2);
define _debito				dec(16,2);
define _credito				dec(16,2);

create temp table tmp_coas(
cod_auxiliar	char(5),
debito			dec(16,2),
credito			dec(16,2)
) with no log;

foreach
 select no_reclamo,
        monto
   into	_no_reclamo,
        _monto
   from rectrmae
  where periodo     = "2004-10"
    and actualizado = 1
	and cod_tipotran in ("004", "005", "006", "007")

   foreach
	select porc_partic_coas,
	       cod_coasegur
	  into _porc_coas_otras,
	       _cod_coasegur
	  from reccoas
	 where no_reclamo   =  _no_reclamo
	   and cod_coasegur <> "036"

		-- Reclamos por Cobrar

		let _debito  = 0.00;
		let _credito = 0.00;
		let _monto2  = _monto / 100 * _porc_coas_otras;

		if _monto2 >= 0.00 then
			let _debito  = _monto2;
		else
			let _credito = _monto2;
		end if

		select cod_auxiliar
		  into _cod_auxiliar
		  from emicoase
		 where cod_coasegur = _cod_coasegur;

		insert into tmp_coas
		values(_cod_auxiliar, _debito, _credito);

	end foreach

end foreach

foreach
 select cod_auxiliar,
        sum(debito),
		sum(credito)
   into _cod_auxiliar,
        _debito,
		_credito
   from tmp_coas
  group by cod_auxiliar

	return _cod_auxiliar,
	       _debito,
		   _credito,
		   (_debito + _credito)
		   with resume;

end foreach

drop table tmp_coas;

end procedure
