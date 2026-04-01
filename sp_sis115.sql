-- Funcion que Separa la cadena de datos segun el separador especificado
-- Inserta en una tabla temporal (tmp_datos)
-- Creado    : 10/12/2010 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sis115;

create procedure "informix".sp_sis115(a_string CHAR(512),a_separador CHAR(2)) 
returning char(1);

define _dato	         char(25);      
define _contador         integer;    
define _char_1           char(1);      
define _tipo             char(1);
define _inicio			 smallint;

create temp table tmp_datos(
		dato char(15)  not null,
		inicio smallint not null,
		primary key (inicio)
		) with no log;

let a_separador = trim(a_separador);
let _dato   	= "";
let _inicio 	= 0;
let a_string 	= trim(a_string) || '°';

for _contador = 1 to 512

	let _char_1   = a_string[1, 1];
	let a_string  = a_string[2, 512];

	if _char_1 = "°" then
		
		let _inicio = _inicio + 1;
		insert into tmp_datos(
			dato,
			inicio
			)
			values(
			_dato,
			_inicio
			);

		let _char_1   = a_string[1, 1];

		exit for;

	else

		if _char_1 = a_separador then

			let _inicio = _inicio + 1;
			insert into tmp_datos(
				dato,
				inicio
				)
				values(
				_dato,
				_inicio
				);
			let _dato = "";
		else
			let _dato = trim(_dato) || trim(_char_1);
		end if

	end if

end for

return _char_1;

end procedure;
