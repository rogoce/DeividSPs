-- Procedimiento que Genera el Informe de Caja para los pagos por tarjeta

-- Creado    : 07/07/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 07/07/2003 - Autor: Marquelda Valdelamar


--DROP PROCEDURE sp_cob120b;

CREATE PROCEDURE "informix".sp_cob120b(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)RETURNING DATE,       -- fecha
           INTEGER,    -- no_cheque
		   CHAR(50),   -- nombre del banco
		   CHAR(50),   -- girado por
		   CHAR(50),   -- a favor de
		   DEC(16,2),  -- importe
		   DEC(16,2),  -- monto efectivo
		   DEC(16,2),  -- monto cajero
		   DEC(16,2),  -- monto rutero
		   DEC(16,2),  -- 100
		   DEC(16,2),  -- 50
		   DEC(16,2),  -- 20
		   DEC(16,2),  -- 10
		   DEC(16,2),  --  5
		   DEC(16,2),  --  1
		   DEC(16,2),  --  0.50
		   DEC(16,2),  --  0.25
		   DEC(16,2),  --  0.10
		   DEC(16,2),  --  0.05
		   DEC(16,2),  --  0.01
		   CHAR(10),   -- rec_desde
		   CHAR(10),   -- rec_hasta
		   CHAR(8);    -- usuario

DEFINE _tipo_mov          CHAR(1); 
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_cliente	      CHAR(10);
DEFINE _documento         CHAR(30);
DEFINE _a_favor_de        CHAR(50); 
DEFINE _nombre_banco 	  CHAR(50);
DEFINE _no_cheque         INTEGER;
DEFINE _no_remesa         CHAR(10);
DEFINE _no_recibo         CHAR(10);
DEFINE _rec_desde         CHAR(10);
DEFINE _rec_hasta         CHAR(10);
DEFINE _fecha             DATE;
DEFINE _cod_banco         CHAR(3);
DEFINE _girado_por        CHAR(50);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _usuario           CHAR(8);
DEFINE _cien_b, _cincuenta_b, _veinte_b, _diez_b, _cinco_b, _uno_b DEC(16,2);
DEFINE _cincuenta_m, _veinticinco_m, _diez_m, _cinco_m, _uno_m     DEC(16,2);
DEFINE _monto_efectivo    DEC(16,2);
DEFINE _monto_cajero      DEC(16,2);
DEFINE _monto_rutero      DEC(16,2);
DEFINE _importe           DEC(16,2);
DEFINE _tipo_cobrador     SMALLINT;

SET ISOLATION TO DIRTY READ;

Let _monto_rutero = 0.00;
Let _monto_cajero = 0.00;
Let _monto_efectivo = 0.00;

-- Formas de Pago de los Recibos

CREATE TEMP TABLE tmp_cob120(
		no_remesa		CHAR(10)		NOT NULL,
		monto_cajero    DEC(16,2)       DEFAULT 0,	
		monto_rutero	DEC(16,2)       DEFAULT 0,
		monto_efectivo 	DEC(16,2)       DEFAULT 0,
		no_recibo       CHAR(10),
		PRIMARY KEY (no_remesa)
		) WITH NO LOG;

FOREACH
	 Select no_remesa,
	        cod_cobrador,
			user_added
	   Into _no_remesa,
	        _cod_cobrador,
			_usuario
	   From cobremae
	  Where fecha = a_fecha
		and tipo_remesa = 'A'
--	    and actualizado = 1

	 Select tipo_cobrador
	   Into _tipo_cobrador
	   From cobcobra
	  Where cod_cobrador = _cod_cobrador;
	  
	  LET _monto_cajero = 0;
	  LET _monto_rutero = 0;
	  LET _monto_efectivo = 0;

	 Select sum(importe)
	   Into _monto_efectivo
	   From cobrepag
	  where tipo_pago = 1
	    and no_remesa = _no_remesa; 	
		  	 
	  If _tipo_cobrador = 2  Then  -- Cajero  
	 	Select sum(importe)
		  Into _monto_cajero
		  From cobrepag
		 where tipo_pago in (1 , 2)
		   and no_remesa = _no_remesa; 	
	  End If

	  If _tipo_cobrador = 3 Then -- Rutero
		Select sum(monto)
		  Into _monto_rutero
		  From cobrepag
		 where tipo_pago in (1 , 2)
		   and no_remesa = _no_remesa; 	
	  End If

	 FOREACH
		 Select no_recibo
		   Into _no_recibo
		   From cobredet
		  Where no_remesa = _no_remesa
		    and tipo_mov <> 'B'
	   EXIT FOREACH;
	 END FOREACH

     BEGIN
	 	ON EXCEPTION
		  UPDATE tmp_cob120
		     SET monto_cajero = monto_cajero + _monto_cajero,
			     monto_rutero = monto_rutero + _monto_rutero,
			     monto_efectivo = monto_efectivo + _monto_efectivo
		   WHERE no_remesa = _no_remesa;
		END EXCEPTION

		INSERT INTO tmp_cob120(
		no_remesa,
		monto_cajero,
		monto_rutero,
		monto_efectivo,
		no_recibo
		)
		VALUES(
		_no_remesa,
		_monto_cajero,
		_monto_rutero,
		_monto_efectivo,
		_no_recibo
		);
	 END
  
END FOREACH

Select sum(monto_cajero),
       sum(monto_rutero),
	   sum(monto_efectivo)
  Into _monto_cajero,
       _monto_rutero,
	   _monto_efectivo
  From tmp_cob120;

Select min(no_recibo)
  Into _rec_desde
  From tmp_cob120;

Select max(no_recibo)
  Into _rec_hasta
  From tmp_cob120;

Select bilcien, bilcinc, bilvein, bildiez, bilcinco, biluno,
       moncinc, monvein, mondiez, moncinco, monuno
  Into _cien_b, _cincuenta_b, _veinte_b, _diez_b, _cinco_b, _uno_b,
       _cincuenta_m, _veinticinco_m, _diez_m, _cinco_m, _uno_m
  From cobcieca
 Where fecha = a_fecha;
--   and actualizado = 1;

Foreach
 Select no_remesa,
        cod_cobrador,
		user_added
   Into _no_remesa,
        _cod_cobrador,
		_usuario
   From cobremae
  Where fecha = a_fecha
	and tipo_remesa = 'A'
--    and actualizado = 1

   Foreach
	Select fecha,
	       no_cheque,
	       cod_banco,
	       girado_por,
	       a_favor_de,
	       importe 
	  Into _fecha,
	       _no_cheque,
	       _cod_banco,
		   _girado_por,
		   _a_favor_de,
		   _importe
	  From cobrepag
	 Where no_remesa = _no_remesa
	   and tipo_pago = 2

		 Select alias
		   Into _nombre_banco
		   From chqbanco
		  Where cod_banco = _cod_banco;

	Return _fecha,
	       _no_cheque,
	 	   _nombre_banco,
	 	   Trim(_girado_por),
	 	   Trim(_a_favor_de),
	 	   _importe,
		   _monto_efectivo,
		   _monto_cajero,
		   _monto_rutero,
		   _cien_b * 100, 
		   _cincuenta_b * 50, 
		   _veinte_b * 20, 
		   _diez_b * 10, 
		   _cinco_b * 5, 
		   _uno_b * 1,
		   _cincuenta_m * 0.5, 
		   _veinticinco_m * 0.25, 
		   _diez_m * 0.1, 
		   _cinco_m * 0.05, 
		   _uno_m * 0.01,
		   _rec_desde,
		   _rec_hasta,
		   _usuario
	 	   WITH RESUME;

   End Foreach

End Foreach

drop table tmp_cob120;

END PROCEDURE
