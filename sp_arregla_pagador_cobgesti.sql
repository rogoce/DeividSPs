-- Retorna la Gestion de un Pagador o de Una Poliza
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_arregla_pagador_cobgesti;

create procedure sp_arregla_pagador_cobgesti()
returning smallint,
		  char(20);

define _no_documento  	char(20);
define _fecha_gestion 	datetime year to second;
define _descripcion   	char(512);
define _no_poliza	  	char(10);
define _cod_gestion	  	char(3);
define _cod_pagador		char(10);
define _cont			smallint;

set isolation to dirty read;

--set debug file to "sp_arregla_pagador_cobgesti.trc";
--trace on;

foreach 
	select distinct no_poliza
	  into _no_poliza
	  from cobgesti
	 where cod_pagador is null

	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	update cobgesti
	   set cod_pagador	= _cod_pagador
	 where no_poliza	= _no_poliza;

end foreach
end procedure
