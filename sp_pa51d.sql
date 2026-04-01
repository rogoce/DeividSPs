-- Informe que muestra si hay diferencia en los saldos de alguna poliza

-- Informe N. 3

-- Creado    : 25/02/2002 - Autor: Marquelda Valdelamar
-- Modificado: 27/02/2002 - Autor: Marquelda Valdelamar
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pa51d;

CREATE PROCEDURE "informix".sp_pa51d(
a_periodo   CHAR(7)     
) RETURNING	DATE,       -- Fecha de la Transaccion
			CHAR(10),	-- No Poliza
			CHAR(10),	-- No_factura
			CHAR(5),	-- No_endoso
			CHAR(10),   -- No_remesa
			INTEGER,    -- No_renglon
			CHAR(10),   -- No_requisicion
			INTEGER,    -- No_cheque
			CHAR(20),   -- No_documento
			DEC(16,2),	-- monto
			DEC(16,2),	-- monto_dbgdeta
			CHAR(20);   -- tipo_transaccion
			 	
DEFINE v_no_documento     CHAR(20);
DEFINE v_no_factura       CHAR(10);
DEFINE v_no_poliza        CHAR(10);
DEFINE v_no_endoso        CHAR(5);
DEFINE v_no_remesa        CHAR(10);
DEFINE v_no_requis        CHAR(10);
DEFINE v_renglon          INTEGER;
DEFINE v_no_cheque        INTEGER;
DEFINE v_monto_dbgdeta	  DEC(16,2);
DEFINE v_monto            DEC(16,2);
DEFINE v_tipo_tran        CHAR(20);

DEFINE _no_poliza         CHAR(10);
DEFINE _tipo_tran         CHAR(20);
DEFINE v_fecha_tran		  DATE;

LET v_no_cheque = 0;
LET v_monto     = 0.00;

FOREACH
 SELECT fecha_tran,
        no_poliza,
   	    no_endoso,
		no_remesa,
		renglon,
		no_requis,
		no_documento,
		monto,
		tipo_tran
   INTO v_fecha_tran,
        v_no_poliza,
 		v_no_endoso,
		v_no_remesa,
		v_renglon,
		v_no_requis,
 		v_no_documento,
 		v_monto_dbgdeta,
		_tipo_tran
   FROM dbgdeta
  WHERE month(fecha_tran) = a_periodo[6,7]
    AND year(fecha_tran)  = a_periodo[1,4]  

	IF _tipo_tran = "F" THEN	  -- Facturas
		
		 LET v_tipo_tran = "Factura";

		 SELECT prima_bruta,
				no_factura,
				no_poliza
		   INTO	v_monto,
				v_no_factura,
				_no_poliza
		   FROM endedmae
		  WHERE periodo       = a_periodo
		    AND no_poliza     = v_no_poliza
			AND prima_bruta   <> v_monto_dbgdeta
			AND no_endoso     = v_no_endoso; 

		   IF _no_poliza IS NOT NULL THEN

				RETURN   v_fecha_tran,
						 v_no_poliza,
						 v_no_factura,
						 v_no_endoso,
						 v_no_remesa,
						 v_renglon,
						 v_no_requis,
						 v_no_cheque,
						 v_no_documento,
						 v_monto,	 
						 v_monto_dbgdeta,
						 v_tipo_tran
				    	 WITH RESUME;
		   END IF

	ELIF _tipo_tran = "R" THEN -- Recibos

		LET v_tipo_tran = "Recibo";  

		 SELECT monto,
		        no_poliza
		   INTO v_monto,
		        _no_poliza
		   FROM cobredet
		  WHERE periodo = a_periodo
	        AND monto <> v_monto_dbgdeta
			AND actualizado = 1
	        AND no_poliza = v_no_poliza; 

			IF 	_no_poliza IS NOT NULL THEN

				RETURN v_fecha_tran,
					 v_no_poliza,
					 v_no_factura,
					 v_no_endoso,
					 v_no_remesa,
					 v_renglon,
					 v_no_requis,
					 v_no_cheque,
					 v_no_documento,
					 v_monto,	 
					 v_monto_dbgdeta,
					 v_tipo_tran
			    	 WITH RESUME;
			END IF

	ELIF _tipo_tran = "P" THEN --Cheques Pagados

		LET v_tipo_tran = "Cheque Pagago";
		
		 SELECT a.no_cheque,
		        a.monto,
				b.no_poliza
		   INTO v_no_cheque,
				v_monto,
				_no_poliza
		   FROM chqchmae a, chqchpol b
		  WHERE a.pagado          = 1
			AND a.periodo         = a_periodo
			AND a.origen_cheque   = "6"
			AND a.no_requis       = b.no_requis
			AND a.no_requis       = v_no_requis
			AND a.monto <> v_monto_dbgdeta
			AND b.no_poliza = v_no_poliza;

			IF _no_poliza IS NOT NULL THEN

				RETURN v_fecha_tran,
		    		   v_no_poliza,
			  		   v_no_factura,
					   v_no_endoso,
					   v_no_remesa,
					   v_renglon,
					   v_no_requis,
					   v_no_cheque,
					   v_no_documento,
					   v_monto,	 
					   v_monto_dbgdeta,
					   v_tipo_tran
			    	   WITH RESUME;
		    END IF

	ELIF _tipo_tran = "A" THEN --Cheques Anulados

		LET v_tipo_tran = "Cheque Anulado";

		 SELECT b.no_poliza,
				a.no_cheque,
				b.monto,
				b.no_poliza
		   INTO v_no_poliza,
				v_no_cheque,
				v_monto,
				_no_poliza
		   FROM chqchmae a, chqchpol b
		  WHERE a.anulado       = 1
		    AND a.periodo = a_periodo
			AND a.origen_cheque = "6"  --cheque de cobros
			AND a.no_requis     = b.no_requis
			AND a.monto <> v_monto_dbgdeta
			AND b.no_poliza = v_no_poliza;

			IF _no_poliza IS NOT NULL THEN

			    RETURN v_fecha_tran,
				  	   v_no_poliza,
					   v_no_factura,
					   v_no_endoso,
					   v_no_remesa,
					   v_renglon,
					   v_no_requis,
					   v_no_cheque,
					   v_no_documento,
					   v_monto,	 
					   v_monto_dbgdeta,
					   v_tipo_tran
			    	   WITH RESUME;
			END IF
	END IF

END FOREACH

END PROCEDURE