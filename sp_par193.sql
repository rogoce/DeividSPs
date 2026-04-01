-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por el Sr. Chamorro
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par193;

create procedure "informix".sp_par193()

define _no_factura		char(10);
define _no_documento	char(20);
define _no_poliza		char(10);

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

foreach
 select no_factura,
        poliza
   into _no_factura,
        _no_documento
   from cobinc0512_2
  where no_factura is not null

	update endedmae
	   set periodo    = "2005-12"
	 where no_factura = _no_factura;

	update endedhis
	   set periodo    = "2005-12"
	 where no_factura = _no_factura;

{
	let _no_poliza = sp_sis21(_no_documento);

	UPDATE emipomae
	   SET cod_no_renov   = null,
		   fecha_no_renov = null,
		   user_no_renov  = null,
		   no_renovar     = 0
	 WHERE no_poliza      = _no_poliza;
}

end foreach

end procedure