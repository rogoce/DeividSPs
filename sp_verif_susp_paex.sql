-- Proceso que verifica si una solicitud tiene mas de 15 dias
-- Creado por :     Roman Gordon	09/02/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_verif_susp_paex;

Create Procedure "informix".sp_verif_susp_paex()
Returning	char(30),			--_doc_susp,
			dec(16,2),			--_monto_susp,
			date,				--_fecha_susp,
			char(10),			--_no_remesa
			smallint;			--_actualizado


define _nom_ejec        varchar(50);
Define _doc_susp		char(30);
Define _no_remesa		char(10);
Define _no_recibo		char(10);
Define _numero			char(10);
Define _monto_susp		dec(16,2);
Define _actualizado		smallint;
Define _fecha_susp		date;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_verif_susp_paex.trc";
--trace on;

foreach
	Select no_remesa_ancon,
		   numero	
	  into _no_remesa,
		   _numero	
	  from cobpaex0
	 where insertado_remesa = 1

	foreach
		select distinct no_recibo
		  into _no_recibo
		  from cobredet
		 where no_remesa	= _no_remesa
		   and tipo_mov		= 'E'
		   and actualizado	= 1

		foreach
			select doc_suspenso,
				   monto,
				   fecha,
				   actualizado
			  into _doc_susp,
			  	   _monto_susp,
			  	   _fecha_susp,
				   _actualizado
			  from cobsuspe
			 where doc_suspenso like trim(_no_recibo) || '%'
			   and date_added >= '01/01/2011' 
			
			{update cobsuspe
			   set actualizado = 1
			 where doc_suspenso = _doc_susp;	}
			   
			return _doc_susp,
				   _monto_susp,
				   _fecha_susp,
				   _no_remesa,
				   _actualizado
				   with resume;
		end foreach
	end foreach					
end foreach
end procedure
