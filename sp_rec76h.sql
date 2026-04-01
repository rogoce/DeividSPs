-- buscar firma electronica	especial de salud descentralizacion

-- Modificado: 20/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_rec76h;

create procedure "informix".sp_rec76h(a_firma char(1))
returning  char(20);	--firma

define _usuario			char(8);
define _cantidad		smallint;
define _orden			integer;
define _windows_user	char(20);

SET LOCK MODE TO WAIT;

if a_firma = "*" then

	select count(*)
	  into _cantidad
	  from wf_firmas
	 where activo     = 1
	   and marc_salud = 0
	   and de_salud   = 1
	   and salud_default = 0
	   and tipo_firma in ("A", "B");

else

	select count(*)
	  into _cantidad
	  from wf_firmas
	 where activo     = 1
	   and marc_salud = 0
	   and de_salud   = 1
	   and salud_default = 0
	   and tipo_firma = a_firma;

end if

if _cantidad = 0 then		--desmarcarlos todos

	if a_firma = "*" then

		update wf_firmas
		   set marc_salud    = 0
		 where tipo_firma in ("A", "B")
	       and de_salud   = 1
	       and salud_default = 0;

	else

		update wf_firmas
		   set marc_salud    = 0
		 where tipo_firma = a_firma
	       and de_salud   = 1
	       and salud_default = 0;

	end if

end if

if a_firma = "*" then

	foreach
		select usuario,
		       orden
		  into _usuario,
		       _orden
		  from wf_firmas
		 where activo     = 1
		   and marc_salud = 0
		   and tipo_firma in ("A", "B")
		   and de_salud   = 1
		   and salud_default = 0
		 order by orden desc

		update wf_firmas
		   set marc_salud = 1
		 where usuario    = _usuario;
--		   and tipo_firma = a_firma;

		select windows_user
		  into _windows_user
		  from segv05:insuser
		 where usuario = _usuario;

	   exit foreach;

	end foreach

else

	foreach
		select usuario,
		       orden
		  into _usuario,
		       _orden
		  from wf_firmas
		 where activo     = 1
		   and marc_salud = 0
		   and tipo_firma = a_firma
		   and de_salud   = 1
		   and salud_default = 0
		 order by orden desc

		update wf_firmas
		   set marc_salud = 1
		 where usuario   = _usuario
		  and tipo_firma = a_firma;

		select windows_user
		  into _windows_user
		  from segv05:insuser
		 where usuario = _usuario;

	   exit foreach;

	end foreach

end if

return trim(_usuario);

end procedure