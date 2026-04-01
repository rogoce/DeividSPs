-- Funcion que Obtiene los Codigos de un String y los Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sis04d;
create procedure 'informix'.sp_sis04d(a_string varchar(255)) 
returning char(1);

define _cadena		varchar(50);      
define _char_1		char(1);
define _tipo		char(1);
define _len_string	smallint;  
define _ancho_char	smallint;  
define _indice		smallint;  
define _pos			smallint;  
define _contador	integer;    

drop table if exists tmp_codigos;

create temp table tmp_codigos(
indice			smallint,
pos				smallint,
ancho_cadena	smallint,
primary key (indice)) with no log;

let _len_string = length(a_string);
let _indice = 0;
let _pos = 1;
let _cadena   = '';

for _contador = 1 to _len_string

	let _char_1   = a_string[1, 1];
	let a_string  = a_string[2, 255];

	if _char_1 in (';',',' ) then
		let _ancho_char = _contador - _pos;
		let _indice = _indice + 1;
		
		insert into tmp_codigos(indice,pos,ancho_cadena)
		values(_indice,_pos,_ancho_char);

		if _char_1 = ';' then
			exit for;
		end if
		let _pos = _contador + 1;
	end if
end for

return _char_1;
end procedure;