-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 20/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram66;

create procedure "informix".sp_preram66()
returning char(3),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,5);

define _cod_ramo		char(3);
define _prima_suscrita	dec(16,2);
define _error_desc		char(100);
define _total_2009		dec(16,2);
define _total_2008		dec(16,2);
define _porc_09         dec(16,5);
define _n_ramo      	char(50);

foreach
	select cod_ramo,
	       sum(total_2009)
	  into _cod_ramo,
	       _total_2009
	  from preram2010
	 where tipo_mov in("52","54","56","58")
	 group by cod_ramo
	 order by cod_ramo

	select sum(total_2009)
	  into _prima_suscrita
	  from preram2010
	 where tipo_mov = "1"
       and cod_ramo = _cod_ramo;

	let _porc_09 = 0;

	if _prima_suscrita <> 0 then
		let _porc_09 =  (_total_2009 / _prima_suscrita) * 100;

	end if
	
	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	 RETURN _cod_ramo,	  
	        _n_ramo,	  
			_total_2009,  
			_prima_suscrita,
			_porc_09 	  
	        WITH RESUME;


end foreach

end procedure