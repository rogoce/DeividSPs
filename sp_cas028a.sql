-- procedimiento que unifica las polizas de un pagador

-- creado    : 10/08/2011 - autor: Roman Gordon C.
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cas028;


create procedure sp_cas028(a_no_documento	char(20),a_cod_cliente	char(10))
 returning	integer,
          	char(100);

define _cantidad	smallint;
define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);
define _cliente_ant	char(10);
define _no_poliza	char(10);

--SET DEBUG FILE TO "sp_cas028.trc"; 
--trace on;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception

SET ISOLATION TO DIRTY READ;

select count(*)
  into _cantidad
  from cascliente
 where cod_cliente = a_cod_cliente;

let _no_poliza = sp_sis21(a_no_documento);
if _cantidad = 0 then

	update emipomae 
	   set cod_pagador	= a_cod_cliente 
	 where no_poliza 	= _no_poliza;
	return 0, "Actualizacion Exitosa ...";

end if

select count(*)
  into _cantidad
  from caspoliza
 where no_documento = a_no_documento;



if _cantidad = 0 then

   	update emipomae
	   set cod_pagador = a_cod_cliente
     where no_poliza   = _no_poliza;
	
else
	foreach
		select cod_cliente
		  into _cliente_ant
		  from caspoliza
		 where no_documento =  a_no_documento
		exit foreach;
	end foreach

	update caspoliza
	   set cod_cliente  = a_cod_cliente
	 where no_documento =  a_no_documento;

	select count(*)
	  into _cantidad
	  from caspoliza
	 where cod_cliente = _cliente_ant;

	if _cantidad = 0 then

		delete from cascliente
		 where cod_cliente = _cliente_ant;

	end if

end if

return 0, "Actualizacion Exitosa ...";

end procedure                                                 
