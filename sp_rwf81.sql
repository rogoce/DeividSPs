-- Procedimiento para sacar el pago para una transaccion
--
-- creado: 10/08/2009 - Autor: Amado Perez M.

--DROP PROCEDURE sp_rwf81;
CREATE PROCEDURE "informix".sp_rwf81(a_no_tranrec CHAR(10))
			RETURNING DEC(16,2);  --Incurrido bruto

DEFINE _monto_tran     DEC(16,2);
DEFINE _variacion	   DEC(16,2);

DEFINE _no_tranrec        CHAR(10);
DEFINE _cod_tipotran      CHAR(3);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _tipo_transaccion  SMALLINT;
DEFINE v_reclamo          CHAR(10);
DEFINE _no_tranrec_tmp   CHAR(10);
DEFINE _no_tranrec_int   char(10);
DEFINE _cod_tipotran_tmp CHAR(3);
DEFINE _fecha_tmp        DATE;
DEFINE _transaccion_tmp  CHAR(10);
DEFINE _variacion_tmp, _monto_tmp, v_reserva DEC(16,2);

LET _variacion         = 0;
LET _monto_tran        = 0;
LET _incurrido_reclamo = 0;

SET ISOLATION TO DIRTY READ;

-- Buscando el monto de la transaccion actual

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

 IF _tipo_transaccion = 1 OR _tipo_transaccion = 2 OR _tipo_transaccion = 3 THEN
 ELSE
	let _monto_tran = 0.00;
 END IF

--INCURRIDOS

LET _incurrido_reclamo = _monto_tran;


RETURN _incurrido_reclamo;

END PROCEDURE
