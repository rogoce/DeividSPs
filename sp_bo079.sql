drop procedure sp_bo079;

create procedure sp_bo079()
returning char(20),
		  dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _prima_ago		dec(16,2);
define _prima_sep		dec(16,2);

create temp table tmp_madrid(
no_documento	char(20),
prima_ago		dec(16,2),
prima_sep		dec(16,2)
) with no log;

foreach
 select no_documento,
        pri_sus_pag_aa
   into _no_documento,
        _prima_ago
   from deivid_tmp:tmp_madrid201108
  where cod_agente = "00218"

	insert into tmp_madrid
	values (_no_documento, 0, _prima_ago);

end foreach

foreach
 select no_documento,
        pri_sus_pag_aa
   into _no_documento,
        _prima_sep
   from deivid_tmp:tmp_madrid201109
  where cod_agente = "00218"

	insert into tmp_madrid
	values (_no_documento, _prima_sep, 0);

end foreach

foreach
 select no_documento,
        sum(prima_ago),
		sum(prima_sep)
   into _no_documento,
        _prima_ago,
		_prima_sep
   from tmp_madrid
  group by 1
  order by 2 desc

	if _prima_ago > _prima_sep then
	 
		return _no_documento,
	           _prima_ago,
			   _prima_sep
			   with resume;

	end if

end foreach

drop table tmp_madrid;

end procedure