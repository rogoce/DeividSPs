
drop procedure sp_rec182;

create procedure sp_rec182()
returning date,
          date;

define _fecha1	date;
define _fecha2	date;
define _dia		smallint;

for _dia = 1 to 31

	let _fecha1 = mdy(5, _dia, 2011);
	let _fecha2 = _fecha1 - 1 units month;

	return _fecha1, _fecha2 with resume;

end for

end procedure