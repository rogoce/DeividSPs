-- Procedure que determina el codigo del Auxiliar del Mayor dependiendo del origen

-- Creado    : 17/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis89;

create procedure "informix".sp_sis89(
a_tipo		smallint default 999,
a_codigo	char(10) default null
) returning char(5);

define _cod_auxiliar char(5);

if a_tipo = 1 then -- Coaseguro

	select cod_auxiliar
	  into _cod_auxiliar
	  from emicoase
	 where cod_coasegur = a_codigo;

elif a_tipo = 2 then -- Agentes

	let _cod_auxiliar = "A" || a_codigo[2,5];

elif a_tipo = 999 then -- No Definido

	let _cod_auxiliar = a_codigo;
	 
end if

return _cod_auxiliar;

end procedure