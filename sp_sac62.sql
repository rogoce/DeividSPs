-- Procedure que determina la fecha de actualizacion en el mayor para el proceso de SAC Online Diario

-- Creado    : 25/04/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_sac62;

create procedure sp_sac62(a_periodo char(7))
returning date;

define _fecha_hoy	date;
define _fecha_act	date;
define _periodo_hoy	char(7);

let _fecha_hoy   = current;
let _periodo_hoy = sp_sis39(_fecha_hoy);

if a_periodo = _periodo_hoy then

	let _fecha_act = _fecha_hoy;

elif a_periodo < _periodo_hoy then

	let _fecha_act = sp_sis36(a_periodo);
	
elif a_periodo > _periodo_hoy then

	let _fecha_act = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

end if

return _fecha_act;

end procedure