drop procedure sp_par159;

create procedure "informix".sp_par159()

define _cod_agente	char(10);

foreach
 select cod_agente
   into _cod_agente
   from gisela

	update agtagent
	   set cod_cobrador = "007"
	 where cod_agente = _cod_agente;

end foreach

end procedure