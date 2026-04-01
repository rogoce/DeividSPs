drop procedure sp_sis63;

create procedure "informix".sp_sis63()

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_tipoprod	char(3);

set isolation to dirty read;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and cod_tipoprod is null

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	update endedmae
	   set cod_tipoprod = _cod_tipoprod
	 where no_poliza    = _no_poliza
	   and no_endoso    = _no_endoso;

end foreach

end procedure