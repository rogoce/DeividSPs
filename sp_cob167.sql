-- Extraer datos de la tabla cobmotiv para crear archivos txt. para el transit.(cobros moviles)
-- 
-- Creado    : 23/09/2004 - Autor: Armando Moreno M.
-- Modificado: 23/09/2004 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.
--DROP PROCEDURE sp_cob167;

CREATE PROCEDURE "informix".sp_cob167()

DEFINE _cod_motiv CHAR(3);
DEFINE _nombre	  CHAR(50);
DEFINE _campo	  CHAR(53);

DELETE FROM cobcmim; --motivos

--lectura de motivos
{FOREACH
	SELECT cod_motiv,
		   nombre
	  INTO _cod_motiv,
		   _nombre
	  FROM cobmotiv

  	LET _campo = _cod_motiv || _nombre;

  	INSERT INTO cobcmim
  	VALUES (_campo);

END FOREACH}

--grupos
FOREACH
	SELECT cod_motiv,
		   nombre
	  INTO _cod_motiv,
		   _nombre
	  FROM cligrupo

  	LET _campo = _cod_motiv || _nombre;

  	INSERT INTO cobcmim
  	VALUES (_campo);

END FOREACH

END PROCEDURE