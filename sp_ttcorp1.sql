--- Actualizar los codigos de subramos provenientes de la tabla de Oracle DET_MOVIM_TECNICO_SIN
--- Creado 26/08/2014 por Armando Moreno

--drop procedure sp_ttcorp1;

create procedure "informix".sp_ttcorp1()
returning integer;

begin


define _cod_subramo     char(3);
define _no_poliza       char(10);
define _id_poliza       char(20);



--SET DEBUG FILE TO "sp_sis419.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;


foreach

	select distinct id_poliza
	  into _id_poliza
	  from deivid_ttcorp:tmp_sin_subramo
	 order by id_poliza

    let _no_poliza = sp_sis21(_id_poliza);

	select cod_subramo
	  into _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	update deivid_ttcorp:tmp_sin_subramo 
	   set cod_subramo = _cod_subramo
	 where id_poliza = _id_poliza;


end foreach

end 
return 0;

end procedure;
