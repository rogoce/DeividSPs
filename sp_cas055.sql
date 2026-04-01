
--drop procedure sp_cas055;

create procedure "informix".sp_cas055(a_cod_pagador char(10))

define _cod_cliente	char(10);
define _cod_cobrador_ant char(3);
define _cod_cobrador char(3);

set isolation to dirty read;

{let _cod_cobrador = "069";

foreach
 select cod_cliente
   into _cod_cliente
   from cascliente
  where cod_cobrador = "046"

	let _cod_cobrador = sp_cas006("001", 1);

	update cascliente
	   set cod_cobrador     = _cod_cobrador
	 where cod_cliente      = _cod_cliente;

--		   cod_cobrador_ant = null

	update cobcapen
	   set cod_cobrador = _cod_cobrador
     where cod_cliente  = _cod_cliente;

end foreach

{foreach
 select cod_cliente
   into _cod_cliente
   from cascliente
  where cod_cobrador_ant = "031"

 let _cod_cobrador = sp_cas006("001", 12);

	update cascliente
	   set cod_cobrador_ant = _cod_cobrador
	 where cod_cobrador_ant = "025";
end foreach}


	let _cod_cobrador = sp_cas006("001", 1);

	update cascliente
	   set cod_cobrador     = _cod_cobrador
	 where cod_cliente      = a_cod_pagador;

--		   cod_cobrador_ant = null

	update cobcapen
	   set cod_cobrador = _cod_cobrador
     where cod_cliente  = a_cod_pagador;


end procedure;

