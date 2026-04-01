drop procedure sp_rec235;

create procedure "informix".sp_rec235()
returning char(20),
          char(20),
		  date,
		  date,
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_siniestro	date;
define _fecha_reclamo	date;

set isolation to dirty read;


foreach
 select no_reclamo,
        numrecla,
		no_documento,
		fecha_siniestro,
		fecha_reclamo,
		no_poliza
   into _no_reclamo,
        _numrecla,
		_no_documento,
		_fecha_siniestro,
		_fecha_reclamo,
		_no_poliza
   from recrcmae
  where actualizado = 1
    and periodo     = "2014-01"

	return _numrecla,
	       _no_documento,
		   _fecha_siniestro,
		   null,
		   _fecha_reclamo,
		   0.00,
		   0.00,
		   0.00
		   with resume;

end foreach

end procedure