drop procedure sp_sis68;

create procedure "informix".sp_sis68()
returning char(20),
          char(10),
		  smallint;

define _no_documento	char(20);
define _no_poliza		char(10);
define _cantidad		smallint;

foreach
 select poliza
   into _no_documento
   from incobrable2004

	let _no_poliza = sp_sis21(_no_documento);
	
	select count(*)
	  into _cantidad
	  from emipomae
	 where no_poliza = _no_poliza;

--{
	update emipomae
	   set incobrable = 1
	 where no_poliza  = _no_poliza;
--}

	return _no_documento,
	       _no_poliza,
		   _cantidad
		   with resume;

end foreach

end procedure
