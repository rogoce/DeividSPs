-- Procedimiento para sacar el monto para una transaccion
--
-- creado: 06/01/2020 - Autor: Amado Perez M.

DROP PROCEDURE sp_rwf181;
CREATE PROCEDURE "informix".sp_rwf181(a_no_tranrec CHAR(10))
			RETURNING DEC(16,2);  -- Monto de la transaccion

DEFINE _monto_tran     DEC(16,2);
DEFINE _no_reclamo     CHAR(10);
DEFINE _perd_total     SMALLINT;
DEFINE _cant           SMALLINT;
DEFINE _monto_da       DEC(16,2);
DEFINE _monto_col      DEC(16,2);
DEFINE _limite_2       DEC(16,2);
DEFINE _perd_total_tr  SMALLINT;
DEFINE _perd_total_t   SMALLINT;
DEFINE _cod_tipotran   CHAR(3);
DEFINE _user_added     CHAR(8);
DEFINE _no_reclamo	   CHAR(10);

LET _monto_tran        = 0;
LET _monto_col         = 0;
LET _monto_da          = 0;
LET _limite_2          = 0;
LET _perd_total_tr     = 0;

SET ISOLATION TO DIRTY READ;

 SELECT user_added,
        no_reclamo
   INTO _user_added,
        _no_reclamo
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec; 

 SELECT a.limite_2
   INTO _limite_2
   FROM wf_aprodet a, insuser b
  WHERE trim(a.grupo) = trim(b.codigo_perfil)
	AND b.usuario = _user_added
	AND a.cod_aprobacion = '011';

 IF _limite_2 IS NULL THEN
	LET _limite_2 = 0;	
 END IF 
 
 RETURN _limite_2;

END PROCEDURE
