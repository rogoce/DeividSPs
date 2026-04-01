-- Reporte de los reclamos abiertos en un periodo

-- Creado:	19/09/2013	Autor: Demetrio Hurtado Almanza

--drop procedure sp_rec221;

create procedure "informix".sp_rec221(_periodo_trab char(7))
returning char(20),
          char(7),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(2),
		  date,
		  char(2);

define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva_actual	dec(16,2);
define _reserva_inic	dec(16,9);
define _monto_pagado	dec(16,9);
define _incurrido		dec(16,9);
define _periodo			char(7);
define _fecha_pago		date;
define _no_poliza		char(10);

define _cod_legal		smallint;	
define _nom_legal		char(2);	

define _cod_evento		char(3);
define _nom_evento		char(50);

define _cod_ramo		char(3);
define _nom_ramo		char(50);

define _perd_total		smallint;
define _nom_perd_total	char(2);

define _filtros     	char(255);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam, _error_desc, 0, 0, 0, "", "", null, "";
end exception

let _incurrido = 0.00;
let _nom_legal = "No";

foreach
 select periodo,
        numrecla,
    	cod_evento,
	    perd_total,
	    estatus_audiencia,
		no_poliza,
		no_reclamo
   into _periodo,
        _numrecla,
	    _cod_evento,
	    _perd_total,
	    _cod_legal,
		_no_poliza,
		_no_reclamo
   from recrcmae
  where periodo     = _periodo_trab
    and actualizado = 1

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("002", "020") then
		continue foreach;
	end if

	select sum(variacion)
	  into _reserva_actual
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	select sum(monto),
	       max(fecha)
	  into _monto_pagado,
	       _fecha_pago
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "004"
	   and actualizado  = 1;

	if _monto_pagado is null then
		let _monto_pagado = 0.00;
	end if

	if _cod_legal in (3, 4, 5) then
		let _nom_legal = "Si";
	else
		let _nom_legal = "No";
	end if

	if _perd_total = 1 then
		let _nom_perd_total = "Si";
	else
		let _nom_perd_total = "No";
	end if

	select nombre
	  into _nom_evento
	  from recevent
	 where cod_evento = _cod_evento;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select variacion
	  into _reserva_inic
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "001"
	   and actualizado  = 1;

	if _reserva_inic is null then
		let _reserva_inic = 0.00;
	end if

	select sum(monto)
	  into _incurrido
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran in ("005", "006", "007")
	   and actualizado  = 1;

	if _incurrido is null then
		let _incurrido = 0.00;
	end if

	let _incurrido = _incurrido + _monto_pagado + _reserva_actual;

	return _numrecla,
	       _periodo,
		   _nom_evento,
		   _reserva_actual,
		   _incurrido,
		   _reserva_inic,
		   _nom_ramo,
		   _nom_perd_total,
		   _fecha_pago,
		   _nom_legal
		   with resume;

end foreach

end

end procedure