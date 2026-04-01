--drop procedure sp_sis68a;

create procedure "informix".sp_sis68a()
returning smallint;

define _cod_pagador  	char(10);

foreach
	select cod_pagador
	  into  _cod_pagador
	  from cobruter2
	 where cod_cobrador = "045"
	   and dia_cobros1 = 8

	
	update cobruter1
	   set dia_cobros1 = 8
	 where cod_pagador = _cod_pagador;

	update cdmclientes
	   set prog = "S"
	 where id_cliente = _cod_pagador
	   and id_usuario = 45;

end foreach
return 0;
end procedure
