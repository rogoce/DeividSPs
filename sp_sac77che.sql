-- Procedure que elimina un comprobante de produccion

drop procedure sp_sac77che;
create procedure sp_sac77che(a_notrx integer)
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

define _periodo_verif char(7);
define _periodo       char(7);

define _cgl			integer;

let _res_cia = "001";

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _res_origen = null;

select periodo_verifica
  into _periodo_verif
  from emirepar;
  
-- Agregar lo del CGL

{let _cgl = 0;

select count(*)
  into _cgl
   from sac:cglresumen 
  where res_notrx = a_notrx
    and res_origen = 'CGL';
	
if _cgl is null then
	let _cgl = 0;
end if	

if _cgl > 0 then
	return 1, "Hay registros con origen CGL, Verifique";
end if

foreach
 select res_origen
   into _res_origen
   from sac:cglresumen 
  where res_notrx = a_notrx
	exit foreach;
end foreach

if _res_origen is null then
	return 1, "No Existe Origen de Comprobante";
end if
}
let _res_origen = 'CHE';

if _res_origen = "REC" then

	foreach
	 select no_tranrec,
	        periodo
	   into _no_tranrec,
	        _periodo
	   from recasien
	  where sac_notrx = a_notrx
	  group by 1, 2
		
	 if _periodo < _periodo_verif then	
		return 1, "Asiento con periodo cerrado";
	 end if
		
		update rectrmae
		   set sac_asientos = 0
		 where no_tranrec   = _no_tranrec;

	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_notrx = a_notrx

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen where res_notrx  = a_notrx;

	update recasien
	   set sac_notrx = null,
	       periodo   = null
	 where sac_notrx = a_notrx;

elif _res_origen = "COB" then

	foreach
	 select no_remesa,
	        renglon,
			periodo
	   into _no_remesa,
	        _renglon,
			_periodo
	   from cobasien
	  where sac_notrx = a_notrx
	  group by 1, 2, 3
	  
	 if _periodo < _periodo_verif then	
		return 1, "Asiento con periodo cerrado";
	 end if	  
		
		update cobredet
		   set sac_asientos = 0
		 where no_remesa    = _no_remesa
		   and renglon      = _renglon;

	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_notrx = a_notrx

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen where res_notrx  = a_notrx;

	update cobasien
	   set sac_notrx = null,
	       periodo   = null
	 where sac_notrx = a_notrx;

elif _res_origen = "PRO" then

	foreach
	 select no_poliza,
	        no_endoso,
			periodo
	   into _no_poliza,
	        _no_endoso,
			_periodo
	   from endasien
	  where sac_notrx = a_notrx
	  group by 1, 2, 3
	  
	 if _periodo < _periodo_verif then	
		return 1, "Asiento con periodo cerrado";
	 end if	  
		
		update endedmae
		   set sac_asientos = 0
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_notrx = a_notrx

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen where res_notrx  = a_notrx;

	update endasien
	   set sac_notrx = null,
	       periodo   = null
	 where sac_notrx = a_notrx;

elif _res_origen = "REA" then

	foreach
	 select no_registro,
	        periodo
	   into _no_poliza,
	        _periodo
	   from sac999:reacompasie
	  where sac_notrx = a_notrx
	  group by 1, 2

	 if _periodo < _periodo_verif then	
		return 1, "Asiento con periodo cerrado";
	 end if
		
		update sac999:reacomp
		   set sac_asientos = 0
		 where no_registro  = _no_poliza;

	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_notrx = a_notrx
	    and res_origen = _res_origen

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen where res_notrx  = a_notrx and res_origen = _res_origen;

	update sac999:reacompasie
	   set sac_notrx = null
	 where sac_notrx = a_notrx;

elif _res_origen in("CHE","PLA") then

	foreach
	 select no_requis,
	        tipo,
			periodo
	   into _no_remesa,
	        _renglon,
			_periodo
	   from chqchcta
	  where sac_notrx = a_notrx
	  group by 1, 2, 3

	 if _periodo < _periodo_verif then	
		return 1, "Asiento con periodo cerrado";
	 end if
		
		if _renglon = 1 then

			update chqchmae
			   set sac_asientos = 0
			 where no_requis    = _no_remesa;

		else

			update chqchmae
			   set sac_anulados = 0
			 where no_requis    = _no_remesa;

		end if
	end foreach

	foreach
	 select res_noregistro	
	   into _noregistro
	   from cglresumen
	  where	res_notrx = a_notrx
	    and res_origen = _res_origen

		delete from sac:cglresumen1 
		 where res1_noregistro = _noregistro;

		delete from sac999:ef_cglresumen
		 where res_noregistro = _noregistro
		   and res_cia_comp   = _res_cia;

		delete from sac999:ef_cglresumen1
		 where res1_noregistro = _noregistro
		   and res1_cia_comp   = _res_cia;

	end foreach

	delete from sac:cglresumen where res_notrx  = a_notrx and res_origen = _res_origen;

	update chqchcta
	   set sac_notrx = null,
	       periodo   = null
	 where sac_notrx = a_notrx;
end if

end

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure 

