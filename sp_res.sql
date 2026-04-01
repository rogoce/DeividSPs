--Creado 29/04/2010 por Armando Moreno



drop procedure sp_res;

create procedure sp_res()
 returning char(20),char(10),char(18),char(10),char(7),dec(16,2),dec(16,2),dec(16,2);

define _no_reclamo			char(10);
define _no_poliza			char(10);
define _no_documento		char(20);
define _reserva_inicial		dec(16,2);
define _reserva_actual		dec(16,2);
define _reserva_actual_sal  dec(16,2);
define _numrecla            char(18);
define _periodo             char(7);
define _error     	    	integer; 

--SET DEBUG FILE TO "sp_res.trc";  
--TRACE ON;                                                                 

foreach

	select no_reclamo,
	       numrecla,
		   periodo,
		   no_documento,
		   no_poliza,
		   reserva_actual
	  into _no_reclamo,
	       _numrecla,
		   _periodo,
		   _no_documento,
		   _no_poliza,
		   _reserva_actual_sal
	  from recrcmae
	 where actualizado = 1
	   and estatus_reclamo = 'C'

	select sum(reserva_inicial),
	       sum(reserva_actual)
	  into _reserva_inicial,
		   _reserva_actual
	  from recrccob
	 where no_reclamo = _no_reclamo;

	if _reserva_actual is null then

		let _reserva_actual = 0;

	end if 

	if _reserva_actual = 0 then

		continue foreach;

	end if

	if _numrecla[1,2] = "18" and _reserva_actual_sal = 0 then

		continue foreach;

	end if


   RETURN  _no_documento,
		   _no_poliza,
		   _numrecla,
		   _no_reclamo,
		   _periodo,
		   _reserva_inicial,
		   _reserva_actual,
		   _reserva_actual_sal

       WITH RESUME;


end foreach

end procedure