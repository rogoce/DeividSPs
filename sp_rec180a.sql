--Buscar solo los bloques que tienen asignaciones en mora y estan pendientes.
--Armando Moreno M. 23/05/2018

--DROP PROCEDURE sp_rec180a;
CREATE PROCEDURE "informix".sp_rec180a()
RETURNING	CHAR(10);

DEFINE _cod_entrada	CHAR(10);

SET ISOLATION TO DIRTY READ;

FOREACH
 select distinct cod_entrada
   into _cod_entrada 
   from atcdocde 
  where en_mora    = '1' 
    and completado = '0'
	
	return _cod_entrada with resume;
END FOREACH;
END PROCEDURE
