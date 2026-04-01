drop procedure sp_par347;

create procedure "informix".sp_par347()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _prima_suscrita	dec(16,2);
define _prima_suscrita2	dec(16,2);

create temp table tmp_diferencia(
no_documento	char(20),
prima_indicador	dec(16,2),
prima_bonibita2	dec(16,2)
) with no log;

foreach
 select poliza,
        prima_suscrita
   into _no_documento,
        _prima_suscrita
   from deivid_tmp:tmp_semusa201406

	insert into tmp_diferencia
	values (_no_documento, _prima_suscrita, 0);

end foreach

foreach
 select poliza,
        prima_suscrita
   into _no_documento,
        _prima_suscrita
   from bonibita2
  where periodo = "2014-12"
    and tipo = 2
    and cod_agente = "00270"
    and cod_ramo in (select cod_ramo
                       from prdrentram
                      where cod_tipo = "003"
                        and periodo = "2014-12")

	insert into tmp_diferencia
	values (_no_documento, 0, _prima_suscrita);

end foreach

foreach
 select no_documento,
        pri_susc_aa
   into _no_documento,
        _prima_suscrita
   from rentabilidad1
  where cod_agente = "00270"
    and periodo    = "2014-12"
    and tipo       = "003"

	insert into tmp_diferencia
	values (_no_documento, 0, _prima_suscrita);

end foreach

foreach
 select no_documento,
        sum(prima_indicador),
		sum(prima_bonibita2)
   into _no_documento,
        _prima_suscrita,
		_prima_suscrita2
   from tmp_diferencia
  group by 1
  order by 1

	if _prima_suscrita <> _prima_suscrita2 then 

		return _no_documento,
			   _prima_suscrita,
			   _prima_suscrita2
			   with resume;

	end if

end foreach

drop table tmp_diferencia;

end procedure