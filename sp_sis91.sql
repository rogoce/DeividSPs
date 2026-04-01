-- Procedure que verifica si una fecha es correcta y la arregla

create procedure sp_sis91(a_fecha date)
returning integer,
	      date,
          char(50);

define _fecha_char	char(10);
define _ano_char2	char(2);
define _ano_char4	char(4);
define _fecha		date;

if a_fecha < "01/01/1950" then

	let _fecha_char = a_fecha;
	let _ano_char2  = _fecha_char[9,10];	

	if _ano_char2 < "10" then
		let _ano_char4 = "20" || _ano_char2;
	else
		let _ano_char4 = "19" || _ano_char2;
	end if					

	let _fecha = mdy(month(a_fecha), day(a_fecha), _ano_char4);
	
	return 1, _fecha, "Fecha Corregida";

elif 		
end if

return 0, a_fecha, "Fecha Correcta";

end procedure