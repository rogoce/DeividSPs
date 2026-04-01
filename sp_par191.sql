-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por el Sr. Chamorro
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par191;

create procedure "informix".sp_par191()
returning integer,
          char(50);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_factura		char(10);

define _error			integer;
define _descripcion		char(50);
define _cantidad		integer;

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

begin work;

let _cantidad = 0;
 
foreach
 select poliza,
        saldo_deivid
   into _no_documento,
        _prima_bruta
   from coloncxc
  where cancelada    = 0  

	let _cantidad    = _cantidad + 1;
	let _no_poliza   = sp_sis21(_no_documento);

	call sp_par192(_no_poliza, "GERENCIA", _prima_bruta) returning _error, _descripcion, _no_endoso;

	if _error <> 0 then
		rollback work;
		return _error, _descripcion; 
	end if

	select no_factura
	  into _no_factura
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
				
	update coloncxc
	   set cancelada  = 1,
	       no_factura = _no_factura
	 where poliza     = _no_documento;

	if _cantidad > 300 then
		exit foreach;
	end if

end foreach

--rollback work;
commit work;

return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 

end procedure