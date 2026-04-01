-- Actualizar la vigencia original de polizas en los endosos

DROP PROCEDURE sp_par20;

CREATE PROCEDURE "informix".sp_par20()

define _no_poliza	    char(10);
define _no_endoso       char(5);
define _vigencia_inic	date;
define _vigencia_final  date;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where vigencia_inic_pol is null

	select vigencia_inic,
	       vigencia_final
	  into _vigencia_inic,
	       _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	update endedmae
	   set vigencia_inic_pol  = _vigencia_inic,
	       vigencia_final_pol = _vigencia_final
	 where no_poliza          = _no_poliza
	   and no_endoso          = _no_endoso;

end foreach

END PROCEDURE;
