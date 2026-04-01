-- Despliega GENPAIS
-- Creado    : 07/08/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par369;

CREATE PROCEDURE sp_par369() RETURNING CHAR(20),char(3);

DEFINE _nombre		CHAR(20);
define _cod_pais    char(3);

SET ISOLATION TO DIRTY READ;

LET _nombre = NULL;
let _cod_pais = null;


FOREACH
	 SELECT nombre[1,20],code_pais
       into _nombre,_cod_pais		 
       FROM genpais
	   order by nombre
	 return _nombre,_cod_pais with resume;
END FOREACH

END PROCEDURE;