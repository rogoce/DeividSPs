-- Procedimiento para crear la carta de aviso de formulario conoce a tu cliente
-- Creado    : 11/05/2010 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro995;
CREATE PROCEDURE "informix".sp_pro995() 
RETURNING   CHAR(50);

DEFINE _n_agente        VARCHAR(50); 
DEFINE _cod_agente      char(5);
SET ISOLATION TO DIRTY READ;


foreach

	SELECT cod_agente   
	  INTO _cod_agente
	  FROM agtcarta

	SELECT nombre   
	  INTO _n_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;


	RETURN _n_agente with resume;

end foreach

END PROCEDURE			   