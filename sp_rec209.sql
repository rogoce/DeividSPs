-- Procedimiento que Retorna el nombre de los tipos de causas

-- Creado    : 04/07/2013 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_rec209;

create procedure "informix".sp_rec209(a_tipo_causa smallint) returning char(50);

define _nombre_causa	char(50);

if a_tipo_causa = 1 then

	let _nombre_causa = "Gastos Medicos";

elif a_tipo_causa = 2 then

	let _nombre_causa = "Legal";

elif a_tipo_causa = 3 then

	let _nombre_causa = "Perdida Total - Robo";

elif a_tipo_causa = 4 then

	let _nombre_causa = "Perdida Total - Colision";

elif a_tipo_causa = 5 then

	let _nombre_causa = "Perdida Total - Incendio";

elif a_tipo_causa = 6 then

	let _nombre_causa = "Perdida Parcial";

elif a_tipo_causa = 7 then

	let _nombre_causa = "Danos a Terceros - Lesiones Corporales";

elif a_tipo_causa = 8 then

	let _nombre_causa = "Danos a Terceros - Danos a Terceros";

elif a_tipo_causa = 9 then

	let _nombre_causa = "Perdida Total sin Cobertura";

end if

return _nombre_causa;
 
end procedure