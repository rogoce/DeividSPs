drop procedure sp_par100;

create procedure "informix".sp_par100()
returning smallint,
          char(20),
          date,
		  char(7),
		  char(7);

define _fecha_reclamo	date;
define _periodo			char(7);
define _periodo2		char(7);
define _numrecla		char(20);
define _user_added		char(8);
define _no_reclamo		char(10);

set isolation to dirty read;

foreach
 select no_reclamo,
        periodo
   into _no_reclamo,
        _periodo
   from rectrmae
  where actualizado = 1
    and cod_tipotran = "001"

	select periodo,
	       numrecla,
		   fecha_reclamo
	  into _periodo2,
	       _numrecla,
		   _fecha_reclamo
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	if _periodo2 > _periodo then

{
		update recrcmae
		   set periodo    = _periodo
		 where no_reclamo = _no_reclamo;
--}

		return 1,
			   _numrecla,
		       _fecha_reclamo,
		       _periodo,
			   _periodo2
			   with resume;

	end if

end foreach

return 0,
	   "",
       null,
       "",
	   ""
	   with resume;

end procedure