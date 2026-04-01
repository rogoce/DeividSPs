


--drop procedure sp_rec195a;

create procedure "informix".sp_rec195a(a_numrecla char(20))
returning char(20),
          char(7),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _periodo		char(7);
define _pagos		dec(16,2);
define _variacion	dec(16,2);
define _incurrido	dec(16,2);

create temp table tmp_incurrid(
periodo		char(7),
pagos		dec(16,2),
variacion	dec(16,2)
) with no log;

set isolation to dirty read;

foreach
 select	periodo,
        variacion
   into _periodo,
        _variacion
   from rectrmae
  where numrecla     = a_numrecla
    and periodo[1,4] >= 2010
	and periodo[1,4] <= 2011
	and actualizado  = 1

	insert into tmp_incurrid
	values (_periodo, 0, _variacion);

end foreach

foreach
 select	periodo,
        monto
   into _periodo,
        _pagos
   from rectrmae
  where numrecla     = a_numrecla
    and periodo[1,4] >= 2010
	and periodo[1,4] <= 2011
	and actualizado  = 1
	and cod_tipotran in ("004", "005", "006", "007")

	insert into tmp_incurrid
	values (_periodo, _pagos, 0);

end foreach

foreach
 select periodo,
        sum(pagos),
		sum(variacion)
   into _periodo,
        _pagos,
		_variacion
   from tmp_incurrid
  group by periodo
  order by periodo

	let _incurrido = _pagos + _variacion;

	return a_numrecla,
	       _periodo,
		   _pagos,
		   _variacion,
		   _incurrido
		   with resume;

end foreach

drop table tmp_incurrid;

end procedure