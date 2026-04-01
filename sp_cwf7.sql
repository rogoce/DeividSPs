-- Consulta de Transacciones por requisicion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_cwf7;

CREATE PROCEDURE sp_cwf7(a_no_requis CHAR(10) default "%")
RETURNING varchar(100),
          CHAR(1);

define v_no_cheque_ant     	varchar(20);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_cheque_ant	  
	  INTO v_no_cheque_ant
	  FROM chqchmae 		  
	 WHERE no_requis = a_no_requis

    IF v_no_cheque_ant IS NULL OR v_no_cheque_ant = "0" THEN
		RETURN "", ""  WITH RESUME;
	ELSE
		RETURN "ESTA REQUISICION REEMPLAZA AL CHEQUE " || trim(v_no_cheque_ant) || " QUE FUE ANULADO.", "1"  WITH RESUME;
    END IF

END FOREACH
END PROCEDURE;