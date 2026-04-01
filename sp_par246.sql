drop procedure sp_par246;

create procedure "informix".sp_par246()
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);

define _cantidad		integer;

set isolation to dirty read;

let _cantidad = 0;

foreach
 select poliza
   into _no_documento
   from deivid_tmp:comest

	foreach
	 select no_poliza
	   into _no_poliza
	   from emipomae
	  where no_documento = _no_documento

		update emipoagt
		   set porc_comis_agt = 0
	     where no_poliza     = _no_poliza
	       and cod_agente    = "00085";

		
		let _cantidad = _cantidad + 1;

	end foreach

end foreach

return _cantidad, "Actualizacion Exitosa";

end procedure