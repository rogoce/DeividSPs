-- Procedimiento que carga los registros para la division de cobros
 
-- Creado     :	22/08/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob286;		

create procedure sp_cob286()
returning smallint,
          char(50);

define _cod_formapag	char(3);
define _cod_cobrador	char(3);

define _cantidad		smallint;

delete from cobdivco;

let _cantidad = 0;

foreach
 select	cod_formapag
   into _cod_formapag
   from cobforpa

	foreach
	 select cod_cobrador
	   into _cod_cobrador
	   from cobcobra
      where tipo_cobrador = 13

		let _cantidad = _cantidad + 1;

		insert into cobdivco
		values (_cod_formapag, _cod_cobrador, "6");
		
	end foreach

end foreach

return 0, _cantidad || " " || "Actualizacion Exitosa";

end procedure		
