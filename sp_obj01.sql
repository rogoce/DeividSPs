-- Procedure que carga los objetivos por ramo para los indicadores.

drop procedure sp_obj01;

create procedure sp_obj01()
returning integer, 
          char(50);

define _cod_ramo	char(3);
define _periodo		char(7);
define _cont		smallint;
define _mes			char(2);

delete from objramo;

foreach
 select cod_ramo
   into _cod_ramo
   from prdramo

	for _cont = 1 to 12

		let _mes = _cont;

--{
		if _cont < 10 then
			let _periodo = "2007-0" || trim(_mes);
		else
			let _periodo = "2007-" || trim(_mes);
		end if	

		insert into objramo
		values (_periodo, _cod_ramo, 0.00);

--}

	end for	

end foreach

return 0, "Actualizacion Existosa";

end procedure