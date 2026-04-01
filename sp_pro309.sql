-- Porcedure que retorna los ultimos 10 anos

-- Creado    : 22/05/2008 - Autor: Demetrio Hurtado

drop procedure sp_pro309;  

create procedure sp_pro309()
returning char(4);

define _ano		char(4);
define _i		smallint;
define _inicio	smallint;

let _inicio = year(today);
let _inicio = _inicio + 1;
for _i = 1 to 25 

	let _ano    = _inicio;
	let _inicio = _inicio - 1;	

	return _ano
		   with resume;

end for

end procedure
