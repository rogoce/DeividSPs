-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv3;
create procedure sp_reainv3()
returning char(10), char(20),char(18),char(7);
		  	

define _no_poliza char(10);
define _no_documento char(20);
define _per_rec         char(7);
define _no_reclamo      char(10);
define _numrecla        char(18);

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _no_poliza = "";
foreach
	select no_poliza,no_documento
	  into _no_poliza,_no_documento
      from camrea2
	
    foreach	
		select no_reclamo,
			   periodo,
			   numrecla
		  into _no_reclamo,
			   _per_rec,
			   _numrecla
		  from recrcmae
		 where no_poliza = _no_poliza
		 
		return _no_poliza,_no_documento,_numrecla,_per_rec with resume;
	end foreach	
	 
end foreach
end 
end procedure;