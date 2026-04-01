-- Procedimiento que determina a que dia corresponde la facturacion
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis156;		

create procedure "informix".sp_sis156(
a_fecha_emis  	date,
a_periodo		char(7)
) returning date;

define _fecha	date;

let _fecha = sp_sis36(a_periodo);

if a_fecha_emis <= _fecha then
	let _fecha = a_fecha_emis;
end if

return _fecha;

end procedure