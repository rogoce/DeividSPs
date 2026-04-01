-- Procedure que retorna las reservas y los deducibles

drop procedure sp_rec225;

create procedure sp_rec225()
returning char(50),
          char(20),
          char(20),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _numrecla		char(20);
define _no_documento	char(20);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _reserva_bruto	dec(16,2);
define _reserva_neto	dec(16,2);
define _deducible		dec(16,2);

define _cod_ramo		char(3);
define _nom_ramo		char(50);

define _filtros			char(255);

call sp_rec02("001", "001", "2013-12") returning _filtros;

foreach
 select numrecla,
        no_reclamo,
		reserva_bruto,
		reserva_neto,
		no_poliza,
		cod_ramo
   into	_numrecla,
        _no_reclamo,
		_reserva_bruto,
		_reserva_neto,
		_no_poliza,
		_cod_ramo
   from tmp_sinis
  where cod_ramo in ("002", "020")

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select sum(deducible)
	  into _deducible
	  from recrccob
	 where no_reclamo = _no_reclamo;

	return _nom_ramo,
	       _numrecla,
	       _no_documento,
		   _reserva_bruto,
		   _reserva_neto,
		   _deducible
		   with resume;

end foreach

drop table tmp_sinis;

end procedure