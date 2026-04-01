-- Consulta de Recibos para Recuperos
-- 
-- Creado    : 05/07/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/07/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_recupero_recibos - DEIVID, S.A.

DROP PROCEDURE sp_rec51;

CREATE PROCEDURE "informix".sp_rec51(a_no_reclamo CHAR(10))
RETURNING CHAR(10),
          DATE,
		  CHAR(10),
		  INTEGER,
		  CHAR(10),
		  CHAR(10),
		  CHAR(100),
		  DEC(16,2),
		  CHAR(10);

DEFINE _cod_tipotran	CHAR(3);
DEFINE _transaccion		CHAR(10);
DEFINE _no_remesa		CHAR(10);
DEFINE _renglon			INTEGER;
DEFINE _fecha			DATE;
DEFINE _cod_cliente		CHAR(10);
DEFINE _no_recibo 		CHAR(10);
DEFINE _monto			DEC(16,2);
DEFINE _nombre			CHAR(100);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_rec51.trc";      
--TRACE ON;                                                                     

SET ISOLATION TO DIRTY READ;

SELECT cod_tipotran
  INTO _cod_tipotran
  FROM rectitra
 WHERE tipo_transaccion = 6;
 
FOREACH
 SELECT	transaccion,
		no_remesa,
		renglon,
		fecha,
		cod_cliente,
		monto
   INTO	_transaccion,
		_no_remesa,
		_renglon,
		_fecha,
		_cod_cliente,
		_monto
   FROM	rectrmae
  WHERE cod_tipotran = _cod_tipotran
    AND no_reclamo   = a_no_reclamo
    AND actualizado  = 1
  ORDER BY fecha

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	  	
	IF _no_remesa IS NOT NULL THEN

		SELECT no_recibo
		  INTO _no_recibo
		  FROM cobredet
		 WHERE no_remesa = _no_remesa
		   AND renglon   = _renglon;

	ELSE

		LET _no_recibo = '';

	END IF

	LET _monto = _monto * -1;

	RETURN _transaccion,
		   _fecha,	
		   _no_remesa,
		   _renglon,
		   _no_recibo,
		   _cod_cliente,
		   _nombre,
		   _monto,
		   a_no_reclamo
		   WITH RESUME;
		       
END FOREACH

END PROCEDURE;

