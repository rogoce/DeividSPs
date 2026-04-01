-- Procedimiento Verificar la Suma de las primas anuales del contratante 
--
-- Creado    : 28/10/2009 - Autor: Amado Perez.
-- Modificado: 11/11/2009 - Autor: Amado Perez.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe46;
CREATE PROCEDURE "informix".sp_proe46(a_contratante CHAR(10))
			RETURNING   DEC(16,2);

DEFINE _no_unidad   	CHAR(10);
DEFINE _error			INTEGER;
DEFINE _cod_asegurado 	CHAR(10);
DEFINE _descrip 	    VARCHAR(40);
DEFINE _conoce_cliente  SMALLINT;
DEFINE _prima_neta      DEC(16,2);
DEFINE _prima_neta_v    DEC(16,2);
DEFINE _no_documento    CHAR(20);
DEFINE _no_poliza       CHAR(10);
DEFINE _no_poliza_v		CHAR(10);

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe46.trc";    
-- TRACE ON;                                                                     
LET _prima_neta = 0;
LET _prima_neta_v = 0;

FOREACH
	SELECT no_poliza, no_documento, prima_neta
	  INTO _no_poliza, _no_documento, _prima_neta_v
	  FROM emipomae
	 WHERE cod_contratante = a_contratante
	   AND actualizado = 1
	   AND estatus_poliza = 1

	CALL sp_sis21(_no_documento) returning _no_poliza_v;

    IF _no_poliza = _no_poliza_v Then
	   LET _prima_neta = _prima_neta + _prima_neta_v;
	END IF

END FOREACH    


RETURN _prima_neta; 
--RETURN 0, "", _descrip;
END
END PROCEDURE;