-- 

drop procedure sp_bo037;

create procedure sp_bo037()
returning char(20),
          char(10),
		  char(10);

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_poliza2		char(10);

foreach
 select no_documento,
        no_poliza
   into _no_documento,
        _no_poliza
   from cobmoros
  where periodo = "2006-08"

	select no_poliza
	  into _no_poliza2
	  from emipomae
	 where no_poliza = _no_poliza;

	if _no_poliza2 is null then

		let _no_poliza2 = sp_sis21(_no_documento);

		return _no_documento,
		       _no_poliza,
			   _no_poliza2
			   with resume;
		
	end if

end foreach

end procedure