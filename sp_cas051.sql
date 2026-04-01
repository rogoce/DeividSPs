-- actualizar codigo cobrador 036 a reg tabla cascliente provenientes de reg de cobcatmp3.
-- dia_cobros3 en cero y cod_cobrador_ant en null. borrar el pagador de cobcapen.
-- Creado    : 11/08/2003 - Autor: Armando Moreno M.
-- Modificado: 11/08/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas051;

create procedure sp_cas051()
returning char(10);

define _no_documento char(20);
define _cod_pagador  char(10);
define _cod_cobrador char(3);
define _cant		 int;

set isolation to dirty read;

foreach with hold
 select cod_pagador
   into _cod_pagador
   from cobcatmp3

let _cant = 0;

 select count(*)
   into _cant
   from cascliente
  where cod_cliente = _cod_pagador;

 if _cant = 0 then
	return _cod_pagador with resume;
 end if

 {update cascliente
    set dia_cobros3 = 0,
	    cod_cobrador = "036",
		cod_cobrador_ant = null
  where cod_cliente = _cod_pagador;

 delete
   from cobcapen
  where cod_cliente = _cod_pagador;}
		
end foreach

end procedure
