-- Consulta de Transaccione de aumento de reserva sin actualizar

-- Creado    : 03/02/2009 - Autor: Amado Perez M.
-- Modificado: 03/02/2009 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf69;

CREATE PROCEDURE sp_rwf69(a_no_reclamo CHAR(10), a_no_tranrec CHAR(10))
RETURNING SMALLINT;

define v_existe	 smallint;
define _cantidad int;
define _cod_tipotran char(3);
define _anular_nt char(10);

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;

LET v_existe = 0;

SELECT cod_tipotran, anular_nt
  INTO _cod_tipotran, _anular_nt
  FROM rectrmae
 WHERE no_tranrec = a_no_tranrec;

IF _cod_tipotran = '002' THEN
	RETURN  1;
END IF

IF _anular_nt is not null And trim(_anular_nt) <> ""  THEN
	RETURN  1;
END IF

 SELECT	count(*)
   INTO _cantidad
   FROM	rectrmae 
  WHERE no_reclamo = a_no_reclamo
    AND no_tranrec <> a_no_tranrec
	AND cod_tipotran in ('001','002')
    AND actualizado = 0
    AND wf_aprobado = 3;

IF _cantidad > 0 THEN
	LET v_existe = 0;
ELSE
	LET v_existe = 1;
END IF

RETURN  v_existe;


END PROCEDURE;