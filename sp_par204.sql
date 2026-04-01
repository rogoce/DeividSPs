drop procedure "informix".sp_par204;

create procedure "informix".sp_par204()
returning char(10),
          char(10),
          char(20),
          smallint;

define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_documento	char(20);
define _renglon			smallint;
define _cantidad		smallint;

foreach	
 select no_poliza,
        no_documento
   into _no_poliza,
        _no_documento
   from emipomae
  where actualizado  = 1
    and cod_tipoprod = "001"

	select count(*)
	  into _cantidad
	  from endasien
	 where no_poliza = _no_poliza;
	 
	 if _cantidad = 0 then
	 	continue foreach;
	 end if| 	

	foreach
	 select no_remesa,
	        renglon
	   into _no_remesa,
	        _renglon
	   from cobredet
	  where no_poliza = _no_poliza
	    and comis_desc = 1

		return _no_poliza, 
	           _no_remesa,
			   _no_documento,
			   _renglon
			   with resume;

	end foreach

end foreach

end procedure