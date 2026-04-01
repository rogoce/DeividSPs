-- Procedimiento que genera las cancelaciones por saldo por lote
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par232;

create procedure sp_par232() 
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

foreach
 select saldo,
        no_factura
   into _saldo,
        _no_factura
   from cobinc0612
--  where no_factura = "02-24324"

	select prima_bruta,
		   tiene_impuesto,
		   no_poliza,
		   no_endoso
	  into _prima_bruta, 
		   _tiene_impuesto,
		   _no_poliza,
		   _no_endoso
	  from endedmae
	 where no_factura = _no_factura;

	let _prima_bruta = _prima_bruta * -1;

	if _saldo = _prima_bruta then
		continue foreach;
	end if

	let _prima_bruta = _saldo * -1;

	if _tiene_impuesto = 1 then

		Let _suma_impuesto = 0.00;

		Foreach	
		 Select cod_impuesto
		   Into _cod_impuesto
		   From endedimp
		  Where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			Select factor_impuesto
			  Into _factor_impuesto
			  From prdimpue
			 Where cod_impuesto = _cod_impuesto;
				    
			Let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);

		End Foreach

		let _prima_neta = _prima_bruta / (1 + _suma_impuesto);

	else

		let _prima_neta = _prima_bruta;

	end if

	let _impuesto = _prima_bruta - _prima_neta;

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