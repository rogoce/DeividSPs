-- Conversion de la tabla de CAJS

drop procedure sp_par172;

create procedure "informix".sp_par172()

define _numero			integer;
define _fecha			char(20);
define _cedula			char(30);
define _nombre			char(255);
define _apellido		char(255);

define _fecha_deivid	date;
define _cedula_deivid	char(30);
define _nombre_deivid	char(100);
define _edad_deivid		integer;

foreach
 select numero,
       	fecha,
       	cedula,
		nombre,
		apellido
   into _numero,
        _fecha,
        _cedula,
		_nombre,
		_apellido
   from cajs

	let _nombre_deivid = trim(_nombre) || " " || trim(_apellido);

	if _fecha is not null then
		let _fecha_deivid = sp_par173(_fecha);
	else
		let _fecha_deivid = null;
	end if

	let _edad_deivid   = sp_sis78(_fecha_deivid, "01/02/2006");
	let _cedula_deivid = sp_par175(_cedula);

	update cajs
	   set fecha_deivid  = _fecha_deivid,
	       cedula_deivid = _cedula_deivid,
		   nombre_deivid = _nombre_deivid,
		   edad_deivid	 = _edad_deivid
	 where numero        = _numero;
 
end foreach          		

end procedure
