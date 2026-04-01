-- Procedimiento para sacar el incurrido bruto para una transaccion
-- 
-- creado: 24/11/2003 - Autor: Armando Moreno Montenegro.

DROP PROCEDURE sp_rec78;
CREATE PROCEDURE "informix".sp_rec78(a_transaccion CHAR(10)) 
			RETURNING DEC(16,2);  --Incurrido bruto

DEFINE v_estimado      DEC(16,2);			 
DEFINE v_deducible     DEC(16,2);			 
DEFINE v_reserva_i     DEC(16,2);			 
DEFINE v_reserva_a     DEC(16,2);			 
DEFINE v_pagos         DEC(16,2);			 
DEFINE v_recupero      DEC(16,2);			 
DEFINE v_salvamento    DEC(16,2);			 
DEFINE v_deducible_p   DEC(16,2);			 
DEFINE v_deducible_d   DEC(16,2);
DEFINE _monto_tran     DEC(16,2);
define _variacion	   DEC(16,2);
DEFINE v_porc_reas	   DEC(9,6);
DEFINE v_porc_coas	   DEC(7,4);

DEFINE _estimado		 DEC(16,2);
DEFINE _deducible		 DEC(16,2);
DEFINE _reserva_inicial	 DEC(16,2);
DEFINE _reserva_actual	 DEC(16,2);
DEFINE _pagos			 DEC(16,2);
DEFINE _salvamento		 DEC(16,2);
DEFINE _recupero		 DEC(16,2);
DEFINE _deducible_pagado DEC(16,2);
DEFINE _deducible_devuel DEC(16,2);	
DEFINE _ded 			 DEC(16,2);
DEFINE _monto_concepto   DEC(16,2);
DEFINE _descuenta_ded    DEC(16,2);
DEFINE _orden            INT;
DEFINE _no_tranrec       CHAR(10);
define _no_reclamo		 CHAR(10);
DEFINE _tipo_transaccion SMALLINT;
DEFINE _tipo_concepto    SMALLINT;
DEFINE _numrecla         CHAR(18);
DEFINE _cod_tipotran     CHAR(3);
DEFINE _cod_concepto     CHAR(3);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _incurrido_bruto  DEC(16,2);
DEFINE _incurrido_neto	  DEC(16,2);

LET v_estimado         = 0;
LET _variacion         = 0;
LET v_deducible        = 0; 
LET v_reserva_i        = 0; 
LET v_reserva_a        = 0; 
LET v_pagos            = 0;     
LET v_recupero         = 0;  
LET v_salvamento       = 0;
LET v_deducible_p      = 0;
LET v_deducible_d      = 0;
LET _ded               = 0;
LET _pagos               = 0;
LET _descuenta_ded     = 0;
LET _deducible_devuel  = 0;
LET _incurrido_reclamo = 0;
LET _incurrido_bruto   = 0;
LET _incurrido_neto    = 0;
LET _deducible_pagado = 0;


 SELECT no_tranrec,
		monto,
		cod_tipotran,
		numrecla,
		no_reclamo,
		variacion
   INTO _no_tranrec,
		_monto_tran,
		_cod_tipotran,
		_numrecla,
		_no_reclamo,
		_variacion
   FROM rectrmae
  WHERE transaccion = a_transaccion
    AND actualizado = 1;

 SELECT tipo_transaccion
   INTO _tipo_transaccion
   FROM rectitra
  WHERE cod_tipotran = _cod_tipotran;

 IF _tipo_transaccion = 4 or _tipo_transaccion = 5 or _tipo_transaccion = 6 or _tipo_transaccion = 7 THEN
 ELSE
	let _monto_tran = 0.00;
 END IF

FOREACH
 SELECT porc_partic_coas
   INTO v_porc_coas
   FROM reccoas r, parparam p
  WHERE r.cod_coasegur = p.par_ase_lider
    AND r.no_reclamo = _no_reclamo
END FOREACH

IF v_porc_coas IS NULL THEN
   LET v_porc_coas = 0;
END IF

--INCURRIDOS

LET _incurrido_reclamo = _monto_tran + _variacion;
--LET _incurrido_bruto   = _incurrido_reclamo * v_porc_coas / 100;

	RETURN _incurrido_reclamo
	  WITH RESUME;   	

--DROP TABLE tmp_arreglo;
END PROCEDURE