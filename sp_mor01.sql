-- Elimina los registros de la estructura del call center, cuando le cambian la forma de pago ANCON
--
-- Creado    : 27/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_mor01;

create procedure "informix".sp_mor01()
returning smallint;

define _cod_pagador		char(10);
define _cantidad		smallint;
define _error			smallint;
define a_no_doc         char(20);

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception


foreach

	select no_documento
	  into a_no_doc
	  from b

	update emipomae
	   set cod_formapag = '089'
	 where no_documento = a_no_doc;

	update endedmae
	   set cod_formapag = '089'
	 where no_documento = a_no_doc;


	select	cod_cliente
	  into	_cod_pagador
	  from	caspoliza
	 where	no_documento = a_no_doc;

	select	count(*)
	  into	_cantidad
	  from	caspoliza
	 where	cod_cliente = _cod_pagador;

	if _cantidad = 1 then

		delete from caspoliza
		 where cod_cliente = _cod_pagador;

		delete from cascliente
		 where cod_cliente = _cod_pagador;

		delete from cobcapen
		 where cod_cliente = _cod_pagador;
	elif _cantidad > 1 then
		delete from caspoliza
		 where no_documento = a_no_doc;
	end if

end foreach

end
return 0;

end procedure
