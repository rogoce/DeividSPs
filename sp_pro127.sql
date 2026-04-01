drop procedure sp_pro127;

create procedure "informix".sp_pro127(a_periodo char(7))
returning date;

define _fecha	date;

let _fecha = mdy(a_periodo[6,7], 1, a_periodo[1,4]);

let _fecha = _fecha - 11 units month;

return _fecha;

end procedure