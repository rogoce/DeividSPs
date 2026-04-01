-- filtro para el drop down dw de gestiones(CallCenter)
-- Creado    : 26/08/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas59;
create procedure "informix".sp_cas59(
a_rol			smallint,
a_camp_anula	smallint default 0)
returning	char(3),
			char(50);

define _cod_gestion		char(3); 
define _nombre			char(50);
define _tipo_contacto	smallint;
define _grupo			smallint;

set isolation to dirty read;

drop table if exists tmp_tipo_accion;

select distinct tipo_accion
  from cobcages
  into temp tmp_tipo_accion;

if a_camp_anula = 3 then
	delete from tmp_tipo_accion
	 where tipo_accion not in (12,13);
else
	delete from tmp_tipo_accion
	 where tipo_accion in (12,13);
end if

{delete from tmp_tipo_accion
	 where tipo_accion in (12,13);}

if a_rol = 13 then
	let a_rol = 8;
end if
	 
if a_rol in (1,11,12) then	--gestor
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where de_gestor = 1
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
	           _nombre with resume;
	end foreach
elif a_rol = 6 then	--incobrable
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where (de_gestor    = 1 or de_ejecutiva = 1)
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
	           _nombre with resume;
	end foreach
elif a_rol in (8,9) then --supervisor
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where de_supervisor = 1
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
			   _nombre with resume;
	end foreach
elif a_rol = 7 then --investigador
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where de_investigador = 1
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
	           _nombre with resume;
	end foreach
elif a_rol = 5 or a_rol = 13 or a_rol = 10 then --ejecutiva
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where de_ejecutiva = 1
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
	           _nombre with resume;
	end foreach
elif a_rol = 4 then --electronico
	foreach	with hold
		select cod_gestion,
			   nombre,
			   tipo_contacto,
			   grupo
	      into _cod_gestion,
		       _nombre,
			   _tipo_contacto,
			   _grupo
		  from cobcages
	     where de_electronico = 1
		   and tipo_accion in (select tipo_accion from tmp_tipo_accion)
		 order by nombre,tipo_contacto,cod_gestion

	    return _cod_gestion,
	           _nombre with resume;
	end foreach
else
end if

drop table if exists tmp_tipo_accion;
end procedure;