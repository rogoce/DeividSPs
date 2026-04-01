-- pruebas

-- Creado    : 12/07/2004 - Autor: Armando Moreno M.

drop procedure sp_cas065e;

create procedure sp_cas065e()
returning smallint;

define _cant          smallint;
define _no_poliza     char(10);
define _cobra_poliza  char(1);

let _cant = 0;
set isolation to dirty read;

   foreach
	select no_poliza
	  into _no_poliza
	  from cobaviso
	 where cobra_poliza is null

	select cobra_poliza
	  into _cobra_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	update cobaviso
	   set cobra_poliza = _cobra_poliza
	 where no_poliza    = _no_poliza;

	let _cant = _cant + 1;  

   end foreach

   RETURN _cant;

end procedure