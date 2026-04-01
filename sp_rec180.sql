DROP PROCEDURE sp_rec180;

CREATE PROCEDURE "informix".sp_rec180()
RETURNING	CHAR(10);

DEFINE _cod_entrada	CHAR(10);

SET ISOLATION TO DIRTY READ;

FOREACH
 select distinct cod_entrada
   into _cod_entrada 
   from atcdocde 
  where cod_entrada not in (select cod_entrada from atcdocde where en_mora='0'and completado='0')
    and mora='1' and completado='0'
	
	return _cod_entrada with resume;
END FOREACH;
END PROCEDURE
