
create procedure "informix".sp_par98()

define _cod_coasegur	char(3);
define _cod_ramo		char(3);
define _porcentaje		decimal(16,2);

foreach
 select cod_coasegur
   into _cod_coasegur
   from emicoase

	foreach
	 select cod_ramo
	   into _cod_ramo
	   from prdramo

		if _cod_coasegur = "010" or	   -- Conase
		   _cod_coasegur = "005" or	   -- Assa
		   _cod_coasegur = "013" then  -- Internacional

			if _cod_ramo = "002" or   -- Auto
			   _cod_ramo = "016" or	  -- Colectivo
			   _cod_ramo = "008" then -- Fianzas
			
				let _porcentaje = 5.00;

			else

				let _porcentaje = 3.00;

			end if

		elif _cod_coasegur = "009" or	 -- National Union
		     _cod_coasegur = "012" or	 -- Generalli
		     _cod_coasegur = "008" then  -- Interoceanica
	
			let _porcentaje = 5.00;

		elif _cod_coasegur = "025" then -- Asecomer
		
			if _cod_ramo = "016" then -- Colectivo
			
				let _porcentaje = 0.00;

			else

				let _porcentaje = 5.00;

			end if

		else

			if _cod_ramo = "002" or   -- Auto
			   _cod_ramo = "016" or	  -- Colectivo
			   _cod_ramo = "008" then -- Fianzas
			
				let _porcentaje = 5.00;

			else

				let _porcentaje = 3.00;

			end if

		end if

		insert into pargasma
		values(
		_cod_coasegur,
		_cod_ramo,
		_porcentaje
		);

	end foreach

end foreach

end procedure