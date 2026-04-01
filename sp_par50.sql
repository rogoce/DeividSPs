-- Verificacion del Reaseguro Actual 
-- de una Poliza

drop procedure sp_par50;

create procedure sp_par50(a_no_poliza char(10), a_cod_contrato char(5))
returning char(5),
		  char(3),
		  char(50),
		  char(5),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _no_endoso		char(5);
define _suma			dec(16,2);
define _prima			dec(16,2);

define _nombre_cober	char(50);
define _nombre_cont		char(50);
define _porc_suma		dec(16,2);
define _porc_prima		dec(16,2);

define _suma_total		dec(16,2);
define _prima_total		dec(16,2);

foreach
 select	r.no_unidad,
        r.cod_cober_reas,
		r.no_endoso,
		r.prima,
		r.suma_asegurada
   into	_no_unidad,
        _cod_cober_reas,
		_no_endoso,
		_prima,
		_suma
   from emifacon r, endedmae e
  where r.no_poliza   = a_no_poliza
    and r.no_poliza   = e.no_poliza
	and r.no_endoso   = e.no_endoso
	and e.actualizado = 1
	and r.cod_contrato  = a_cod_contrato
  order by r.no_unidad, r.cod_cober_reas, r.no_endoso
 
	select sum(r.prima),
		   sum(r.suma_asegurada)
	  into _prima_total,
	       _suma_total
	  from emifacon	r, endedmae e
	 where r.no_poliza      = a_no_poliza
	   and r.no_unidad      = _no_unidad
	   and r.cod_cober_reas = _cod_cober_reas      	   	
	   and r.no_poliza      = e.no_poliza
	   and r.no_endoso      = e.no_endoso
	   and r.no_endoso      = _no_endoso
	   and e.actualizado    = 1;

	if _suma_total = 0 then
		let _porc_suma  = 0;
	else		
		let _porc_suma  = _suma  / _suma_total  * 100;
	end if

	if _prima_total = 0 then
		let _porc_prima = 0;
	else
		let _porc_prima = _prima / _prima_total * 100;
	end if

 	select nombre
	  into _nombre_cober
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;

	select nombre
	  into _nombre_cont
	  from reacomae
	 where cod_contrato = a_cod_contrato;

	return _no_unidad,
	       _cod_cober_reas,
	       _nombre_cober,
	       _no_endoso,
	       _nombre_cont,
	       _prima,
	       _suma,
		   _porc_prima,
		   _porc_suma
	       with resume;	

end foreach

end procedure