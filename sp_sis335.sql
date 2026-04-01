-- Procedimiento que Carga los Datos para la Apadea
-- 
-- Creado    : 18/02/2002 - Autor: Amado Perez M. 
-- Modificado: 18/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis335;		

CREATE PROCEDURE "informix".sp_sis335()
RETURNING INTEGER;

DEFINE  v_numero INTEGER;
DEFINE  v_fecha  DATE;

SET ISOLATION TO DIRTY READ;

SELECT numero
  INTO v_numero
  FROM cib_contador;

LET	v_numero = v_numero + 1;
LET v_fecha = CURRENT;

UPDATE cib_contador
   SET numero = v_numero,
       fecha  = v_fecha;

RETURN v_numero;
       


END PROCEDURE;