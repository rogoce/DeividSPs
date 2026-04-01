-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar 
-- Modificado por : Victor Molinar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob36;

CREATE PROCEDURE "informix".sp_cob36(a_docto CHAR(20), a_cliente CHAR(10), a_corredor CHAR(5));
 
RETURNING	CHAR(10),
			CHAR(50),
			CHAR(10),
			CHAR(20),
			CHAR(10),
			DATE,
			DATE,
			CHAR(5),
			CHAR(3),
			CHAR(3),
	        DATE,
			CHAR(20),
			CHAR(20),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo4;

CREATE TEMP TABLE tmp_saldo4(
		asegurado       CHAR(10),
		direccion       CHAR(50),
		telefono        CHAR(10),
		apartado        CHAR(20),
		poliza          CHAR(10),
		vigencia_1      DATE,
		vigencia_2 		DATE,
		corredor        CHAR(5),
		ramo            CHAR(3),
		subramo         CHAR(3),
        fecha           DATE,
		referencia      CHAR(20),
		no_documento    CHAR(20),
		debito          DEC(16,2),
		credito         DEC(16,2),
		saldo           DEC(16,2)
		) WITH NO LOG;   

 -- Lectura de Polizas	

FOREACH
 SELECT no_factura, prima INTO _no_factura, _prima
   FROM endedmae
  WHERE no_documento = a_docto
    AND actualizado  = 1

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
	 WHERE no_poliza   = _no_poliza
	   AND actualizado = 1
	   AND prima_bruta <> 0

		INSERT INTO tmp_saldo4(
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
		_no_poliza   
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
	  WHERE no_poliza   = _no_poliza
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

		INSERT INTO tmp_saldo4(
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
		_no_poliza   
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
	  WHERE no_poliza = _no_poliza

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

				INSERT INTO tmp_saldo4(
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
				_no_poliza   
				);

			END IF
			
	END FOREACH

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
        _no_poliza 
   FROM tmp_saldo4
  ORDER BY periodo, fecha, referencia, no_documento

  LET v_saldo = v_saldo + v_monto;
		 
  RETURN v_fecha,
		 v_referencia,  
		 v_documento,  
		 v_monto,      
		 v_prima, 
		 v_saldo,     
		 v_periodo,
		 _no_poliza   
    	 WITH RESUME;

END FOREACH;

DROP TABLE tmp_saldo4;

END PROCEDURE
