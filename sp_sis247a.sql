-- Funcion que Obtiene los Codigos de un String y los Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sis247a;
create procedure "informix".sp_sis247a() 
returning char(1);

define _cod_modelo		char(5);
define _grupo           char(4);
define _tipo_auto		char(3);
define _anio		integer;    
define _porcentaje	integer;    

--drop table if exists tmp_codigos;

foreach
	select grupo,
		   anio,
		   porcentaje
	  into _grupo,
		   _anio,
		   _porcentaje		   
	  from deivid_tmp:tmp_act_trf2024

	update emivecla1
	   set porc_desc = _porcentaje
	 where cod_grupo = _cod_modelo
	   and ano = _anio;
end foreach
return 0;
end procedure;