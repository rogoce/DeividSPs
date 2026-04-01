-- Verificacion Entre Estado de Cuenta y Morosidad

-- Creado    : 30/05/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 30/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis24;

CREATE PROCEDURE "informix".sp_sis24(
a_compania     CHAR(3), 
a_sucursal     CHAR(3))
RETURNING	CHAR(20),  -- No. Documento
			DEC(16,2), -- Monto	Estado Cuenta
			DEC(16,2), -- Monto Morosidad
			DEC(16,2), -- Monto Suma
			DEC(16,2), -- Montos Saldos
			CHAR(50);  -- Compania	

DEFINE a_no_documento    CHAR(20); 
DEFINE v_monto_est       DEC(16,2);
DEFINE v_monto_mor       DEC(16,2);
DEFINE v_monto_sal       DEC(16,2);
DEFINE v_monto_sum       DEC(16,2);

DEFINE _no_poliza        CHAR(10); 
DEFINE _no_requis        CHAR(10); 
DEFINE _pagado           SMALLINT; 
DEFINE _anulado          SMALLINT; 

DEFINE a_fecha           DATE;     
DEFINE a_periodo         CHAR(7);  
DEFINE _cantidad         INTEGER;  
DEFINE v_compania_nombre CHAR(50); 

LET a_fecha   = MDY(12,31,9999);
LET a_periodo = '9999-12';

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

--DROP TABLE tmp_saldo;

CREATE TEMP TABLE tmp_saldo(
		no_documento	CHAR(20),
		monto_est       DEC(16,2),
		monto_mor      	DEC(16,2),
		monto_sal       DEC(16,2),
		monto_sum       DEC(16,2)
		) WITH NO LOG;   

LET _cantidad = 0;

FOREACH
 SELECT no_documento
   INTO a_no_documento
   FROM emipomae
  GROUP BY no_documento

{
	LET _cantidad = _cantidad + 1;

	IF _cantidad > 1000 THEN
		EXIT FOREACH;
	END IF
}

-- Saldos de Polizas

SELECT SUM(saldo)
  INTO v_monto_sum
  FROM emipomae
 WHERE no_documento = a_no_documento
   AND actualizado  = 1;

INSERT INTO tmp_saldo
VALUES(
a_no_documento,
0,    
0,
0,
v_monto_sum
);

-- Estado de Cuenta

FOREACH
 SELECT no_poliza
   INTO _no_poliza
   FROM emipomae
  WHERE no_documento = a_no_documento
    AND actualizado  = 1

   FOREACH
	SELECT prima_bruta
	  INTO v_monto_est
	  FROM endedmae
	 WHERE no_poliza   = _no_poliza
	   AND actualizado = 1
	   AND activa      = 1
	   AND prima_bruta <> 0

		INSERT INTO tmp_saldo
		VALUES(
		a_no_documento,
		v_monto_est,    
		0,
		0,
		0
	    );

   END FOREACH;

	FOREACH
	 SELECT monto
	   INTO v_monto_est
	   FROM cobredet
	  WHERE no_poliza   = _no_poliza
	    AND actualizado = 1
		AND tipo_mov IN ('P', 'N')

		LET v_monto_est = v_monto_est * -1;

		INSERT INTO tmp_saldo
		VALUES(
		a_no_documento,
		v_monto_est,    
		0,
		0,
		0
	    );

	END FOREACH

	FOREACH
	 SELECT monto,
			no_requis
	   INTO v_monto_est,
			_no_requis
	   FROM chqchpol
	  WHERE no_poliza = _no_poliza

		SELECT pagado,
			   anulado
		  INTO _pagado,
			   _anulado
		  FROM chqchmae
		 WHERE no_requis = _no_requis;

			IF _pagado  = 1 AND
			   _anulado = 0 THEN

				INSERT INTO tmp_saldo
				VALUES(
				a_no_documento,
				v_monto_est,
				0,
				0,
				0    
				);

			END IF
			
	END FOREACH

END FOREACH

BEGIN 

DEFINE _monto           DEC(16,2);
DEFINE _monto_cheque    DEC(16,2);
DEFINE _fecha_impresion DATE;     
DEFINE _fecha_anulado   DATE;     

LET v_monto_sal = 0;

FOREACH
 SELECT prima_bruta
   INTO _monto
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1
		LET v_monto_sal = v_monto_sal + _monto;
END FOREACH

-- Recibos

FOREACH
 SELECT monto
   INTO _monto
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')		-- Pago de Prima(P) y Notas de Credito(N)
     AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros
		LET v_monto_sal = v_monto_sal - _monto;
END FOREACH

-- Cheques de Devolucion de Primas

FOREACH
 SELECT monto,
        no_requis
   INTO _monto_cheque,
	   _no_requis	
   FROM chqchpol
  WHERE no_documento   = a_no_documento

	SELECT pagado,
		   fecha_impresion,
		   fecha_anulado
	  INTO _pagado,
		   _fecha_impresion,
		   _fecha_anulado
	  FROM chqchmae
	 WHERE no_requis = _no_requis;

	IF _pagado = 1 THEN
		IF _fecha_impresion > a_fecha THEN
			LET _monto_cheque = 0;
		ELSE
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado <= a_fecha	THEN
					LET _monto_cheque = 0;
				END IF
			END IF
		END IF				
	ELSE
		LET _monto_cheque = 0;
	END IF	
	
	IF _monto_cheque IS NULL THEN
		LET _monto_cheque = 0;
	END IF		

	LET v_monto_sal = v_monto_sal + _monto_cheque;	

END FOREACH

INSERT INTO tmp_saldo
VALUES(
a_no_documento,
0,
0,
v_monto_sal,
0    
);

END 

-- Inicio del Proceso de Determinar la Morosidad de las Facturas

BEGIN

DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);

CALL sp_cob33(
	 a_compania,
	 a_sucursal,	
	 a_no_documento,
	 a_periodo,
	 a_fecha
	 ) RETURNING v_por_vencer,       
				 v_exigible,         
				 v_corriente,        
				 v_monto_30,         
				 v_monto_60,         
				 v_monto_90,
				 v_saldo;         


INSERT INTO tmp_saldo
VALUES(
a_no_documento,
0,
(v_por_vencer + v_exigible),
0,
0    
);

END

END FOREACH

LET _cantidad = 0;

FOREACH
 SELECT no_documento,
        SUM(monto_est),
		SUM(monto_mor),
		SUM(monto_sal),
		SUM(monto_sum)
   INTO a_no_documento,
        v_monto_est,
		v_monto_mor,
		v_monto_sal,
		v_monto_sum
   FROM tmp_saldo
  GROUP BY no_documento
  ORDER BY no_documento[1,2], no_documento[3,4], no_documento

	IF v_monto_est <> v_monto_mor OR
	   v_monto_est <> v_monto_sal OR
	   v_monto_est <> v_monto_sum OR   
	   v_monto_mor <> v_monto_sal OR
	   v_monto_mor <> v_monto_sum OR
	   v_monto_sal <> v_monto_sum THEN

--		LET _cantidad = _cantidad + 1;

--		IF _cantidad < 10 THEN

			{
			LET _no_poliza = sp_sis21(a_no_documento);

			UPDATE emipomae
			   SET saldo        = 0
			 WHERE no_documento = a_no_documento
			   AND actualizado  = 1;
			
			UPDATE emipomae
			   SET saldo       = v_monto_est
			 WHERE no_poliza   = _no_poliza;
			--}

--		END IF


		RETURN a_no_documento,  
			   v_monto_est,      
			   v_monto_mor,      
			   v_monto_sal,      
			   v_monto_sum,
			   v_compania_nombre      
			   WITH RESUME;

	END IF

END FOREACH

DROP TABLE tmp_saldo;

END PROCEDURE
