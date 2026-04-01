-- Procedimiento Verificar que si hay asegurados sin Conoce a tu Cliente
--
-- Creado    : 28/10/2009 - Autor: Amado Perez.
-- Modificado: 28/10/2009 - Autor: Amado Perez.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe43;
CREATE PROCEDURE "informix".sp_proe43(a_poliza CHAR(10))
			RETURNING   SMALLINT,			 -- _error
						CHAR(10),			 -- ls_unidad
						VARCHAR(40);

DEFINE _no_unidad   	CHAR(10);
DEFINE _error			INTEGER;
DEFINE _cod_asegurado 	CHAR(10);
DEFINE _descrip 	    VARCHAR(40);
DEFINE _conoce_cliente  SMALLINT;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     
LET _descrip = NULL;

FOREACH	
	SELECT no_unidad,
	       cod_asegurado
	  INTO _no_unidad,
	       _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	ORDER BY no_unidad

    SELECT conoce_cliente
	  INTO _conoce_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

    IF _conoce_cliente = 0 THEN
		LET _descrip = "formulario Conoce a tu Cliente";
	END IF


	IF _descrip IS NOT NULL THEN
		RETURN 1, _no_unidad, _descrip;
		EXIT FOREACH;
	END IF
END FOREACH
RETURN 0, "", _descrip;
END
END PROCEDURE;