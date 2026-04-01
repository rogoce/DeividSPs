-- Procedure que elimina un comprobante de produccion

drop procedure sp_sac77bk;
create procedure sp_sac77bk(a_notrx integer)
returning integer,
          char(50);


define _res_origen	char(3);
define _res_cia		char(3);

define _no_remesa	char(10);
define _renglon 	smallint;

define _no_poliza	char(10);
define _no_endoso	char(5);

define _no_tranrec	char(10);

define _noregistro	integer;


define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

let _res_cia = "001";

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _res_origen = null;



	foreach
	 select no_registro
	   into _no_poliza
	   from sac999:reacompasie
	  where sac_notrx = a_notrx
	  group by 1
		
		update sac999:reacomp
		   set sac_asientos = 0
		 where no_registro  = _no_poliza;

	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_comprobante = 'REA031910'
        and res_origen = 'REA'
	    and res_notrx  = a_notrx

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen 
	where res_comprobante = 'REA031910'
      and res_origen = 'REA'
      and res_notrx  = a_notrx;

	update sac999:reacompasie
	   set sac_notrx = null
	 where sac_notrx = a_notrx;

end
commit work;

return 0, "Actualizacion Exitosa";

end procedure 

