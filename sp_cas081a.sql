-- Elimina los registros de la estructura del call center, cuando le cambian la forma de pago ANCON
--
-- Creado    : 27/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas081a;

create procedure "informix".sp_cas081a(a_no_doc char(20),a_cod_pagador char(10))
returning smallint;

define _cantidad		smallint;
define _cantidad2		smallint;
define _error			smallint;

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

let _cantidad  = 0;
let _cantidad2 = 0;

select count(*)
  into _cantidad
  from caspoliza
 where cod_cliente = a_cod_pagador;

select count(*)
  into _cantidad2
  from caspoliza
 where no_documento = a_no_doc;

if _cantidad = 1 and _cantidad2 = 1 then

	delete from caspoliza
	 where cod_cliente = a_cod_pagador;

	delete from cascliente
	 where cod_cliente = a_cod_pagador;

	delete from cobcapen
	 where cod_cliente = a_cod_pagador;

elif _cantidad > 1 then

	delete from caspoliza
	 where no_documento = a_no_doc
	   and cod_cliente  = a_cod_pagador;

end if

end
return 0;

end procedure
