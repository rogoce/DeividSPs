drop procedure sp_par218;

create procedure "informix".sp_par218()
returning integer,
          char(50);

define _cod_ruta		char(5);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _orden			smallint;
define _serie			smallint;
define _cantidad		smallint;

foreach
 select cod_ruta,
        serie
   into _cod_ruta,
        _serie
   from rearumae

	select count(*)
	  into _cantidad
	  from rearucon r, reacomae c
	 where r.cod_contrato  = c.cod_contrato
	   and c.tipo_contrato = 3
       and r.cod_ruta      = _cod_ruta;

	if _cantidad <> 0 then

		select max(orden)
		  into _orden
		  from rearucon
		 where cod_ruta = _cod_ruta;
		
		let _orden = _orden + 1;

		foreach
		 select cod_contrato
		   into _cod_contrato
		   from reacomae
		  where serie         = _serie
		    and fronting      = 1
			and tipo_contrato = 3

			insert into rearucon
			values (_cod_ruta, _orden, _cod_contrato, 0.00, 0.00);

			exit foreach;

		end foreach

	end if

end foreach    

return 0, "Actualizacion Exitosa";

end procedure