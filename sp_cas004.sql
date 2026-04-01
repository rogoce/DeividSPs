-- Procedure que actualiza los codigos de pagador para las gestiones
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--

--drop procedure sp_cas004;

create procedure sp_cas004()
returning char(100);

define _no_poliza		char(10);
define _cod_pagador		char(10);
define _cantidad		integer;

let _cantidad = 0;

foreach
 select no_poliza
   into _no_poliza
   from cobgesti
  where cod_pagador is null

	let _cantidad = _cantidad + 1;

	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	update cobgesti
	   set cod_pagador = _cod_pagador
	 where no_poliza   = _no_poliza
	   and cod_pagador is null;

end foreach

return _cantidad || " Registros Procesados";

end procedure
