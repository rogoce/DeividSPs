-- buscar firma electronica

-- Creado: 08/03/2019 - Autor: Amado Perez M

drop procedure sp_yos04;

create procedure "informix".sp_yos04(a_firma char(1), a_monto decimal(16,2), a_min_aut_salud dec(16,2) DEFAULT 0.00, a_firma1 CHAR(20) DEFAULT "")
returning  char(8);	--firma

define _usuario			char(8);
define _cantidad		smallint;
define _orden			integer;
define _windows_user	char(20);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec76i.trc";      
--TRACE ON;                                                                     

let a_monto = a_monto; 
let a_firma1 = a_firma1;
 
if a_min_aut_salud <> 0.00 then
		select usuario
		  into _usuario
		  from wf_firmas
		 where salud_default = 1
	       and activo        = 1;

		if _usuario is null or trim(_usuario) = '' then
			foreach
				select usuario
				  into _usuario
				  from wf_firmas
				 where activo     = 1
				   and tipo_firma = a_firma
				   and windows_user <> a_firma1
				   and windows_user in ('WESPINOZA','ZAROSEMENA') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				--   and windows_user in ('MDEFRANCO','OWONG') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				 order by orden

		       -- set lock mode to wait;

				update wf_firmas
				   set orden      = orden + 1
				 where usuario    = _usuario;

			   exit foreach;

			end foreach
		end if
 else
	if a_firma = "*" then
		if a_monto < 1000 then
			foreach
				select usuario
				  into _usuario
				  from wf_firmas
				 where activo     = 1
				   and tipo_firma in ("A", "B")
				   and windows_user <> "ASAENZ" --> Para excluir los cheques < 1000
				   and windows_user <> a_firma1
				   and windows_user in ('WESPINOZA','ZAROSEMENA') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				--   and windows_user in ('MDEFRANCO','OWONG') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				 order by orden

	        --    set lock mode to wait;

				update wf_firmas
				   set orden      = orden + 1
				 where usuario    = _usuario;

			   exit foreach;

			end foreach
		else
			foreach
				select usuario
				  into _usuario
				  from wf_firmas
				 where activo     = 1
				   and tipo_firma in ("A", "B")
				   and windows_user <> a_firma1
				   and windows_user in ('WESPINOZA','ZAROSEMENA') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				--   and windows_user in ('MDEFRANCO','OWONG') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				 order by orden

	       --     set lock mode to wait;

				update wf_firmas
				   set orden      = orden + 1
				 where usuario    = _usuario;

			   exit foreach;

			end foreach
		end if
	else

		foreach
			select usuario
			  into _usuario
			  from wf_firmas
			 where activo     = 1
			   and tipo_firma = a_firma
			   and windows_user <> a_firma1
				   and windows_user in ('WESPINOZA','ZAROSEMENA') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
				--   and windows_user in ('MDEFRANCO','OWONG') -- OBARRIO PRUEBA REAL 'LMORENO','OWONG',
			 order by orden

	   --     set lock mode to wait;

			update wf_firmas
			   set orden      = orden + 1
			 where usuario    = _usuario;

		   exit foreach;

		end foreach

	end if
end if

--SET ISOLATION TO DIRTY READ;

return trim(_usuario);

end procedure