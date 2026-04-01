-- Busca proxima libreta disponible

-- Creado    : 31/07/2003 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob121a;

CREATE PROCEDURE "informix".sp_cob121a(a_recibo CHAR(10)) 
RETURNING 	INTEGER,
            CHAR(3),
			DATE,
			CHAR(100),
			CHAR(100);

DEFINE _no_cheque   INTEGER;
DEFINE _cod_banco   CHAR(3);
DEFINE _fecha       DATE;
DEFINE _girado_por  CHAR(100);
DEFINE _a_favor_de  CHAR(100); 

DEFINE _no_remesa   CHAR(10);

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_remesa
	  INTO _no_remesa
	  FROM cobredet
	 WHERE no_recibo =  a_recibo 
	EXIT FOREACH;
END FOREACH

FOREACH
 SELECT	no_cheque, 
		cod_banco, 
		fecha,     
		girado_por,
		a_favor_de
   INTO	_no_cheque, 
		_cod_banco, 
		_fecha,     
		_girado_por,
		_a_favor_de
   FROM	cobrepag
  WHERE no_remesa = _no_remesa
    AND tipo_pago = 2
	EXIT FOREACH;
END FOREACH

RETURN _no_cheque, 
	   _cod_banco, 
	   _fecha,     
	   _girado_por,
	   _a_favor_de;
END PROCEDURE;
