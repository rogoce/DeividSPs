-- Procedimiento Verificar que no hay Valores con orden igual a cero en Coberturas
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_proe40a;
CREATE PROCEDURE "informix".sp_proe40a(a_poliza CHAR(10))
			RETURNING   SMALLINT,			 -- _error
						CHAR(10),			 -- ls_unidad
						VARCHAR(30);

DEFINE _no_unidad   	CHAR(10);
DEFINE _error			INTEGER;
DEFINE _cod_asegurado 	CHAR(10);
DEFINE _descrip 	    VARCHAR(30);
DEFINE _cedula			VARCHAR(30);
DEFINE _telefono1		CHAR(10);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "sp_pro44.trc";
-- TRACE ON;                                                                     
LET _descrip = NULL;

FOREACH	
	SELECT no_unidad,
	       cod_asegurado
	  INTO _no_unidad,
	       _cod_asegurado
	  FROM emireaut
	 WHERE no_poliza = a_poliza
	ORDER BY no_unidad

    SELECT cedula,
	       telefono1
	  INTO _cedula,
	       _telefono1
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

    IF _cedula IS NULL OR TRIM(_cedula) = "" THEN
		LET _descrip = "Cedula";
	END IF

    IF _telefono1 IS NULL OR TRIM(_telefono1) = "" THEN
		IF _descrip IS NOT NULL THEN
			LET _descrip = _descrip || " y el Telefono de Casa";
		ELSE
			LET _descrip = "Telefono de Casa";
		END IF
	END IF

	IF _descrip IS NOT NULL THEN
		RETURN 1, _no_unidad, _descrip;
	END IF
END FOREACH
RETURN 0, "", _descrip;
END
END PROCEDURE;