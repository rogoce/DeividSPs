-- Procedimiento que elimina el impuesto de las facturas del minsa
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro507;		

create procedure "informix".sp_pro507()
returning integer,
		  char(100);

define _no_poliza	char(10);
define _no_endoso	char(5);

foreach
 select no_poliza
   into _no_poliza
   from emipomae
  where no_documento in ("0110-00471-01", 
  						 "0210-01288-01", 
  						 "0410-00129-01", 
  						 "0410-00130-01", 
  						 "0410-00149-01", 
  						 "0510-00037-01", 
                         "0510-00038-01", 
                         "0510-00039-01", 
                         "0610-00279-01", 
                         "0710-00002-01", 
                         "1010-00027-01",
                         "1110-00011-01", 
                         "1610-00299-01", 
                         "1610-00300-01", 
                         "1710-00018-01")

	delete from emipolim
	 where no_poliza = _no_poliza;

	update emipomae
	   set tiene_impuesto = 0,
	       impuesto       = 0,
		   prima_bruta    = prima_neta
	 where no_poliza      = _no_poliza;

	foreach
	 select no_endoso
	   into _no_endoso
	   from endedmae
	  where no_poliza = _no_poliza

		delete from endedimp
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		
		update endedmae
		   set tiene_impuesto = 0,
		       impuesto       = 0,
		       prima_bruta    = prima_neta
		 where no_poliza      = _no_poliza
		   and no_endoso      = _no_endoso;

		update endeduni
		   set impuesto       = 0,
		       prima_bruta    = prima_neta
		 where no_poliza      = _no_poliza
		   and no_endoso      = _no_endoso;

		update endedhis
		   set tiene_impuesto = 0,
		       impuesto       = 0,
		       prima_bruta    = prima_neta
		 where no_poliza      = _no_poliza
		   and no_endoso      = _no_endoso;

	end foreach

end foreach

return 0, "Actualizacion Exitosa";

end procedure