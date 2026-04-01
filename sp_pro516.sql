-- Polizas SODA con los limites incorrectos

-- Creado    : 20/09/2012 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro516;

create procedure "informix".sp_pro516()
returning char(20),
          smallint,
          smallint;

define _no_documento	char(20);
define _reempla_poliza	char(20);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_cobertura	char(5);
define _limite_1		dec(16,2);
define _limite_2		dec(16,2);
define _ano				smallint;
define _mes				smallint;

define _error			smallint;

foreach
 select no_documento,
 		no_poliza,
		reemplaza_poliza,
		year(vigencia_final),
		month(vigencia_final)
   into _no_documento,
        _no_poliza,
		_reempla_poliza,
		_ano,
		_mes
   from emipomae
  where actualizado           = 1
    and cod_ramo              = "020"
	and year(vigencia_final)  = 2013
--	and month(vigencia_final) >= 1
	and renovada              = 0
	and estatus_poliza        <> 2
  order by 5

	if _reempla_poliza is not null then
		continue foreach;
	end if

	let _error = 0;

	foreach
	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza = _no_poliza

		foreach 
		 select	cod_cobertura,
		        limite_1,
				limite_2
		   into _cod_cobertura,
		        _limite_1,
				_limite_2
		   from emipocob
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad

			if _cod_cobertura = "01021" then

				if _limite_1 <> 5000  or
				   _limite_2 <> 10000 then

					let _error = 1;
					
				end if
				
			 elif _cod_cobertura = "01022" then

				if _limite_1 <> 5000  then

					let _error = 1;
					
				end if				

			end if

		end foreach

	end foreach

	if _error = 1 then

		return _no_documento,
		       _ano,
			   _mes
		       with resume;

	end if


end foreach

return "00000", 0, 0;

end procedure