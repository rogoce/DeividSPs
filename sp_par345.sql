-- Procedure que carga las tarifas por tipo de auto

-- Creado:	23/06/2014 - Autor: Demetrio Hurtado Almanza


drop procedure sp_par345;

create procedure "informix".sp_par345()
returning integer,
          char(50);

define _cod_tipo	smallint;
define _ano			smallint;
define _renglon		smallint;
define _rango_1		dec(16,2);
define _rango_2		dec(16,2);

delete from emitiautdesc;

for _cod_tipo = 1 to 3

	for _ano = 0 to 9 

		for _renglon = 1 to 6

			if _renglon = 1 then
				let _rango_1 = 0;
				let _rango_2 = _rango_1 + 5000;
			elif _renglon = 2 then
				let _rango_1 = 5000;
				let _rango_2 = _rango_1 + 5000;
			elif _renglon = 3 then
				let _rango_1 = 10000;
				let _rango_2 = _rango_1 + 5000;
			elif _renglon = 4 then
				let _rango_1 = 15000;
				let _rango_2 = _rango_1 + 5000;
			elif _renglon = 5 then
				let _rango_1 = 20000;
				let _rango_2 = _rango_1 + 5000;
			elif _renglon = 6 then
				let _rango_1 = 25000;
				let _rango_2 = 1000000;
			end if

			insert into emitiautdesc
			values (_cod_tipo, _ano, _renglon, _rango_1, _rango_2, 0);

		end for

	end for

end for

return 0, "Actualizacion Exitosa";

end procedure 