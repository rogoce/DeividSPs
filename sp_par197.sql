-- Procedimiento que actualiza los valores de prima y se suma asegurada para endcoama

-- Creado    : 23/01/2002 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par197;

create procedure sp_par197()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _prima_neta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _cantidad		integer;
define _porc_coas		dec(7,4);
define _cod_coasegur    char(3);

define _suma_total		dec(16,2);
define _prima_total		dec(16,2);
define _suma_reas		dec(16,2);
define _prima_reas		dec(16,2);
define _suma_dist		dec(16,2);
define _prima_dist		dec(16,2);

set isolation to dirty read;

let _cantidad = 0;

foreach
 select no_poliza,
        no_endoso,
        prima_neta,
		suma_asegurada
   into _no_poliza,
        _no_endoso,
        _prima_neta,
		_suma_asegurada
   from endedmae
  where actualizado = 1
	and cod_endomov = "018"
--	and no_poliza   = "202666"

	let _cantidad = _cantidad + 1;

	select sum(suma_asegurada),
	       sum(prima_neta)
	  into _suma_total,
	       _prima_total
	  from endedmae
	 where no_poliza   = _no_poliza
	   and no_endoso   < _no_endoso
	   and actualizado = 1;

   foreach	
	select cod_coasegur,
	       porc_partic_coas
	  into _cod_coasegur,
	       _porc_coas
	  from endcamco
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso

		select sum(r.suma),
		       sum(r.prima)
		  into _suma_reas,
			   _prima_reas
		  from endcoama r, endedmae e
		 where r.no_poliza    = _no_poliza
		   and r.no_poliza    = e.no_poliza
		   and r.no_endoso    = e.no_endoso
		   and e.no_endoso    < _no_endoso
		   and e.actualizado  = 1
		   and r.cod_coasegur = _cod_coasegur;  	

		if _suma_reas is null then
			let _suma_reas = 0.00;
		end if

		if _prima_reas is null then
			let _prima_reas = 0.00;
		end if

		let _suma_dist  = (_suma_total  * _porc_coas / 100) - _suma_reas;	
		let _prima_dist = (_prima_total * _porc_coas / 100) - _prima_reas;	

		update endcoama
		   set prima        = _prima_dist,
		       suma         = _suma_dist
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso
		   and cod_coasegur = _cod_coasegur;  	

	end foreach

end foreach

return _cantidad, " Registros Procesados";

end procedure
