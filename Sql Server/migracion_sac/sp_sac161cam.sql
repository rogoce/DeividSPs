-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac161cam;		

create procedure "informix".sp_sac161cam()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Validacion del periodo de reclamos

--call sp_rea054() returning _error, _error_desc;

{if _error <> 0 then 
	return _error, _error_desc;
end if}

--set debug file to "sp_sac161cam.trc";
--trace on;

return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion

foreach
 select r.no_registro,
         r.tipo_registro
   into _no_registro,
	    _tipo_registro
   from sac999:reacomp r, camrea c
  where r.no_poliza 		= c.no_poliza
    and r.tipo_registro 	= 1
   group by r.no_registro, r.tipo_registro
   order by r.no_registro

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

return 1, "Produccion " || current with resume;

-- cobros

foreach
	 select r.no_registro,
	        r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r, camcobreaco c
	  where r.no_poliza = c.no_poliza
        and r.no_remesa = c.no_remesa
	    and r.tipo_registro = 2
   group by r.no_registro,r.tipo_registro
   order by r.no_registro

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

return 1, "Cobros " || current with resume;

--reclamos

foreach

	 select r.no_registro,
	        r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r, camrecreaco c
	  where r.no_poliza  = c.no_poliza
        and r.no_tranrec = c.no_tranrec
	    and r.tipo_registro = 3
   group by r.no_registro,r.tipo_registro
   order by r.no_registro

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

return 1, "Reclamos " || current with resume;

--devolucion

foreach

     select r.no_registro,
            r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r, camrea c
	  where r.no_poliza = c.no_poliza
	    and r.tipo_registro in(4,5)
   group by r.no_registro,r.tipo_registro
   order by r.no_registro

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

return 1, "Cheques " || current with resume;

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
