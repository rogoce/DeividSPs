

drop procedure sp_par254;

create procedure sp_par254()
returning char(20),
          smallint;

define _poliza		char(20);
define _cantidad	smallint;

foreach 
 select poliza
   into _poliza 
   from deivid_tmp:psc0709

	select count(*)
	  into _cantidad
	  from emipomae
	 where no_documento = _poliza;

	if _cantidad is null then
		let _cantidad = 0;
	end if

		return _poliza,
		       _cantidad
		       with resume;

end foreach

return "", 0;

end procedure