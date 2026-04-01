-- Procedure que elimina los registros de pruebas de las cotizaciones web

-- Creado    : 16/09/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro313;

create procedure sp_pro313()
returning smallint,
          char(50);

define _no_factura		char(10);
define _no_documento	char(20);
define _cantidad		smallint;

let _cantidad = 0;

foreach
 select no_factura,
        no_documento
   into _no_factura,
        _no_documento
   from endedhis
  where no_factura like "09%"

	let _cantidad = _cantidad + 1;

	delete from endedhis
	 where no_factura = _no_factura;

	delete from emipoliza
	 where no_documento = _no_documento;

end foreach

return _cantidad, "Procesados con Exito";

end procedure