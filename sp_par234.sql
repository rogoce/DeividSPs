-- Procedimiento que genera las cancelaciones por saldo por lote
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par234;

create procedure sp_par234() 
returning integer,
          char(50);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _descripcion		char(50);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _saldo			dec(16,2);
define _no_factura		char(10);
define _no_poliza		char(10);
define _no_documento	char(20);

foreach
 select poliza
   into _no_documento
   from cobinc0612b
  where cancelada = 1
    and no_factura is null


	update endedmae
	   set prima_neta  = _prima_neta,
		   impuesto    = _impuesto,
		   prima_bruta = _prima_bruta
	 where no_factura  = _no_factura;

	update endedhis
	   set prima_neta  = _prima_neta,
		   impuesto    = _impuesto,
		   prima_bruta = _prima_bruta
	 where no_factura  = _no_factura;

end foreach

return 0, "Actualizacion Exitosa";

end procedure