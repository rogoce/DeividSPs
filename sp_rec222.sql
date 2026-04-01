-- Reporte de los reclamos abiertos en un periodo

-- Creado:	19/09/2013	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec222;

create procedure "informix".sp_rec222(_periodo_trab char(7))
returning char(20),
		  date,
		  date,
		  date,
          char(7),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  smallint;

define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva_inic	dec(16,9);
define _reserva_cierre	dec(16,2);
define _periodo			char(7);
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _fecha_cierre	date;
define _no_poliza		char(10);

define _cod_evento		char(3);
define _nom_evento		char(50);

define _cod_ramo		char(3);
define _nom_ramo		char(50);

define _tipo			smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, "", "", "", _error_isam, _error_desc, 0, 0, _numrecla, 0;
end exception

let _fecha_cierre   = null;
let _reserva_cierre = 0.00;

foreach
 select periodo,
        numrecla,
    	cod_evento,
		no_poliza,
		no_reclamo,
		fecha_siniestro,
		fecha_reclamo
   into _periodo,
        _numrecla,
	    _cod_evento,
		_no_poliza,
		_no_reclamo,
		_fecha_siniestro,
		_fecha_reclamo
   from recrcmae
  where periodo     >= _periodo_trab
    and periodo     <= "2013-08"
    and actualizado = 1

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("002", "020") then
		continue foreach;
	end if

	let _tipo = 3;

	select nombre
	  into _nom_evento
	  from recevent
	 where cod_evento = _cod_evento;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select sum(variacion)
	  into _reserva_inic
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "001"
	   and actualizado  = 1;

	if _reserva_inic is null then
		let _reserva_inic = 0.00;
	end if

	select variacion,
	       fecha
	  into _reserva_cierre,
	       _fecha_cierre
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "011"
	   and actualizado  = 1
	   and user_added   = "informix";

	if _reserva_cierre is null then
		let _reserva_cierre = 0.00;
	end if

	if _reserva_cierre <> 0.00 then

		let _tipo = 1;

		select count(*)
		  into _cantidad
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1;

		if _cantidad > 2 then
			let _tipo = 2;
		end if

	end if

	return _numrecla,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _fecha_cierre,
	       _periodo,
		   _nom_evento,
		   _reserva_inic,
		   _reserva_cierre,
		   _nom_ramo,
		   _tipo
		   with resume;

end foreach

end

end procedure