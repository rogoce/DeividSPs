-- Valida Prima Cedida de endedmae, endeduni, reacompasie
-- 
-- Creado     : 02/10/2012 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pre02;		

create procedure "informix".sp_pre02()
returning char(10),
          char(5),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _periodo1		char(7);
define _periodo2		char(7);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);

define _prima_sus_end	dec(16,2);
define _prima_sus_uni	dec(16,2);
define _prima_sus_asi	dec(16,2);

define _prima_ret_end	dec(16,2);
define _prima_ret_uni	dec(16,2);
define _prima_ret_asi	dec(16,2);

define _prima_ced_end	dec(16,2);
define _prima_ced_uni	dec(16,2);
define _prima_ced_asi	dec(16,2);

define _cod_cober_reas	char(3);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _no_registro		char(10);

define _cantidad		smallint;

set isolation to dirty read;

let _periodo1 = "2011-10";
--let _periodo1 = "2012-09";
let _periodo2 = "2012-09";

foreach
 select no_poliza,
        no_endoso,
		prima_suscrita,
		prima_retenida
   into _no_poliza,
        _no_endoso,
		_prima_sus_end,
		_prima_ret_end
   from endedmae
  where periodo    >= _periodo1
    and periodo    <= _periodo2
	and actualizado = 1

	let _prima_ced_end = _prima_sus_end - _prima_ret_end;

	select no_registro
	  into _no_registro
	  from sac999:reacomp
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select sum(debito - credito)
	  into _prima_ced_asi
	  from sac999:reacompasie
	 where no_registro = _no_registro
	   and cuenta      like "511%";

	if _prima_ced_asi is null then
		let _prima_ced_asi = 0;
	end if

	 select count(*)
	   into _cantidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso;

	{
	if _cantidad = 1 then

		let _prima_ced_uni = _prima_ced_asi;

	else

		let _prima_ced_uni = 0;

	    foreach	
		 select no_unidad,
		        prima_suscrita
		   into _no_unidad,
		        _prima_sus_uni
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
				
--			select min(cod_cober_reas)
--			  into _cod_cober_reas
--			  from emifacon
--			 where no_poliza = _no_poliza
--			   and no_endoso = _no_endoso
--			   and no_unidad = _no_unidad;
					

		    foreach	
			 select cod_contrato,
			        prima
			   into _cod_contrato,
			        _prima_ret_uni
			   from emifacon
			  where no_poliza      = _no_poliza
			    and no_endoso      = _no_endoso
			    and no_unidad      = _no_unidad
	--		    and cod_cober_reas = _cod_cober_reas

				select tipo_contrato
				  into _tipo_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _tipo_contrato <> 1 then
				
					let _prima_ced_uni = _prima_ced_uni + _prima_ret_uni;

				end if

			end foreach

		end foreach

	end if
	}
		
	if abs(_prima_ced_asi - _prima_ced_uni) > 0.25 then

--	if _prima_ced_asi - _prima_ced_uni <> 0 then
		
		return _no_poliza,
		       _no_endoso,
			   _prima_ced_end,
			   _prima_ced_uni,
			   _prima_ced_asi
			   with resume;

	end if

end foreach

return "00000",
       "00000",
	   0,
	   0,
	   0;

end procedure