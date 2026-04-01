-- Verificacion del Reaseguro Actual 
-- de una Poliza

drop procedure sp_par48;

create procedure sp_par48(a_no_poliza char(10))
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
define _cod_contrato	char(5);
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
		r.cod_contrato,
		sum(r.prima),
		sum(r.suma_asegurada)
   into	_no_unidad,
        _cod_cober_reas,
		_cod_contrato,
		_prima,
		_suma
   from emifacon r, endedmae e
  where r.no_poliza   = a_no_poliza
    and r.no_poliza   = e.no_poliza
	and r.no_endoso   = e.no_endoso
	and e.actualizado = 1
--	and r.no_endoso   < "00004"
  group by r.no_unidad, r.cod_cober_reas, r.cod_contrato
  order by r.no_unidad, r.cod_cober_reas, r.cod_contrato
 
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
--	   and r.no_endoso      < "00004"
	   and e.actualizado    = 1;

	let _porc_suma  = _suma  / _suma_total  * 100;
	let _porc_prima = _prima / _prima_total * 100;

 	select nombre
	  into _nombre_cober
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;

	select nombre
	  into _nombre_cont
	  from reacomae
	 where cod_contrato = _cod_contrato;

	return _no_unidad,
	       _cod_cober_reas,
	       _nombre_cober,
	       _cod_contrato,
	       _nombre_cont,
	       _prima,
	       _suma,
		   _porc_prima,
		   _porc_suma
	       with resume;	

end foreach

end procedure