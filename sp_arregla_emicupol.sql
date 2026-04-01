-- Arreglar emicupol y endcuen
-- 
-- Creado    : 07/06/2012 - Autor: Armando Moreno
-- Modificado: 07/06/2012 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_arregla_emicupol;

create procedure sp_arregla_emicupol()
returning smallint,
		  char(20);

define _no_documento  	char(20);
define _suma_asegurada  decimal(16,2);
define _no_poliza	  	char(10);
define _no_unidad       char(5);
define _cod_ubica       char(3);

set isolation to dirty read;

--set debug file to "sp_arregla_pagador_cobgesti.trc";
--trace on;

foreach

    select no_documento
	  into _no_documento
	  from tmp_cumulo

	let _no_poliza = sp_sis21(_no_documento);

    foreach

		 select no_unidad,suma_asegurada
		   into _no_unidad,_suma_asegurada
		   from emipouni
		  where no_poliza = _no_poliza
	  
		foreach

		  	 select cod_ubica
			   into _cod_ubica
			   from emicupol
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad

			 update emicupol
			    set suma_incendio  = _suma_asegurada,
					suma_terremoto = _suma_asegurada
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

			 update endcuend
			    set suma_incendio  = _suma_asegurada,
					suma_terremoto = _suma_asegurada
			  where no_poliza      = _no_poliza
			    and no_endoso      = '00000'
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

		 
	   	end foreach
    
    end foreach
 
end foreach
return 0,'Actualizacion Terminada';
end procedure
