   --Procedimiento de verificacion
   --  Armando Moreno M. 21/04/2017
   
   DROP procedure sp_super09;
   CREATE procedure sp_super09()
   RETURNING char(20),CHAR(10),char(50),smallint;

   DEFINE _no_poliza     CHAR(10);
   DEFINE _poliza        CHAR(20);
   DEFINE _cod_agente	 CHAR(10);
   define _cnt           smallint;
   define _n_agente      char(50);
   
SET ISOLATION TO DIRTY READ;


foreach
	select poliza
	  into _poliza
	  from traspaso
     group by poliza
     order by 1

	let _no_poliza = sp_sis21(_poliza);
	
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		if _cod_agente <> '00035' then
			select count(*)
			  into _cnt
			  from emipoagt
			 where no_poliza = _no_poliza;
			select nombre into _n_agente from agtagent where cod_agente = _cod_agente; 
			return _poliza,_cod_agente,_n_agente, _cnt with resume;
		end if

	end foreach
end foreach

END PROCEDURE;