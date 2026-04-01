--creado por Armando Moreno
--09/09/2003***traer reg de gestiones 009 y 014 de cobcapen y que sean del investigardor
--que esta ejecutando el proceso de mandar mail.

drop procedure sp_cas66;

create procedure "informix".sp_cas66(a_cia char(3),a_suc char(3), a_cod_cobrador char(3))
returning char(10);

define _cod_cliente	char(10);

set isolation to dirty read;

foreach
	select p.cod_cliente
	   into _cod_cliente
	   from cobcapen p, cascliente c
	  where p.cod_cliente = c.cod_cliente
	    and c.cod_gestion in ("009", "014")

 return _cod_cliente
   with resume;
	
end foreach

end procedure;

