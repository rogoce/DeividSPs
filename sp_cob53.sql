-- CONSULTA DE PRIMAS POR COBRAR  para los Estados de Cuenta por Cliente
-- Creado    : 19/12/2000 - Autor: Marquelda Valdelamar 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob53;

CREATE PROCEDURE "informix".sp_cob53(
a_compania 		CHAR(3), 
a_sucursal 		CHAR(3), 
a_cod_agente    CHAR(5),
a_periodo      	CHAR(7),
a_fecha         DATE,
a_no_poliza     CHAR(10)
) RETURNING	DATE,  	   -- Fecha
			CHAR(20),  -- Referencia
			CHAR(20),  -- No. Documento
			DEC(16,2), -- Monto
			DEC(16,2), -- Prima Neta
			DEC(16,2), -- Saldo
			CHAR(7),   -- Periodo
			CHAR(10);  -- Poliza

DEFINE v_fecha		      DATE;
DEFINE v_referencia       CHAR(20);
DEFINE v_documento        CHAR(20);
DEFINE v_monto            DEC(16,2);
DEFINE v_prima            DEC(16,2);
DEFINE v_saldo            DEC(16,2);	 
DEFINE v_periodo          CHAR(7);

DEFINE _tipo_remesa      CHAR(1);
DEFINE _no_requis		 CHAR(10);
DEFINE _no_remesa		 CHAR(10);
DEFINE _pagado           SMALLINT;
DEFINE _no_documento     CHAR(20);

SET ISOLATION TO DIRTY READ;
             
CREATE TEMP TABLE tmp_saldo_cliente(
        fecha           DATE,
		no_documento    CHAR(20),
		referencia      CHAR(20),
		monto           DEC(16,2),
		prima_neta      DEC(16,2),
		periodo			CHAR(7),
		no_poliza       CHAR(10)
		) WITH NO LOG;   

 -- Lectura de Polizas	
LET v_referencia = 'FACTURA';

   FOREACH
	SELECT fecha_emision,
	       no_factura,
		   prima_bruta,
		   prima_neta,
		   periodo
	  INTO v_fecha,		
		   v_documento, 
		   v_monto,     
		   v_prima,     
		   v_periodo   
	  FROM endedmae
	 WHERE no_poliza   = a_no_poliza
	   AND actualizado = 1
	   AND prima_bruta <> 0
	   AND activa = 1

		INSERT INTO tmp_saldo_cliente(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza
		)
		VALUES(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,
		a_no_poliza   
	    );

   END FOREACH;
	FOREACH
	 SELECT no_recibo,
	        monto,
		    prima_neta,
		    no_remesa
	   INTO v_documento,
	        v_monto,
		    v_prima,
	   	    _no_remesa
	   FROM cobredet
	  WHERE no_poliza   = a_no_poliza
	    AND actualizado = 1
		AND tipo_mov IN ('P', 'N')

		LET v_monto = v_monto * -1;
		LET v_prima = v_prima * -1;

		SELECT fecha,
		       tipo_remesa,
			   periodo
		  INTO v_fecha,		
			   _tipo_remesa, 
			   v_periodo   
		  FROM cobremae
		 WHERE no_remesa = _no_remesa;

	    IF   _tipo_remesa = 'C' THEN
	      LET v_referencia = 'COMPROBANTE';
		ELSE
	      LET v_referencia = 'RECIBO';
	    END IF

		INSERT INTO tmp_saldo_cliente(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza   
		)
		VALUES(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,   
		a_no_poliza   
	    );

	END FOREACH

	LET v_referencia = 'CHEQUE';

	FOREACH
	 SELECT monto,
	        prima_neta,
	 	    no_requis
	   INTO v_monto,
	        v_prima,
	 	    _no_requis
	   FROM chqchpol
	  WHERE no_poliza = a_no_poliza

		LET v_monto = v_monto * -1;
		LET v_prima = v_prima * -1;

		SELECT fecha_impresion,
		       no_cheque,
			   periodo,
			   pagado
		  INTO v_fecha,		
			   v_documento, 
			   v_periodo,
			   _pagado   
		  FROM chqchmae
		 WHERE no_requis = _no_requis;

			IF _pagado = 1 THEN

				INSERT INTO tmp_saldo_cliente(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza   
				)
				VALUES(
				v_fecha,
				v_referencia,		
				v_documento,
				v_monto,    
				v_prima,    
				v_periodo,   
				a_no_poliza   
				);

			END IF		
END FOREACH

LET v_saldo = 0;

FOREACH
 SELECT fecha,
        referencia,
        no_documento,
        monto,
        prima_neta,
        periodo,
		no_poliza
   INTO v_fecha,
        v_referencia,
        v_documento,
        v_monto,    
        v_prima,    
        v_periodo,
        a_no_poliza 
   FROM tmp_saldo_cliente
  ORDER BY periodo, fecha, referencia, no_documento

  LET v_saldo = v_saldo + v_monto;
		 
  RETURN v_fecha,
		 v_referencia,  
		 v_documento,  
		 v_monto,      
		 v_prima, 
		 v_saldo,     
		 v_periodo,
		 a_no_poliza   
    	 WITH RESUME;
END FOREACH;

DROP TABLE tmp_saldo_cliente;
END PROCEDURE
