-- Verificacion de la Vigencia Final de las Unidades diferentes a la Poliza

drop procedure sp_par33;

create procedure sp_par33()
returning char(20),
		  char(10),
		  char(5),
		  date,
		  date,
		  char(100);
		  	
define _no_poliza			char(10);
define _no_unidad			char(10);
define _no_documento		char(20);
define _vigencia_final_pol	date;
define _vigencia_final_uni	date;
define _cantidad			integer;

foreach
 select	vigencia_final,
        no_documento,
		no_poliza
   into	_vigencia_final_pol,
		_no_documento,
		_no_poliza
   from	emipomae
  where actualizado = 1
--	and cod_ramo    <> "002"

	if _vigencia_final_pol is null then
		let _vigencia_final_pol = "01/01/00";
	end if
			
	 select count(*)
	   into _cantidad
	   from emipouni
	  where no_poliza = _no_poliza;

	foreach
	 select vigencia_final,
	        no_unidad
	   into _vigencia_final_uni,
	        _no_unidad
	   from emipouni
	  where no_poliza = _no_poliza

		if _vigencia_final_uni is null then
			let _vigencia_final_uni = "01/01/00";
		end if

		if _vigencia_final_pol is null then
			{
			update emipouni
			   set vigencia_final = _vigencia_final_pol
			 where no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad;
			--}
			if _vigencia_final_uni <> "18/11/2000" then
				return _no_documento,
					   _no_poliza,
					   _no_unidad,
					   _vigencia_final_pol,
					   _vigencia_final_uni,
					   "21 - Vigencia Final Is Null"
					   with resume;
		   else
				return _no_documento,
					   _no_poliza,
					   _no_unidad,
					   _vigencia_final_pol,
					   _vigencia_final_uni,
					   "20 - Vigencia Final Is Null"
					   with resume;
		   end if
		elif _vigencia_final_pol <> _vigencia_final_uni then
			if _vigencia_final_uni <> "18/11/2000" then
				if _vigencia_final_pol > _vigencia_final_uni then
					{
					update emipouni
					   set vigencia_final = _vigencia_final_pol
					 where no_poliza      = _no_poliza
					   and no_unidad      = _no_unidad;
					--}
					return _no_documento,
						   _no_poliza,
						   _no_unidad,
						   _vigencia_final_pol,
						   _vigencia_final_uni,
						   "01 - Vigencia Final Poliza Mayor"
						   with resume;
				else
					if _cantidad <> 1 then
						return _no_documento,
							   _no_poliza,
							   _no_unidad,
							   _vigencia_final_pol,
							   _vigencia_final_uni,
							   "02 - Vigencia Final Unidad Mayor + de 1 Unidad"
							   with resume;
					else
						{
						update emipouni
						   set vigencia_final = _vigencia_final_pol
						 where no_poliza      = _no_poliza
						   and no_unidad      = _no_unidad;
						--}
						return _no_documento,
							   _no_poliza,
							   _no_unidad,
							   _vigencia_final_pol,
							   _vigencia_final_uni,
							   "03 - Vigencia Final Unidad Mayor 1 Unidad"
							   with resume;
					end if
				end if
			else
				{
				update emipouni
				   set vigencia_final = _vigencia_final_pol
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad;
				--}
				return _no_documento,
					   _no_poliza,
					   _no_unidad,
					   _vigencia_final_pol,
					   _vigencia_final_uni,
					   "04 - Vigencia igual al 18/11/2000"
					   with resume;
			end if			
		end if			
	end foreach

end foreach

end procedure;