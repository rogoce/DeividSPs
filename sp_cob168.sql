-- Extraer datos de la tabla chqbanco para crear archivos txt. para el transit.(cobros moviles)
-- 
-- Creado    : 23/09/2004 - Autor: Armando Moreno M.
-- Modificado: 23/09/2004 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_cob168;

CREATE PROCEDURE "informix".sp_cob168()

DEFINE _cod_banco CHAR(3);
DEFINE _nombre	  CHAR(50);
DEFINE _campo	  CHAR(53);

DELETE FROM cobcmbm; --motivos

--lectura de motivos
FOREACH
	SELECT cod_banco,
		   nombre
	  INTO _cod_banco,
		   _nombre
	  FROM chqbanco

  	LET _campo = _cod_banco || _nombre;

  	INSERT INTO cobcmbm
  	VALUES (_campo);

END FOREACH
END PROCEDURE