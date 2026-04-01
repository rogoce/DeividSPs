-- Trae la descripcion de los cheques de reclamos pagados 2 veces

drop procedure sp_rec254;

create procedure sp_rec254(a_transaccion char(10))
returning char(50);

define _no_requis		char(10);
define _periodo		char(7);
define _descripcion	char(100);

let _descripcion = "Se pago 2 Veces: ";

foreach
 select m.no_requis,
         m.periodo
   into _no_requis,
        _periodo
   from chqchrec r, chqchmae m
  where r.no_requis 	= m.no_requis
    and pagado 		= 1
    and anulado		= 0
    and transaccion 	= a_transaccion

	let _descripcion = trim(_descripcion) || " " || trim(_no_requis) || " " || trim(_periodo) || ","; 
	
end foreach

return _descripcion;

end procedure

