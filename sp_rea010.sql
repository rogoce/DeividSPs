drop procedure sp_rea010;

create procedure sp_rea010()
returning char(10),
          char(10),
		  char(5),
		  dec(16,2),
		  dec(16,2);

define _no_registro	char(10);

define _no_poliza	char(10);
define _no_endoso	char(5);

define _por_pagar_rep	dec(16,2);
define _por_pagar_asi	dec(16,2);

foreach
 select no_poliza,
        no_endoso,
        sum(por_pagar)
   into _no_poliza,
        _no_endoso,
        _por_pagar_rep
   from	deivid_tmp:tmp_bouquet
  group by 1, 2

	select no_registro
	  into _no_registro
	  from sac999:reacomp
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select sum(debito + credito)
	  into _por_pagar_asi
	  from sac999:reacompasie
	 where no_registro = _no_registro
	   and cuenta      = "2550101";

	if _por_pagar_asi is null then
		let _por_pagar_asi = 0;
	end if

	let _por_pagar_asi = _por_pagar_asi * -1;

	if _por_pagar_asi <> _por_pagar_rep then

		return _no_registro,
		       _no_poliza,
			   _no_endoso,
			   _por_pagar_rep,
			   _por_pagar_asi
			   with resume;

	end if

end foreach

foreach
 select no_registro,
        sum(debito + credito)
   into _no_registro,
        _por_pagar_asi
   from sac999:reacompasie
  where cuenta  = "2550101"
    and periodo = "2010-01"
  group by 1

	let _por_pagar_asi = _por_pagar_asi * -1;

	select no_poliza,
		   no_endoso	
	  into _no_poliza,
		   _no_endoso
	  from sac999:reacomp
	 where no_registro = _no_registro;

	 select sum(por_pagar)
	   into _por_pagar_rep
	   from	deivid_tmp:tmp_bouquet
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso;

	if _por_pagar_rep is null then
		let _por_pagar_rep = 0;
	end if

	if _por_pagar_asi <> _por_pagar_rep then

		return _no_registro,
		       _no_poliza,
			   _no_endoso,
			   _por_pagar_rep,
			   _por_pagar_asi
			   with resume;

	end if

end foreach

return "0",
	   "",
	   "",
	   0,
	   0;

end procedure