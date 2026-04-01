-- filtro para el drop down dw de gestiones(CallCenter)
-- Creado    : 26/08/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas59;
create procedure "informix".sp_cas59(
a_rol			smallint,
a_camp_anula	smallint default 0)
returning	char(3),
			char(50);

define _sus_gest_automatic	char(3); 
define _gestion_super		char(3); 
define _cod_gestion			char(3); 
define _nombre				char(50);
define _tipo_contacto		smallint;
define _de_investigador		smallint;
define _de_electronico		smallint;
define _de_supervisor		smallint;
define _de_ejecutiva		smallint;
define _de_gestor			smallint;
define _return				smallint;
define _grupo				smallint;

set isolation to dirty read;

--drop table if exists tmp_tipo_accion;

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

if a_rol = 13 then
	let a_rol = 8;
end if

let _gestion_super = '013'; --Pasar al Supervisor

select valor_parametro
  into _sus_gest_automatic
  from inspaag
 where codigo_parametro = 'sus_gest_automatic';

foreach
	select cod_gestion,
		   nombre,
		   tipo_contacto,
		   grupo,
		   de_gestor,
		   de_ejecutiva,
		   de_supervisor,
		   de_investigador,
		   de_electronico
	  into _cod_gestion,
		   _nombre,
		   _tipo_contacto,
		   _grupo,
		   _de_gestor,
		   _de_ejecutiva,
		   _de_supervisor,
		   _de_investigador,
		   _de_electronico
	  from cobcages
	 where tipo_accion in (select tipo_accion from tmp_tipo_accion)
	    or cod_gestion in (_sus_gest_automatic,_gestion_super)
	 order by nombre,tipo_contacto,cod_gestion

	let _return = 0;

	if a_rol in (1,11,12) and _de_gestor = 1 then	--gestor
		let _return = 1;
	elif a_rol = 6 and (_de_gestor = 1 or _de_ejecutiva = 1) then	--incobrable
		let _return = 1;
	elif a_rol in (8,9) and _de_supervisor = 1 then --supervisor
		let _return = 1;
	elif a_rol = 7 and _de_investigador = 1 then --investigador
		let _return = 1;
	elif a_rol in (5,13,10) and _de_ejecutiva = 1 then --ejecutiva
		let _return = 1;
	elif a_rol = 4 and _de_electronico = 1 then --electronico
		let _return = 1;
	end if

	if _return = 1 then
		return _cod_gestion,
	           _nombre with resume;
	end if
end foreach

--drop table if exists tmp_tipo_accion;
drop table tmp_tipo_accion;
end procedure;