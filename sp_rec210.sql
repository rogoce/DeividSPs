-- Procedure que actualiza el tamano de los modelos

-- Creado    : 03/07/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec210;

create procedure "informix".sp_rec210() 
returning smallint,
          char(50);

define _tmp_modelo	char(5);
define _tmp_tamano	char(3);

define _tamano		smallint;
 
set isolation to dirty read;

foreach
 select modelo,
        tamano
   into _tmp_modelo,
        _tmp_tamano
   from deivid_tmp:tmp_modelos

	if _tmp_tamano = "Gra" then

		let _tamano = 3;

	elif _tmp_tamano = "Med" then

		let _tamano = 2;

	elif _tmp_tamano = "Peq" then

		let _tamano = 1;

	else
	
		let _tamano = 0;
		return 1, _tmp_modelo || " " || _tmp_tamano || " No Encontrado ";

	end if

	update emimodel
	   set tamano     = _tamano
	 where cod_modelo = _tmp_modelo;

end foreach

return 0, "Actualizacion Exitosa";

end procedure