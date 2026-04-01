drop procedure sp_par247;

create procedure "informix".sp_par247()
returning char(20),
          char(20),
		  char(10),
		  char(20),
		  char(10);

define _numrecla		char(20);
define _no_documento	char(20);
define _no_poliza		char(10);

define _no_documento2	char(20);
define _no_poliza2		char(10);

foreach
 select no_documento,
        no_poliza,
		numrecla
   into _no_documento,
        _no_poliza,
		_numrecla
   from recrcmae

	 select no_documento,
	        no_poliza
	   into _no_documento2,
	        _no_poliza2
	   from emipomae
	  where no_poliza = _no_poliza;
	
	if _no_documento <> _no_documento2 then

		return _numrecla,
		       _no_documento,
			   _no_poliza,
		       _no_documento2,
			   _no_poliza2
			   with resume;

	end if

end foreach

end procedure