

--DROP PROCEDURE sp_zule1;
CREATE PROCEDURE sp_zule1(a_cod_agente CHAR(10))
RETURNING CHAR(10),CHAR(20),CHAR(10),CHAR(50);

DEFINE _no_poliza		CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _cod_agente,_cod_agente1		char(10);
DEFINE _n_agente 		varchar(50);

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;

FOREACH
	select cod_agente,nombre
      into _cod_agente,_n_agente
	  from agtagent
	 where tipo_agente = 'O'

	foreach
		select no_poliza
		  into _no_poliza
		  from emipoagt
		 where cod_agente = _cod_agente

		foreach
			select cod_agente
			  into _cod_agente1
			  from endmoage
			 where no_poliza = _no_poliza
			 
			if _cod_agente1 = '01341' then
				select no_documento into _no_documento from emipomae
				 where no_poliza = _no_poliza;
				return _no_poliza,_no_documento,_cod_agente,_n_agente with resume;
			end if
			 
		end foreach	 
	end foreach

END FOREACH

END PROCEDURE;