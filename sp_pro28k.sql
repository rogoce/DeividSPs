-- Buscar en emirepol, para saber si se ha renovado la poliza, si es asi se debe eliminar de emirepol. 
-- Creado    : 25/08/2008 - Autor: Armando Moreno

drop procedure sp_pro28k;

create procedure sp_pro28k()
 returning	integer,char(80);

define _no_poliza       char(10);
define _cant			integer;
define _fecha           date;
define _renovada        smallint;

set isolation to dirty read;

let _fecha = today;
let _cant = 0;

foreach

 select no_poliza
   into _no_poliza
   from emirepol

 select renovada
   into _renovada
   from emipomae
  where no_poliza   = _no_poliza
    and actualizado = 1;

 if _renovada = 1 then

	  delete from emirepol
	  where no_poliza = _no_poliza;

	  let _cant = _cant + 1;
 end if

end foreach

return 0, _cant || " polizas borradas de emirepol, debido a que en emipomae aparece como renovada";

end procedure
