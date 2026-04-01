-- buscar firma electronica

-- Modificado: 20/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_rec76b;

create procedure "informix".sp_rec76b(a_firma char(1), a_monto DEC(16,2) DEFAULT 0.00)
returning  char(20);	--firma

define _usuario			char(8);
define _cantidad		smallint;
define _orden			integer;
define _windows_user	char(20);

SET ISOLATION TO DIRTY READ;

if a_firma = "*" then

	if a_monto < 1000 then
		select count(*)
		  into _cantidad
		  from wf_firmas
		 where activo     = 1
		   and marcado    = 0
		   and tipo_firma in ("A", "B")
		   and windows_user <> "WESPINOZA";
	else
		select count(*)
		  into _cantidad
		  from wf_firmas
		 where activo     = 1
		   and marcado    = 0
		   and tipo_firma in ("A", "B");
	end if

else

	select count(*)
	  into _cantidad
	  from wf_firmas
	 where activo     = 1
	   and marcado    = 0
	   and tipo_firma = a_firma;

end if

if _cantidad = 0 then		--desmarcarlos todos

    set lock mode to wait;

	if a_firma = "*" then

		update wf_firmas
		   set marcado    = 0
		 where tipo_firma in ("A", "B");

	else

		update wf_firmas
		   set marcado    = 0
		 where tipo_firma = a_firma;

	end if

    set isolation to dirty read;

end if

if a_firma = "*" then

	if a_monto < 1000 then
		foreach
			select usuario,
			       orden
			  into _usuario,
			       _orden
			  from wf_firmas
			 where activo     = 1
			   and marcado    = 0
			   and tipo_firma in ("A", "B")
			   and windows_user <> "WESPINOZA" --> Para excluir al Sr Wilson de los cheques < 1000
			 order by orden desc

            set lock mode to wait;

			update wf_firmas
			   set marcado    = 1
			 where usuario    = _usuario;
	--		   and tipo_firma = a_firma;

    		set isolation to dirty read;

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
			   and marcado    = 0
			   and tipo_firma in ("A", "B")
			 order by orden desc

            set lock mode to wait;

			update wf_firmas
			   set marcado    = 1
			 where usuario    = _usuario;
	--		   and tipo_firma = a_firma;

    		set isolation to dirty read;

			select windows_user
			  into _windows_user
			  from segv05:insuser
			 where usuario = _usuario;

		   exit foreach;

		end foreach
	end if
else

	foreach
		select usuario,
		       orden
		  into _usuario,
		       _orden
		  from wf_firmas
		 where activo     = 1
		   and marcado    = 0
		   and tipo_firma = a_firma
		 order by orden desc

        set lock mode to wait;

		update wf_firmas
		  set marcado    = 1
		 where usuario   = _usuario;
--		  and tipo_firma = a_firma;

    	set isolation to dirty read;
	
		select windows_user
		  into _windows_user
		  from segv05:insuser
		 where usuario = _usuario;

	   exit foreach;

	end foreach

end if

return trim(_usuario);

end procedure