--drop procedure sp_cas056;

create procedure "informix".sp_cas056()

define _cod_cliente	char(10);

set isolation to dirty read;

foreach
 select cod_cliente
   into _cod_cliente
   from cascliente
  where cod_cobrador = "025"

	update cobcapen
	   set cod_cobrador = "025"
     where cod_cliente  = _cod_cliente;

end foreach

end procedure;
