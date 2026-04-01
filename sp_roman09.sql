-- Procedimiento para los Totales de la Emision de Reclamo
-- 
-- Creado    : 06/11/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 06/11/2000 - Autor: Amado Perez Mendoza
-- Modificado: 03/12/2001 - Autor: Armando Moreno Montenegro.(sacar pagado y deducible(se agrego esta columna al datawindow)
-- de transacciones, arreglar Deducible Pagado y calcular los incurridos desde aqui y no desde el datawindow.
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_roman09;
CREATE PROCEDURE sp_roman09(a_reclamo CHAR(10))
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
DEFINE _tipo_transaccion SMALLINT;
DEFINE _tipo_concepto    SMALLINT;
DEFINE _numrecla         CHAR(18);
DEFINE _cod_tipotran     CHAR(3);
DEFINE _cod_concepto     CHAR(3);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _incurrido_bruto  DEC(16,2);
DEFINE _incurrido_neto	  DEC(16,2);
	
CREATE TEMP TABLE tmp_arreglo(
		estimado   	DEC(16,2),
		deducible  	DEC(16,2),
		reserva_i  	DEC(16,2),
		reserva_a  	DEC(16,2),
		pagos      	DEC(16,2),
		recupero   	DEC(16,2),
		salvamento 	DEC(16,2),
		deducible_p	DEC(16,2),
        deducible_d	DEC(16,2),
		tr_deduci	DEC(16,2)
		) WITH NO LOG;   

LET v_estimado         = 0;  
LET v_deducible        = 0; 
LET v_reserva_i        = 0; 
LET v_reserva_a        = 0; 
LET v_pagos            = 0;     
LET v_recupero         = 0;  
LET v_salvamento       = 0;
LET v_deducible_p      = 0;
LET v_deducible_d      = 0;
LET _ded               = 0;
LET _pagos             = 0;
LET _descuenta_ded     = 0;
LET _deducible_devuel  = 0;
LET _incurrido_reclamo = 0;
LET _incurrido_bruto   = 0;
LET _incurrido_neto    = 0;
LET _deducible_pagado  = 0;
let _numrecla = null;

FOREACH	
   SELECT SUM(x.estimado),
		  SUM(x.deducible),
		  SUM(x.reserva_inicial),
		  SUM(x.reserva_actual),
		  SUM(x.salvamento),
		  SUM(x.recupero)
     INTO _estimado,
		  _deducible,
		  _reserva_inicial,
		  _reserva_actual,
		  _salvamento,
		  _recupero
	 FROM recrccob x, recrcmae y
	WHERE x.no_reclamo  = y.no_reclamo
	  AND y.no_reclamo  = a_reclamo

	  LET _salvamento = _salvamento * -1;
	  LET _recupero   = _recupero   * -1;

	--TRANSACCIONES	DE DEDUCIBLE y PAGOS

	FOREACH
		 SELECT no_tranrec,
				monto,
				cod_tipotran,
				numrecla
		   INTO _no_tranrec,
				_monto_tran,
				_cod_tipotran,
				_numrecla
		   FROM rectrmae
		  WHERE no_reclamo  = a_reclamo
		    AND actualizado = 1

		-- Nombre de las Transacciones
		 SELECT tipo_transaccion
		   INTO _tipo_transaccion
		   FROM rectitra
		  WHERE cod_tipotran = _cod_tipotran;

		 IF _tipo_transaccion = 7 THEN	--ded
			LET _ded = _ded + (_monto_tran * -1);
		 ELIF _tipo_transaccion = 4 THEN	--pagos
			LET _pagos = _pagos + _monto_tran;
		 ELSE
			CONTINUE FOREACH;
		 END IF
	END FOREACH;

	--CONCEPTO DE PAGO
	FOREACH
		SELECT c.cod_concepto,
	    	   SUM(c.monto)
		  INTO _cod_concepto,
	           _monto_concepto
	      FROM rectrcon c, rectrmae t
	     WHERE c.no_tranrec   = t.no_tranrec
		   AND t.numrecla     = _numrecla
		   AND t.actualizado  = 1
		 GROUP BY cod_concepto

		  IF _monto_concepto IS NULL THEN
		  	LET _monto_concepto = 0;
		  END IF

		SELECT tipo_concepto
		  INTO _tipo_concepto
		  FROM recconce
		 WHERE cod_concepto = _cod_concepto;

	   	IF _tipo_concepto = 2 THEN	--desc. ded.
			LET _descuenta_ded = _monto_concepto;
		END IF

	   	IF _tipo_concepto = 3 THEN	--devol. de ded.
			LET _deducible_devuel = _monto_concepto;
		END IF

		LET _deducible_pagado = _ded + _descuenta_ded + _deducible_devuel;
	END FOREACH;

	LET _deducible_pagado = _deducible_pagado * -1;

	INSERT INTO tmp_arreglo(
	estimado,   
	deducible,  
	reserva_i,  
	reserva_a,  
	pagos,        
	recupero,   	
	salvamento,  
	deducible_p, 
	deducible_d,
	tr_deduci
	)
	VALUES(
	_estimado,
	_deducible,
	_reserva_inicial,
	_reserva_actual,
	_pagos,
	_recupero,
	_salvamento,
	_deducible_pagado,
	_deducible_devuel,
	_ded
	);

END FOREACH;

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
	 SELECT estimado,    
			deducible,  
			reserva_i,  
			reserva_a,  
			pagos,      
			recupero,   
			salvamento, 
			deducible_p,
			deducible_d,
			tr_deduci
	   INTO _estimado,
			_deducible,
			_reserva_inicial,
			_reserva_actual,
			_pagos,
			_recupero,
			_salvamento,
			_deducible_pagado,
			_deducible_devuel,
			_ded
	   FROM tmp_arreglo	 

END FOREACH

LET	v_porc_coas = NULL;

FOREACH
 SELECT porc_partic_coas
   INTO v_porc_coas
   FROM reccoas r, parparam p
  WHERE r.cod_coasegur = p.par_ase_lider
    AND r.no_reclamo = a_reclamo
END FOREACH

IF v_porc_coas IS NULL THEN
   LET v_porc_coas = 0;
END IF

--INCURRIDOS

LET _incurrido_reclamo = 0.00;
LET _incurrido_bruto   = 0.00;
LET _incurrido_neto    = 0.00;
let v_porc_reas        = 0.00;
foreach
 select monto,
        no_tranrec
   into _monto_tran,
        _no_tranrec
   from rectrmae
  where no_reclamo   = a_reclamo
    and actualizado  = 1
    and cod_tipotran in ("004", "005", "006", "007")

     foreach
		 select porc_partic_suma    -- Estaba trayendo error al renovar porque traia mas de una fila CASO: 15809 USER: LELIA PC: CMEMIS28 30/09/2013
		   into v_porc_reas
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato = 1
         exit foreach;
	 end foreach

	IF v_porc_reas IS NULL THEN
	   LET v_porc_reas = 0;
	END IF

	let _incurrido_reclamo = _incurrido_reclamo + _monto_tran;
	let _monto_tran        = _monto_tran * v_porc_coas / 100;
	let _incurrido_bruto   = _incurrido_bruto + _monto_tran;
	let _monto_tran        = _monto_tran * v_porc_reas / 100;
	let _incurrido_neto    = _incurrido_neto + _monto_tran;

end foreach

foreach
 select variacion,
        no_tranrec
   into _monto_tran,
        _no_tranrec
   from rectrmae
  where no_reclamo   = a_reclamo
    and actualizado  = 1
    and variacion    <> 0.00

     foreach
		 select porc_partic_suma
		   into v_porc_reas
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato = 1
         exit foreach;
	 end foreach

	IF v_porc_reas IS NULL THEN
	   LET v_porc_reas = 0;
	END IF

	let _incurrido_reclamo = _incurrido_reclamo + _monto_tran;
	let _monto_tran        = _monto_tran * v_porc_coas / 100;
	let _incurrido_bruto   = _incurrido_bruto + _monto_tran;
	let _monto_tran        = _monto_tran * v_porc_reas / 100;
	let _incurrido_neto    = _incurrido_neto + _monto_tran;

end foreach

DROP TABLE tmp_arreglo;

RETURN _incurrido_bruto;

END PROCEDURE