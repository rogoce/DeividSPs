drop procedure sp_rec130;

create procedure sp_rec130(a_periodo char(7))
returning char(20),
          char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date;

define _no_poliza	char(10);
define _cod_subramo	char(3);
define _numrecla	char(20);
define _nombre_sub	char(50);
define _cod_icd		char(10);
define _fecha_trx	date;

define _pagado_b	dec(16,2);
define _pagado_n	dec(16,2);
define _variacion	dec(16,2);
define _variacion_b	dec(16,2);
define _variacion_n	dec(16,2);
define _incurrido_b	dec(16,2);
define _incurrido_n	dec(16,2);

define _filtro      char(255);

set isolation to dirty read;

let _filtro = sp_rec02("001", "001", a_periodo);

foreach
 select no_poliza,
        numrecla,
		pagado_bruto,
		pagado_neto,
		incurrido_bruto,
		incurrido_neto,
		reserva_bruto,
		reserva_neto,
		reserva_total,
		ultima_fecha
   into _no_poliza,
        _numrecla,
		_pagado_b,
		_pagado_n,
		_incurrido_b,
		_incurrido_n,
		_variacion_b,
		_variacion_n,
		_variacion,
		_fecha_trx
   from tmp_sinis
  where cod_ramo = "018"

	select cod_icd
	  into _cod_icd
	  from recrcmae
	 where numrecla = _numrecla;

	if _cod_icd <> "V22.2" then
		continue foreach;
	end if

	select cod_subramo
	  into _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_subramo not in ("007", "008") then
		continue foreach;
	end if

	select nombre
	  into _nombre_sub
	  from prdsubra
	 where cod_ramo    = "018"
	   and cod_subramo = _cod_subramo;

	return _numrecla,
		   _nombre_sub,
		   _pagado_b,
		   _pagado_n,
		   _variacion_b,
		   _variacion_n,
		   _incurrido_b,
		   _incurrido_n,
	       _fecha_trx
		   with resume;

end foreach

drop table tmp_sinis;

end procedure 






											