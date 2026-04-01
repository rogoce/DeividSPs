-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por el Sr. Chamorro
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par185;

create procedure "informix".sp_par185()
returning integer,
          char(50);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);

define _error			integer;
define _descripcion		char(50);
define _cantidad		integer;
define _cod_tipoprod	char(3);

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

let _cantidad = 0;
 
foreach
 select poliza
   into _no_documento
   from cobinc0612b

	let _cantidad    = _cantidad + 1;
	let _no_poliza   = sp_sis21(_no_documento);
	let _prima_bruta = sp_cob174(_no_documento);

{
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
}

	update cobinc0612b
	   set saldo_deivid = _prima_bruta
	 where poliza       = _no_documento;

end foreach

return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 

end procedure