--Informe que muestra la los saldos de dbgacum
 
-- Creado    : 16/02/2002 - Autor: Marquelda Valdelamar 
-- Modificado: 18/02/2002 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pa51b;

CREATE PROCEDURE "informix".sp_pa51b(a_periodo	CHAR(7) 
) RETURNING	DATE,  	   -- fecha_tran
			DEC(16,2), -- monto_factura
			DEC(16,2), -- monto_pago
			DEC(16,2), -- monto_cheque
			DEC(16,2), -- monto_anulado
			DEC(16,2), -- saldo inicial
			DEC(16,2), -- saldo	acumulado
			DEC(16,2); -- saldo del dia

DEFINE _monto_factura    DEC(16,2);
DEFINE _monto_pago       DEC(16,2);
DEFINE _monto_cheque     DEC(16,2);
DEFINE _monto_anulado    DEC(16,2);
DEFINE _saldo            DEC(16,2);
DEFINE _saldo_inicial    DEC(16,2);
DEFINE _saldo_acum       DEC(16,2);
DEFINE _saldo_dia        DEC(16,2);
DEFINE _valor            INTEGER;
DEFINE _ano              INTEGER;
DEFINE _mes              CHAR(2);
DEFINE _mes_string       CHAR(7);
DEFINE _ano_string       CHAR(4);
DEFINE _fecha_tran       DATE;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pa51b.trc";
--trace on;

LET _saldo 			= 0.00;
LET _saldo_acum		= 0.00;
LET _saldo_dia      = 0.00;

--Validacion del mes en caso de que sea Enero

IF a_periodo[6,7] = "01" THEN

   LET _ano_string = integer(a_periodo[1,4]) - 1; 
   LET _mes_string = _ano_string || "-12";

ELSE

	LET _mes = a_periodo[6,7] - 1;
	LET _ano_string = a_periodo[1,4]; 

	IF _mes < 10 THEN
	    LET _mes_string = "0" || _mes;
	ELSE
	    LET _mes_string = _mes;
	END IF

	LET _mes_string = _ano_string || "-"|| _mes_string;
					  
END IF

-- Selecciona el saldo del mes anterior									 
	SELECT saldo       
	  INTO _saldo_inicial
	  FROM dbgsaldo
	 WHERE periodo = _mes_string;
	
	IF _saldo_inicial IS NULL THEN
		LET _saldo_inicial = 0.00;
	END IF

-- Insertar un registro en blanco en dbgsaldo si no hay registros para el mes actual
	SELECT COUNT(*)
	  INTO _valor
	  FROM dbgsaldo
	 WHERE periodo = a_periodo;

	IF _valor = 0 THEN

		Insert Into dbgsaldo(
	  		      	 periodo,
				     saldo
					 )
				 	Values(
				 	 a_periodo,
				 	 0.00
				 	 );
	ELSE

		UPDATE dbgsaldo
		   SET saldo   = 0.00
		 WHERE periodo = a_periodo;

	END IF

	FOREACH
	 SELECT fecha_tran,
	        monto_factura,
			monto_pago,
			monto_cheque,
			monto_anulado
	   INTO _fecha_tran,
	        _monto_factura,
			_monto_pago,
			_monto_cheque,
			_monto_anulado
	   FROM dbgacum
	  WHERE month(fecha_tran) = a_periodo[6,7]
	    AND  year(fecha_tran) = a_periodo[1,4]
	ORDER BY fecha_tran

	--Calculo del saldo actual
		LET _saldo_acum = _monto_factura + _monto_pago + _monto_cheque - _monto_anulado + _saldo_inicial;
        LET _saldo_dia  = _monto_factura + _monto_pago + _monto_cheque - _monto_anulado;

		UPDATE dbgsaldo 
		   SET dbgsaldo.periodo = a_periodo,
			   dbgsaldo.saldo   = dbgsaldo.saldo + _saldo_acum
		WHERE  dbgsaldo.periodo = a_periodo;

	  RETURN _fecha_tran,
			 _monto_factura,  
			 _monto_pago,
			 _monto_cheque,
			 _monto_anulado,
			 _saldo_inicial,
			 _saldo_acum,
			 _saldo_dia
	    	 WITH RESUME;

END FOREACH;

END PROCEDURE
