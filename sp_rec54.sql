-- Monto y Fecha de Recibos para Recuperos
-- 
-- Creado    : 24/07/2001 - Autor: Marquelda Valdelamar
-- Modificado: 24/07/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_recl_recupero_recibos - DEIVID, S.A.

DROP PROCEDURE sp_rec54;

CREATE PROCEDURE "informix".sp_rec54(a_no_reclamo CHAR(10))
RETURNING DATE,
		  DEC(16,2);

DEFINE _cod_tipotran	CHAR(3);
DEFINE _fecha			DATE;
DEFINE _monto			DEC(16,2);

SET ISOLATION TO DIRTY READ;


SELECT cod_tipotran
  INTO _cod_tipotran
  FROM rectitra
 WHERE tipo_transaccion = 6;
 
FOREACH
 SELECT fecha,
	    monto
   INTO	_fecha,
   	    _monto
   FROM	rectrmae
  WHERE cod_tipotran = _cod_tipotran
    AND no_reclamo   = a_no_reclamo
    AND actualizado  = 1
 ORDER BY fecha DESC
 EXIT FOREACH;
END FOREACH

LET _monto = _monto * -1;

RETURN _fecha,	
	   _monto
   WITH RESUME;
		       
END PROCEDURE;

