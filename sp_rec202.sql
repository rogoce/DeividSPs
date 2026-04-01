-- Pagos al Asegurado

-- 


drop procedure sp_rec202;

create procedure "informix".sp_rec202()
returning char(20),
          char(20),
		  date,
		  char(50),
		  date,
		  date,
		  dec(16,2);

define _numrecla		char(20);
define _no_reclamo		char(20);
define _fecha_siniestro	date;
define _fecha_pago		date;
define _fecha_pago2		date;
define _fecha_pago3		date;
define _fecha_pago4		date;
define _fecha_prima		date;

define _reserva			dec(16,2);
define _monto			dec(16,2);
define _monto2			dec(16,2);
define _monto3			dec(16,2);
define _monto4			dec(16,2);
define _cod_cliente		char(10);
define _tipo_persona	char(1);

define _no_documento	char(20);
define _no_poliza		char(20);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);

foreach
 select numrecla,
        no_reclamo,
		no_poliza,
		fecha_siniestro
   into _numrecla,
        _no_reclamo,
		_no_poliza,
		_fecha_siniestro
   from recrcmae
  where actualizado = 1
  	and year(fecha_siniestro) = 2012
--	and month(fecha_siniestro) = 11

	select no_documento,
	       cod_ramo
	  into _no_documento,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_ramo not in ("002", "020", "018") then
		continue foreach;
	end if

	-- Pago al Asegurado

	select sum(monto),
	       min(fecha)
	  into _monto,
	       _fecha_pago
	  from rectrmae
	 where actualizado  = 1
	   and no_reclamo   = _no_reclamo
	   and cod_tipotran = "004"
	   and cod_tipopago = "003";

	if _monto is null then
		let _monto = 0.00;
	end if

	if _fecha_pago is null then
		let _fecha_pago = today;
	end if
	
	-- Reembolso Persona Natural

	let _monto3      = 0;
	let _fecha_pago3 = today;

	foreach
	 select	monto,
	        cod_cliente,
			fecha
	   into	_monto2,
	        _cod_cliente,
			_fecha_pago2
	   from rectrmae
	  where actualizado  = 1
	    and no_reclamo   = _no_reclamo
	    and cod_tipotran = "004"
	    and cod_tipopago <> "003"
	
		select tipo_persona
		  into _tipo_persona
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _tipo_persona <> "N" then
			continue foreach;
		end if

		let _monto3 = _monto3 + _monto2;

		if _fecha_pago2 < _fecha_pago3 then
			let _fecha_pago3 = _fecha_pago2;
		end if

	end foreach

	let _monto4 = _monto3 + _monto;

	if _monto4 = 0 then
		continue foreach;
	end if

	if _fecha_pago < _fecha_pago3 then
		let _fecha_pago4 = _fecha_pago;
	else
		let _fecha_pago4 = _fecha_pago3;
	end if 

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select max(fecha)
	  into _fecha_prima
	  from cobredet
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and tipo_mov    = "P";

	return _numrecla,
	       _no_documento,
		   _fecha_siniestro,
		   _nombre_ramo,
		   _fecha_pago4,
		   _fecha_prima,
	       _monto4
		   with resume;

end foreach

end procedure