-- Procedimiento para buscar el valor del Recargo
-- Creado    : 27/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe70;
create procedure sp_proe70(a_no_poliza char(10))
returning	dec(16,2);

define _no_unidad		char(5);
define _porc_recargo	dec(10,4);
define _recargo_dep		dec(16,2);		
define _recargo_ac		dec(16,2);
define _descuento		dec(16,2);
define _prima_dep		dec(16,2);
define _recargo			dec(16,2);
define _prima_uni,_prima_uni_au		dec(16,2);

begin

set isolation to dirty read;

-- set debug file to "sp_proe70.trc";
-- trace on;

let _recargo_dep	= 0.00;
let _recargo_ac		= 0.00;
let _recargo		= 0.00;
let _porc_recargo	= 0.00;
let _prima_uni_au   = 0.00;

foreach
	select u.no_unidad,
		   u.prima_total
	  into _no_unidad,
		   _prima_uni		   		   
	  from emipouni u
	 where u.no_poliza	= a_no_poliza
	   and u.activo		= 1

	let _prima_uni_au = _prima_uni;
	let _recargo      = 0.00;
	
	foreach
		select r.porc_recargo
		  into _porc_recargo	   		   
		  from emiunire r
		 where r.no_poliza = a_no_poliza
		   and r.no_unidad = _no_unidad
	 
		if _porc_recargo is null then
			let _porc_recargo = 0.00;
		end if
		let _recargo = _recargo + _prima_uni_au * (_porc_recargo / 100);
		let _prima_uni_au = _prima_uni_au + _recargo;
	end foreach	
	
	let _prima_dep   = 0.00;
	let _recargo_dep = 0.00;
	call sp_proe54(a_no_poliza, _no_unidad) returning _prima_dep;
	call sp_proe53(a_no_poliza, _no_unidad) returning _recargo_dep;
	let _prima_uni	= _prima_uni - _prima_dep;
	let _descuento	= sp_proe71a(a_no_poliza,_no_unidad);
	let _prima_uni	= (_prima_uni - _descuento);
	let _recargo_ac = _recargo_ac + _recargo + _recargo_dep;	
end foreach
return _recargo_ac;
end
end procedure
	   
	
	 
	

	