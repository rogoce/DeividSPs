create procedure "informix".sp_par136()

define _no_poliza			char(10);
define _no_endoso			char(5);
define _prima_suscrita		dec(16,2);
define _prima_neta			dec(16,2);
define _porc_partic_coas	decimal(7,4);

foreach
 select no_poliza,
        no_endoso,
        prima_neta
   into _no_poliza,
        _no_endoso,
        _prima_neta
   from endedmae
  where cod_tipocan = "013"
    and prima_neta <> prima_suscrita

	select porc_partic_coas	
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = "036";

	let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

	update endedmae
	   set prima_suscrita = _prima_suscrita
	 where no_poliza      = _no_poliza
	   and no_endoso      = _no_endoso;

end foreach

end procedure