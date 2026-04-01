
drop procedure sp_aprueba;

create procedure "informix".sp_aprueba()
returning char(10),char(10);

begin

define _no_poliza   	char(10);
define _no_endoso    	char(10);
define _cnt             integer;

--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

foreach

	select no_poliza,
	       no_endoso
	  into _no_poliza,
	       _no_endoso
	  from asientos

		SELECT count(*)
	      INTO _cnt
		  FROM temp_det
		 WHERE seleccionado = 1
		   and no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		
		if _cnt is null then
			let _cnt = 0;
		end if
		   
		if _cnt > 0 then
			continue foreach;
		end if
		
		return _no_poliza,_no_endoso with resume;

end foreach
end 

end procedure;
