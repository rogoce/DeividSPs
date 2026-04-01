drop procedure sp_bo025;

create procedure sp_bo025()
returning char(20),
          dec(16,2);

define _no_reclamo	char(10);
define _deducible	dec(16,2);
define _numrecla	char(20);
define _no_poliza	CHAR(10);
define _cod_ramo	char(3);

foreach
 select no_reclamo
   into _no_reclamo
   from rectrmae
  where cod_compania matches "*"
    and actualizado  = 1
    and cod_tipotran matches "*"
    and periodo[1,4] = 2006
  group by no_reclamo
  order by no_reclamo

	select numrecla,
               no_poliza
	  into _numrecla,
               _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
          into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select sum(deducible)
	  into _deducible
	  from recrccob
	 where no_reclamo = _no_reclamo;
	
	if _cod_ramo <> "002" then
		continue foreach;
	end if

	return _numrecla,
	       _deducible
	       with resume;		

end foreach

end procedure