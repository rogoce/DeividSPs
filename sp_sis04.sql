-- Funcion que Obtiene los Codigos de un String y los Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sis04;
create procedure "informix".sp_sis04(a_string char(255)) 
returning char(1);

define _codigo           char(25);      
define _char_1           char(1);
define _tipo             char(1);
define _contador         integer;    

--drop table if exists tmp_codigos;

create temp table tmp_codigos(
codigo	char(25)  not null,
primary key (codigo)) with no log;

let _codigo   = "";
for _contador = 1 to 255

	let _char_1   = a_string[1, 1];
	let a_string  = a_string[2, 255];

	if _char_1 = ";" then

		insert into tmp_codigos(codigo)
		values(_codigo);

		let _char_1   = a_string[1, 1];
		exit for;
	else
		if _char_1 = "," then
			insert into tmp_codigos(codigo)
			values(_codigo);

			let _codigo = "";
		else
			let _codigo = trim(_codigo) || trim(_char_1);
		end if
	end if
end for

return _char_1;
end procedure;