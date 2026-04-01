-- Procedimiento Verificar las exclusiones de Conoce a tu Cliente 
--
-- Creado    : 28/10/2009 - Autor: Amado Perez.
-- Modificado: 11/11/2009 - Autor: Amado Perez.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe47;
CREATE PROCEDURE "informix".sp_proe47(a_exclusion VARCHAR(10), a_tipo CHAR(3))
			RETURNING   SMALLINT;

DEFINE _no_unidad   	CHAR(10);
DEFINE _error			INTEGER;
DEFINE _cod_asegurado 	CHAR(10);
DEFINE _descrip 	    VARCHAR(40);
DEFINE _conoce_cliente  SMALLINT;
DEFINE _prima_neta      DEC(16,2);

BEGIN

SET ISOLATION TO DIRTY READ;

LET _error = 0;

--return 1;

IF a_tipo = '001' THEN	  -- Exclusion por Sucursal Remota
	IF TRIM(a_exclusion) IN ('056','059','072','047','075','020','083') THEN 
		LET _error = 1;
	END IF
ELIF a_tipo = '002' THEN
	IF TRIM(a_exclusion) = '00035' THEN	 -- Exclusion por Corredor 
		LET _error = 1;
	END IF
END IF


RETURN _error; 
--RETURN 0, "", _descrip;
END
END PROCEDURE;