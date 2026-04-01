-- Porcedure que determina la cantidad de tiempo entre 2 fechas

-- Creado:	19/09/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_bo036;
create procedure sp_bo036(
a_fecha_desde datetime year to minute,
a_fecha_hasta datetime year to minute
) returning dec(16,2);

define _tiempo_usado   	interval day(4) to minute;
define _tiempo_char		char(11);
define _dias_usados		dec(16,2);
define _hora_usados		dec(16,2);
define _minu_usados		dec(16,2);
define _temp_usados		dec(16,2);
define _tiempo_total	dec(16,2);

let _tiempo_usado = (a_fecha_hasta - a_fecha_desde);
let _tiempo_char  = _tiempo_usado;

let _dias_usados  = _tiempo_char[1,5];
let _hora_usados  = _tiempo_char[7,8];
let _minu_usados  = _tiempo_char[10,11];

let _temp_usados  = _dias_usados * 24; -- Dias a horas
let _hora_usados  = _hora_usados + _temp_usados;
let _temp_usados  = _hora_usados * 60; -- Horas a minutos
let _minu_usados  = _minu_usados + _temp_usados;
let _tiempo_total = _minu_usados;

return _tiempo_total;

end procedure
