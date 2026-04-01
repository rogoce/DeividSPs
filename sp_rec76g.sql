-- buscar firma electronica

-- Modificado: 26/08/2009 - Autor: Amado Perez Mendoza

drop procedure sp_rec76g;

create procedure "informix".sp_rec76g(a_default smallint default 1)
returning  char(20);	--firma

define _usuario			char(20);
define _cantidad		smallint;
define _orden			integer;
define _windows_user	char(20);

--SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT;

--SET DEBUG FILE TO "sp_rec76g.trc";
--TRACE ON;

let _usuario = '';


if a_default <> 1 then

	select count(*)
	  into _cantidad
	  from wf_firmas
	 where de_salud      = 1
	   and salud_default <> 0
       and activo        = 1;

	if _cantidad = 1 then
		select usuario,
		       windows_user
		  into _usuario,
		       _windows_user
		  from wf_firmas
		 where salud_default = 1;

	elif _cantidad = 0 then

		let _usuario = sp_rec76b("B",0.00);

		select windows_user
		  into _windows_user
		  from wf_firmas
		 where usuario = _usuario;

	else

		select count(*)
		  into _cantidad
		  from wf_firmas
		 where de_salud      = 1
		   and marc_salud    = 0
		   and salud_default <> 0;

		if _cantidad = 0 then		--desmarcarlos todos
			update wf_firmas
			   set marc_salud = 0
			 where de_salud   = 1
			   and salud_default <> 0;
		end if

		foreach	with hold
			select usuario,
			       orden_salud,
				   windows_user
			  into _usuario,
			       _orden,
				   _windows_user
			  from wf_firmas
			 where marc_salud = 0
			   and de_salud   = 1
			   and salud_default <> 0
			 order by orden_salud desc

			update wf_firmas
			   set marc_salud = 1
			 where usuario    = _usuario;

		   exit foreach;

		end foreach
	end if
else
	select usuario,
	       windows_user
	  into _usuario,
	       _windows_user
	  from wf_firmas
	 where salud_default = 1
       and activo        = 1;

	if _usuario is null or trim(_usuario) = '' then

		let _usuario = sp_rec76b("B",0.00);

		select windows_user
		  into _windows_user
		  from wf_firmas
		 where usuario = _usuario;

	end if

end if

if _usuario is null or trim(_usuario) = '' then

	select count(*)
	  into _cantidad
	  from wf_firmas
	 where activo        = 1
	   and de_salud      = 1
	   and marc_salud    = 0;

	if _cantidad = 0 then		--desmarcarlos todos

		update wf_firmas
		   set marc_salud = 0
		 where de_salud   = 1
		   and activo     = 1;

	end if

   foreach with hold
	select usuario,
	       orden_salud,
		   windows_user
	  into _usuario,
	       _orden,
		   _windows_user
	  from wf_firmas
	 where activo     = 1
	   and marc_salud = 0
	   and de_salud   = 1
	 order by orden_salud desc

	if _usuario is not null and trim(_usuario) <> '' then
		update wf_firmas
		   set marc_salud = 1
		 where usuario    = _usuario;
		exit foreach;
	end if
   end foreach

end if


return trim(_windows_user);

end procedure