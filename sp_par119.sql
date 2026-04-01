-- Procedimiento que verifica los cambios de corredor para los registros contables
-- 
-- Creado    : 25/11/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par119;		

Create Procedure "informix".sp_par119(a_periodo CHAR(7))
returning char(10),
          date;

define _no_poliza		char(10);
define _no_poliza_end	char(10);
define _no_endoso_end	char(10);
define _no_factura		char(10);
define _fecha_emision	date;
define _cod_ramo		char(3);

foreach
 select no_poliza
   into _no_poliza
   from endedmae
  where periodo     = a_periodo
    and actualizado = 1
  group by no_poliza

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "018" then
		continue foreach;
	end if

	foreach
	 select no_poliza,
	        no_endoso,
			no_factura,
			fecha_emision
	   into _no_poliza_end,
	        _no_endoso_end,
			_no_factura,
			_fecha_emision
	   from endedmae
	  where no_poliza   = _no_poliza
	    and actualizado = 1
		and periodo     >= a_periodo
		and cod_endomov = "012"

		return _no_factura,
		       _fecha_emision
			   with resume;

	end foreach

end foreach

end procedure
