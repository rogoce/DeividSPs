-- Informe que muestra si hay diferencia en los saldos de alguna poliza
-- 
-- Creado    : 25/02/2002 - Autor: Marquelda Valdelamar
-- Modificado: 26/02/2002 - Autor: Marquelda Valdelamar
-- 
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pa51d;

CREATE PROCEDURE "informix".sp_pa51d(
a_periodo      CHAR(7)     
) RETURNING	DATE,       -- Fecha de la Transaccion
			CHAR(10),	-- No Poliza
			CHAR(10),	-- No_factura
			CHAR(5),	-- No_endoso
			CHAR(10),   -- No_remesa
			INTEGER,    -- No_renglon
			CHAR(10),   -- No_recibo
			CHAR(10),   -- No_requisicion
			INTEGER,    -- No_cheque
			CHAR(20),   -- No_documento
			DEC(16,2),	-- monto
			DEC(16,2),	-- monto_dbgdeta
			CHAR(20);   -- Tipo_tran
 	
DEFINE v_no_documento     CHAR(20);
DEFINE v_no_factura       CHAR(10);
DEFINE v_no_poliza        CHAR(10);
DEFINE v_no_endoso        CHAR(5);
DEFINE v_no_recibo        CHAR(10);
DEFINE v_no_remesa        CHAR(10);
DEFINE v_no_requis        CHAR(10);
DEFINE v_renglon          INTEGER;
DEFINE v_no_cheque        INTEGER;
DEFINE v_monto_dbgdeta	  DEC(16,2);
DEFINE v_monto            DEC(16,2);

DEFINE _tipo_tran         CHAR(20);
DEFINE v_fecha_tran		  DATE;

CREATE TEMP TABLE tmp_deta(
		fecha_tran    DATE,
		no_poliza     CHAR(10),
		no_factura    CHAR(10),
		no_endoso     CHAR(5),
		no_remesa     CHAR(10),
		renglon       INTEGER,
		no_recibo     CHAR(10),
		no_requis     CHAR(10),
		no_cheque     INTEGER,
		no_documento  CHAR(20),
		monto		  DEC(16,2),
		monto_dbgdeta DEC(16,2),
		tipo_tran	  CHAR(20)
		) WITH NO LOG;   

FOREACH
 SELECT prima_bruta,
		no_factura,
		no_poliza
   INTO	v_monto,
		v_no_factura,
		v_no_poliza
   FROM endedmae
  WHERE periodo       = a_periodo
--fecha_emision = a_fecha
    AND actualizado   = 1 
    AND activa        = 1
   
    LET _tipo_tran = 'FACTURA';
	
	 FOREACH
	 SELECT fecha_tran,
			no_endoso,
			no_documento,
			monto
	   INTO v_fecha_tran,
			v_no_endoso,
			v_no_documento,
			v_monto_dbgdeta
	    FROM dbgdeta
	   WHERE monto   <> v_monto
	     AND no_poliza = v_no_poliza

		INSERT INTO tmp_deta(
			fecha_tran,
			no_poliza,
			no_factura,
			no_endoso,
			no_remesa,
			renglon,
			no_recibo,
			no_requis,
			no_cheque,
			no_documento,
			monto,	 
			monto_dbgdeta,
			tipo_tran 
			)
			VALUES(
			v_fecha_tran,
			v_no_poliza,    
			v_no_factura,
			v_no_endoso,    
			null,
			null,
			null,
			null,
			null,
			v_no_documento,
			v_monto,
			v_monto_dbgdeta,
			_tipo_tran
		    );
  END FOREACH;
END FOREACH; --verificar

-- Recibos

FOREACH 
 SELECT no_poliza,
        no_recibo,
		monto
   INTO v_no_poliza,
		v_no_recibo,
		v_monto
   FROM cobredet
  WHERE periodo = a_periodo
  --fecha   <= a_fecha

	LET _tipo_tran = 'RECIBO';

	 FOREACH
	 SELECT fecha_tran,
			no_remesa,
			renglon,
			no_documento,
			monto
	   INTO v_fecha_tran,
			v_no_remesa,
			v_renglon,
			v_no_documento,
			v_monto_dbgdeta
	    FROM dbgdeta
	   WHERE monto   <> v_monto
	     AND no_poliza = v_no_poliza

		INSERT INTO tmp_deta(
			fecha_tran,
			no_poliza,
			no_factura,
			no_endoso,
			no_remesa,
			renglon,
			no_recibo,
			no_requis,
			no_cheque,
			no_documento,
			monto,	 
			monto_dbgdeta,
			tipo_tran 
			)
			VALUES(
			v_fecha_tran,
			v_no_poliza,    
			null,
			null,    
			v_no_remesa,
			v_renglon,
			v_no_recibo,
			null,
			null,
			v_no_documento,
			v_monto,
			v_monto_dbgdeta,
			_tipo_tran
		    );

		END FOREACH;
END FOREACH;

--Cheques Pagados
FOREACH 
 SELECT b.no_poliza,
		a.no_cheque,
        a.monto
   INTO v_no_poliza,
		v_no_cheque,
		v_monto
   FROM chqchmae a, chqchpol b
  WHERE a.pagado          = 1
-- AND	a.fecha_impresion = a_fecha
	AND a.periodo         = a_periodo
	AND a.origen_cheque   = "6"
	AND a.no_requis       = b.no_requis

	LET _tipo_tran = 'CHEQUE PAGADO';

     FOREACH
	 SELECT fecha_tran,
			no_requis,			
  			no_documento,
			monto
	   INTO v_fecha_tran,
			v_no_requis,
			v_no_documento,
			v_monto_dbgdeta
	    FROM dbgdeta
	   WHERE monto   <> v_monto
	     AND no_poliza = v_no_poliza	     

		INSERT INTO tmp_deta(
			fecha_tran,
			no_poliza,
			no_factura,
			no_endoso,
			no_remesa,
			renglon,
			no_recibo,
			no_requis,
			no_cheque,
			no_documento,
			monto,	 
			monto_dbgdeta,
			tipo_tran 
			)
			VALUES(
			v_fecha_tran,
			v_no_poliza,    
			null,
			null,    
			null,
			null,
			null,
			v_no_requis,
			v_no_cheque,
			v_no_documento,
			v_monto,
			v_monto_dbgdeta,
			_tipo_tran
		    );
		END FOREACH;
END FOREACH;

-- Cheque Anulado
FOREACH 
 SELECT b.no_poliza,
		a.no_cheque,
		b.monto
   INTO v_no_poliza,
		v_no_cheque,
		v_monto
   FROM chqchmae a, chqchpol b
  WHERE a.anulado       = 1
--  AND	a.fecha_anulado = a_fecha
    AND a.periodo = a_periodo
	AND a.origen_cheque = "6"
	AND a.no_requis     = b.no_requis

	LET _tipo_tran = 'CHEQUE ANULADO';

	 FOREACH
	 SELECT fecha_tran,
			no_requis,			
  			no_documento,
			monto
	   INTO v_fecha_tran,
			v_no_requis,
			v_no_documento,
			v_monto_dbgdeta
	    FROM dbgdeta
	   WHERE monto   <> v_monto
	     AND no_poliza = v_no_poliza

		INSERT INTO tmp_deta(
			fecha_tran,
			no_poliza,
			no_factura,
			no_endoso,
			no_remesa,
			renglon,
			no_recibo,
			no_requis,
			no_cheque,
			no_documento,
			monto,	 
			monto_dbgdeta,
			tipo_tran 
			)
			VALUES(
			v_fecha_tran,
			v_no_poliza,    
			null,
			null,    
			null,
			null,
			null,
			v_no_requis,
			v_no_cheque,
			v_no_documento,
			v_monto,
			v_monto_dbgdeta,
			_tipo_tran
		    );

		END FOREACH;
END FOREACH;

  RETURN v_fecha_tran,
		 v_no_poliza,
		 v_no_factura,
		 v_no_endoso,
		 v_no_remesa,
		 v_renglon,
		 v_no_recibo,
		 v_no_requis,
		 v_no_cheque,
		 v_no_documento,
		 v_monto,	 
		 v_monto_dbgdeta,
		 _tipo_tran 
    	 WITH RESUME;
		
DROP TABLE tmp_deta;

END PROCEDURE

