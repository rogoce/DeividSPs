drop procedure sp_ren001;

create procedure sp_ren001()

define _no_poliza	char(10);

foreach
 select r.no_poliza
   into _no_poliza
   from emirepol r, emipomae p
  where r.no_poliza     = p.no_poliza
    and sucursal_origen = "002"
    and r.user_added    = "MARGARIT"

	update emirepol
	   set user_added = "EDUARDO"
	 where no_poliza  = _no_poliza;

end foreach

end procedure
