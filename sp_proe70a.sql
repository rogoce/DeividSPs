-- Procedimiento para buscar el valor del Recargo
-- Creado    : 27/02/2013 - Autor: Edgar E. Cano G.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe70;
create procedure "informix".sp_proe70(a_no_poliza char(10))
returning	dec(16,2); -- ld_descuento

define _no_unidad		char(5);
define _porc_recargo	dec(10,4);
define _recargo_ac		dec(16,2);
define _recargo			dec(16,2);
define _prima_uni		dec(16,2);

begin

set isolation to dirty read;

-- set debug file to "\\sp_proe70.trc";
-- trace on;

let _recargo_ac = 0.00;
let _recargo	= 0.00;

foreach
	select r.no_unidad,
		   sum(r.porc_recargo),
		   sum(u.prima_total)
	  into _no_unidad,
		   _porc_recargo,
		   _prima_uni		   		   
	  from emipouni u,emiunire r
	 where u.no_poliza	= r.no_poliza
	   and u.no_unidad	= r.no_unidad
	   and u.no_poliza	= a_no_poliza
	   and u.activo		= 1
	 group by r.no_unidad 
	
	let _recargo	= _prima_uni * (_porc_recargo / 100);
	let _recargo_ac = _recargo_ac + _recargo;	
end foreach
return _recargo_ac;
end
end procedure
	   
	
	 
	

	