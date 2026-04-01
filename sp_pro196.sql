-- Retorna Nombre del corredor

-- Creado    : 29/10/2010 - Autor: Armando Moreno
-- Modificado: 29/10/2010 - Autor: Armando Moreno


DROP PROCEDURE sp_pro196;

CREATE PROCEDURE sp_pro196()
RETURNING CHAR(5),   
          VARCHAR(50);

DEFINE _cod_agente     CHAR(5);  
DEFINE _n_agente       VARCHAR(50); 

SET ISOLATION TO DIRTY READ;


FOREACH
	SELECT cod_agente,    
	       nombre
	  INTO _cod_agente,
		   _n_agente
	  FROM agtagent
  ORDER BY nombre

	
	RETURN _cod_agente, _n_agente WITH RESUME;
	
END FOREACH

END PROCEDURE;


