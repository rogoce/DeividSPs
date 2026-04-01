-- Procedure que verifica la informacion de reaseguros vs la cuenta 417 y 544

drop procedure sp_par344;

create procedure "informix".sp_par344()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _numrecla	char(20);
define _no_tranrec	char(10);
define _no_registro	char(10);

define _monto_reas	dec(16,2);
define _monto_asie	dec(16,2);
define _monto_calc	dec(16,2);

define _periodo		char(7);

--set debug file to "sp_par344.trc";
--trace on;

let _periodo = "2014-01";

foreach
 select reclamo,
        pag_contrato
   into _numrecla,
        _monto_reas
   from deivid_tmp:tmp_sinpag201401
--  where reclamo = "02-0114-00008-01"	

	let _monto_asie = 0;

	foreach
	 select no_tranrec
	   into _no_tranrec
	   from rectrmae
	  where numrecla     = _numrecla
	    and actualizado  = 1
		and periodo      = _periodo
		and cod_tipotran in ("004", "005", "006", "007")

		foreach 
		 select no_registro
		   into _no_registro
		   from sac999:reacomp
		  where no_tranrec = _no_tranrec

			select sum(credito - debito)
			  into _monto_calc
			  from sac999:reacompasie
			 where no_registro = _no_registro
			   and (cuenta[1,3] = "417" or cuenta[1,3] = "544");

			if _monto_calc is null then
				let _monto_calc = 0;
			end if

			let _monto_asie = _monto_asie + _monto_calc;

		end foreach

	end foreach

	if _monto_asie <> _monto_reas then

		return _numrecla,
		       _monto_reas,
			   _monto_asie
			   with resume;

	end if

end foreach

return "0",
       "",
	   "";

end procedure