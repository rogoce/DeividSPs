drop procedure sp_par29;

create procedure sp_par29()
returning char(5),
          char(5),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _prima_neta_uni		dec(16,2);
define _prima_neta_end		dec(16,2);
define _prima_neta_cal		dec(16,6);
define _no_unidad			char(5);
define _cod_cobertura		char(5);
define _no_poliza			char(10);
define _no_endoso			char(5);

let _no_poliza = "81371";
let _no_endoso = "00012";

foreach
 select prima_neta,
        no_unidad,
		cod_cobertura
   into _prima_neta_uni,
        _no_unidad,
		_cod_cobertura
   from emipocob
  where no_poliza = _no_poliza

	select prima_neta
	  into _prima_neta_end
	  from endedcob
	 where no_poliza     = _no_poliza
	   and no_endoso     = _no_endoso
	   and no_unidad     = _no_unidad
	   and cod_cobertura = _cod_cobertura;

	let _prima_neta_cal = _prima_neta_uni * 0.999967;

--	if _prima_neta_cal <> _prima_neta_end then

		return _no_unidad,
		       _cod_cobertura,
			   _prima_neta_uni,
			   _prima_neta_cal,
			   _prima_neta_end
			   with resume;

--	end if

end foreach

end procedure;