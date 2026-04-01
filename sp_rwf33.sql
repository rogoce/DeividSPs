-- Procedimiento para sacar el incurrido bruto para una transaccion
--
-- creado: 24/11/2003 - Autor: Armando Moreno Montenegro.

--DROP PROCEDURE sp_rwf33;
CREATE PROCEDURE "informix".sp_rwf33(a_no_tranrec CHAR(10))
			RETURNING DEC(16,2);  --Incurrido bruto

DEFINE _monto_tran     DEC(16,2);
DEFINE _variacion	   DEC(16,2);

DEFINE _no_tranrec        CHAR(10);
DEFINE _cod_tipotran      CHAR(3);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _tipo_transaccion  SMALLINT;


LET _variacion         = 0;
LET _monto_tran        = 0;
LET _incurrido_reclamo = 0;

SET ISOLATION TO DIRTY READ;

 SELECT no_tranrec,
		monto,
		cod_tipotran,
		variacion
   INTO _no_tranrec,
		_monto_tran,
		_cod_tipotran,
		_variacion
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

 SELECT tipo_transaccion
   INTO _tipo_transaccion
   FROM rectitra
  WHERE cod_tipotran = _cod_tipotran;

 IF _tipo_transaccion = 4 or _tipo_transaccion = 5 or _tipo_transaccion = 6 or _tipo_transaccion = 7 THEN
 ELSE
	let _monto_tran = 0.00;
 END IF


--INCURRIDOS

LET _incurrido_reclamo = _monto_tran + _variacion;

	RETURN _incurrido_reclamo;

END PROCEDURE
