-- Procedimiento para buscar el valor del Recargo
-- Creado    : 27/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe71a;
create procedure "informix".sp_proe71a(a_no_poliza char(10), a_no_unidad char(5))
returning	dec(16,2); -- ld_descuento

define _no_unidad		char(5);
define _porc_descuento	dec(10,4);
define _descuento_ac	dec(16,2);
define _descuento		dec(16,2);
define _prima_uni		dec(16,2);

begin

set isolation to dirty read;

-- set debug file to "\\sp_proe71.trc";
-- trace on;

let _descuento_ac = 0.00;
let _descuento	= 0.00;

foreach
	select d.no_unidad,
		   sum(d.porc_descuento),
		   sum(u.prima_total)
	  into _no_unidad,
		   _porc_descuento,
		   _prima_uni		   		   
	  from emipouni u,emiunide d
	 where u.no_poliza	= d.no_poliza
	   and u.no_unidad	= d.no_unidad
	   and u.no_poliza	= a_no_poliza
	   and u.no_unidad	= a_no_unidad
	   and u.activo		= 1
	 group by d.no_poliza,d.no_unidad 
	
	let _descuento	= _prima_uni * (_porc_descuento / 100);
	let _descuento_ac = _descuento_ac + _descuento;	
end foreach
return _descuento_ac;
end
end procedure
	   
	
	 
	

	