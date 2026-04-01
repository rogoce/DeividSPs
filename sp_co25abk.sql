-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar 
-- Modificado: 21/03/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co25abk;

CREATE PROCEDURE "informix".sp_co25abk(
a_compania 		CHAR(3), 
a_sucursal 		CHAR(3), 
a_no_documento  CHAR(20),
a_periodo       CHAR(7),
a_fecha         DATE
) RETURNING	DATE,  	   -- Fecha
			CHAR(20),  -- Referencia
			CHAR(20),  -- No. Documento
			DEC(16,2), -- Monto
			DEC(16,2), -- Prima Neta
			DEC(16,2), -- Saldo
			CHAR(7),   -- Periodo
			CHAR(10),  -- Poliza
			CHAR(30);  -- Tipo factura

DEFINE v_fecha		      DATE;
DEFINE v_referencia       CHAR(20);
DEFINE v_documento        CHAR(20);
DEFINE v_monto            DEC(16,2);
DEFINE v_prima            DEC(16,2);
DEFINE v_saldo            DEC(16,2);	 
DEFINE v_periodo          CHAR(7);
DEFINE v_cod_endomov      CHAR(3);
DEFINE v_cod_tipocan      CHAR(3);
DEFINE _cod_tipoprod      CHAR(3);

DEFINE _no_poliza        CHAR(10);
DEFINE _tipo_fac         CHAR(30);
DEFINE _nueva_renov      CHAR(1);
DEFINE _tipo_remesa      CHAR(1);
DEFINE _no_requis		 CHAR(10);
DEFINE _no_remesa		 CHAR(10);
DEFINE _pagado           SMALLINT;
DEFINE _anulado          SMALLINT;
DEFINE _cod_banco        CHAR(3);
DEFINE _tipo_mov         CHAR(1);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo;

CREATE TEMP TABLE tmp_saldo3(
        fecha           DATE,
		referencia      CHAR(20),
		no_documento    CHAR(20),
		monto           DEC(16,2),
		prima_neta      DEC(16,2),
		periodo			CHAR(7),
		no_poliza       CHAR(10),
		tipo_fac        CHAR(30)
		) WITH NO LOG;   

FOREACH
 SELECT no_poliza,
        nueva_renov
   INTO _no_poliza,
        _nueva_renov
   FROM emipomae
  WHERE no_documento = a_no_documento
    AND actualizado  = 1
--	AND periodo      <= a_periodo
   	
	LET v_referencia = 'FACTURA';

   FOREACH
	SELECT fecha_emision,
	       no_factura,
		   prima_bruta,
		   prima_neta,
		   periodo,
		   cod_endomov,   
		   cod_tipocan
	  INTO v_fecha,		
		   v_documento, 
		   v_monto,     
		   v_prima,     
		   v_periodo,
		   v_cod_endomov,   
		   v_cod_tipocan
	  FROM endedmae
	 WHERE no_poliza   = _no_poliza
	   AND actualizado = 1
	   AND prima_bruta <> 0
	   AND activa = 1
--	   AND periodo <= a_periodo

		-- Tipo de Factura

		LET _tipo_fac = "";

		IF v_cod_endomov = '011' THEN
			IF _nueva_renov = 'N' THEN
			   LET _tipo_fac = 'NUEVA';
			ELSE			 
			   LET _tipo_fac = 'RENOVACION';
			END IF
		ELIF v_cod_endomov = '002' THEN
		     SELECT nombre
		       INTO	_tipo_fac
		       FROM endtican
		      WHERE cod_tipocan = v_cod_tipocan;
		ELSE
 		     SELECT nombre                       
 		       INTO	_tipo_fac                    
 		       FROM endtimov                     
 		      WHERE cod_endomov = v_cod_endomov; 
		END IF

		INSERT INTO tmp_saldo3(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza,
		tipo_fac
		)
		VALUES(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,
		_no_poliza,
		_tipo_fac
	    );

   END FOREACH;

	FOREACH
	 SELECT no_recibo,
	        monto,
		    prima_neta,
		    no_remesa,
			tipo_mov
	   INTO v_documento,
	        v_monto,
		    v_prima,
	   	    _no_remesa,
			_tipo_mov
	   FROM cobredet
	  WHERE no_poliza   = _no_poliza
	    AND actualizado = 1
		AND tipo_mov IN ('P', 'N', 'X')
 --		AND periodo <= a_periodo

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
		  if _tipo_mov = 'X' then
		      LET v_referencia = 'AJUSTE';
		  else
		      LET v_referencia = 'RECIBO';
		  end if
	    END IF

		LET _tipo_fac = 'REMESA ' || _no_remesa;

		INSERT INTO tmp_saldo3(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza,
		tipo_fac
		)
		VALUES(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,   
		_no_poliza,
		_tipo_fac
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

--		LET v_monto = v_monto * -1;
--		LET v_prima = v_prima * -1;

		SELECT fecha_impresion,
		       no_cheque,
			   periodo,
			   pagado,
			   cod_banco,
			   anulado
		  INTO v_fecha,		
			   v_documento, 
			   v_periodo,
			   _pagado,
			   _cod_banco,   
			   _anulado
		  FROM chqchmae
		 WHERE no_requis = _no_requis;

        SELECT nombre
		 INTO  _tipo_fac
		 FROM  chqbanco
		 WHERE cod_banco = _cod_banco;

			IF _pagado  = 1 AND
			   _anulado = 0 THEN

				INSERT INTO tmp_saldo3(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac
				)
				VALUES(
				v_fecha,
				v_referencia,		
				v_documento,
				v_monto,    
				v_prima,    
				v_periodo,   
				_no_poliza,
				_tipo_fac
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
		no_poliza,
		tipo_fac
   INTO v_fecha,
        v_referencia,
        v_documento,
        v_monto,    
        v_prima,    
        v_periodo,
        _no_poliza,
		_tipo_fac
   FROM tmp_saldo3
  ORDER BY periodo, fecha, referencia, no_documento

  LET v_saldo = v_saldo + v_monto;
		 
  RETURN v_fecha,
		 v_referencia,  
		 v_documento,  
		 v_monto,      
		 v_prima, 
		 v_saldo,     
		 v_periodo,
		 _no_poliza,
		 _tipo_fac
    	 WITH RESUME;

END FOREACH;

DROP TABLE tmp_saldo3;

END PROCEDURE
