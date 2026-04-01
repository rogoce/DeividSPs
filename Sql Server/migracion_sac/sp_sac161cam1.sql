-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac161cam1;		

create procedure "informix".sp_sac161cam1()
returning integer, 
          char(100);
		  	
define _no_registro		char(10);
define _contador		smallint;
define _tipo_registro	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _no_poliza       char(10);
define _no_remesa       char(10);
define _no_tranrec      char(10);
define _renglon         integer;

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

let _contador = 0;

-- produccion
{
foreach

	select no_poliza
	  into _no_poliza
	  from camrea
	 group by no_poliza
	 order by no_poliza

	foreach
		
		 select r.no_registro,
		        r.tipo_registro
		   into _no_registro,
		        _tipo_registro
		   from sac999:reacomp r
		  where r.no_poliza     = _no_poliza
		    and r.tipo_registro = 1


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

end foreach	  }

-- cobros

foreach

	select no_remesa,
	       renglon
	  into _no_remesa,
	       _renglon
	  from camcobreaco
--  group by no_remesa
  order by no_remesa,renglon

  foreach

	 select r.no_registro,
	        r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r
	  where r.no_remesa     = _no_remesa
	    and r.renglon       = _renglon
	    and r.tipo_registro = 2

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

end foreach

--reclamos
{ 
foreach

	select no_tranrec
	  into _no_tranrec
	  from camrecreaco
	 where no_tranrec is not null
  group by no_tranrec
  order by no_tranrec

  foreach

	 select r.no_registro,
	        r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r
	  where r.no_tranrec    = _no_tranrec
	    and r.tipo_registro = 3

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

end foreach	 

--devolucion

foreach

	 select no_poliza
	   into _no_poliza
	   from camchqreaco
   order by no_poliza

   foreach

     select r.no_registro,
            r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r
	  where r.no_poliza     = _no_poliza
	    and r.tipo_registro in(4,5)

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

end foreach	 }

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
