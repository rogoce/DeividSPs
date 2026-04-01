-- Procedimiento que Determina la unidad que en emireaco contemple las coberturas de reaseguro de la poliza
-- 
-- Creado    : 26/08/2016 - Autor: Armando Moreno M.

drop procedure sp_sis446;
create procedure sp_sis446(a_no_poliza char(10), a_no_cambio smallint)
returning char(5);

define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _valor			smallint;
define _cnt				smallint;
define _error			integer;

set isolation to dirty read;

begin

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	let _valor = 0;
		
	foreach
		select cod_cober_reas
		  into _cod_cober_reas
		  from tmp_dist_rea

		select nvl(count(*),0)
		  into _cnt
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_cambio = a_no_cambio
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas;

		if _cnt > 0 then
			let _valor = 1;
			exit foreach;
		else
			let _valor = 0;
			exit foreach;
		end if
	end foreach
	
	if _valor = 1 then
		exit foreach;
	end if	
end foreach

return _no_unidad;

end 
end procedure;