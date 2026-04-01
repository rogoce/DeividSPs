-- Procedimiento para sacar el monto para una transaccion
--
-- creado: 06/01/2020 - Autor: Amado Perez M.

DROP PROCEDURE sp_rwf170;
CREATE PROCEDURE "informix".sp_rwf170(a_no_tranrec CHAR(10))
			RETURNING DEC(16,2);  -- Monto de la transaccion

DEFINE _monto_tran     DEC(16,2);
DEFINE _no_reclamo     CHAR(10);
DEFINE _perd_total     SMALLINT;
DEFINE _cant           SMALLINT;

LET _monto_tran        = 0;

SET ISOLATION TO DIRTY READ;

 SELECT no_reclamo,
        monto,
        perd_total
   INTO _no_reclamo,
        _monto_tran,
        _perd_total
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;


 RETURN _monto_tran;

END PROCEDURE
