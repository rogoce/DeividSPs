-- Procedure que carga los registros para el WEB

-- Creado: 08/02/2007 - Autor: Demetrio Hurtado Almanza

drop procedure sp_itzis_endoso;

create procedure "informix".sp_itzis_endoso()
returning integer,
          char(100);

define _no_poliza			char(10);
define _no_factura			char(10);
define _no_endoso			char(10);
define _contador			smallint;


begin


set isolation to dirty read;

--SET DEBUG FILE TO "sp_web01.trc";
--TRACE ON ;
let _contador = 0;

  foreach
  	  select no_factura
		  into _no_factura
		  from deivid_web:malitos
		  	
	foreach
		select no_poliza,
			no_endoso
		  into _no_poliza,
		  _no_endoso
		  from endedmae
		 where no_factura = _no_factura

		delete from deivid_web:malitos
			where no_factura = _no_factura;

		delete from deivid_web:web_endoso
			where no_poliza <> _no_poliza
			and num_factura = _no_factura
			and no_endoso = _no_endoso;
	end foreach

	let _contador = _contador + 1;

	if _contador >= 3000 then
	  	exit foreach;
  	end if

  end foreach

		

end

return 0, "Actualizacion Exitosa";

end procedure
