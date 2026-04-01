-- Funcion que Obtiene los Codigos de un String y los Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sis247;
create procedure "informix".sp_sis247() 
returning char(1);

define _cod_modelo		char(5);
define _grupo           char(4);
define _tipo_auto		char(3);
define _tamano			integer;    
define _cod_tipoauto	integer;    

--drop table if exists tmp_codigos;

foreach
	select cod_modelo,
		   cod_tipoauto,
		   cod_tamano,
		   grupo
	  into _cod_modelo,
		   _cod_tipoauto,
		   _tamano,
		   _grupo
	  from deivid_tmp:tmp_act_mdl2024

	let _tipo_auto = '000';
	if _cod_tipoauto > 99 then
		let _tipo_auto = _cod_tipoauto;
	elif _cod_tipoauto > 9 then
		let _tipo_auto[2,3] = _cod_tipoauto;
	else
		let _tipo_auto[3,3] = _cod_tipoauto;
	end if

	update emimodel
	   set grupo = _grupo,
		   tamano = _tamano,
		   cod_tipoauto = _tipo_auto
	 where cod_modelo = _cod_modelo;
end foreach
return 0;
end procedure;