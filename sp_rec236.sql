drop procedure sp_rec236;

create procedure "informix".sp_rec236()
returning char(50),
          char(50),
		  char(20),
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
define _fecha_recibo	date;

define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _cod_agente		char(5);
define _nombre_agente	char(50);

define _monto_pagado	dec(16,2);
define _monto_reserva	dec(16,2);
define _monto_cobrado	dec(16,2);

define _periodo			char(7);

set isolation to dirty read;


let _periodo = "2014-01";

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
    and periodo     >= _periodo
  order by numrecla

	select min(fecha),
	       sum(prima_neta)
	  into _fecha_recibo,
	       _monto_cobrado
	  from cobredet
	 where doc_remesa = _no_documento
	   and actualizado = 1
	   and tipo_mov in ("P", "N");

	if _fecha_recibo  > _fecha_siniestro and 
	   _fecha_reclamo > _fecha_recibo    then	   

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		foreach
		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza
			exit foreach;
		end foreach

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		select sum(monto)
		  into _monto_pagado
		  from rectrmae
		 where cod_compania = "001"
		   and actualizado  = 1
		   and cod_tipotran = "004"
		   and periodo      >= _periodo
		   and numrecla     = _numrecla;

		select sum(variacion)
		  into _monto_reserva
		  from rectrmae
		 where cod_compania = "001"
		   and periodo      >= _periodo
           and actualizado  = 1
		   and numrecla     = _numrecla;

	    return _nombre_ramo,
		       _nombre_agente,
	           _numrecla,
		       _no_documento,
			   _fecha_siniestro,
			   _fecha_recibo,
			   _fecha_reclamo,
			   _monto_pagado,
			   _monto_reserva,
			   _monto_cobrado
			   with resume;

	end if

end foreach

end procedure