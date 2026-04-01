-- Procedimiento que Genera el Informe de Caja

-- Creado    : 07/07/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 07/07/2003 - Autor: Marquelda Valdelamar


DROP PROCEDURE sp_cob120;
CREATE PROCEDURE "informix".sp_cob120(
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
		   CHAR(10),   -- rec_desde
		   CHAR(10),   -- rec_hasta
		   CHAR(8),    -- usuario
		   DEC(16,2);

DEFINE _tipo_mov, _tipo_remesa CHAR(1); 
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_cliente	      CHAR(10);
DEFINE _documento         CHAR(30);
DEFINE _a_favor_de        CHAR(50); 
DEFINE _nombre_banco 	  CHAR(50);
DEFINE _no_cheque         INTEGER;
DEFINE _no_remesa         CHAR(10);
DEFINE _no_recibo, _rec_m_max, _rec_m_min CHAR(10);
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
define _m_efectivo_rut    DEC(16,2);
define _stipo_cheque      varchar(30);
DEFINE _tipo_cobrador     SMALLINT;
DEFINE _cant_cheques      INT;
define _tipo_cheque       smallint;

SET ISOLATION TO DIRTY READ;

Let _monto_rutero = 0.00;
Let _monto_cajero = 0.00;
Let _monto_efectivo = 0.00;
Let _m_efectivo_rut = 0.00;
Let _rec_m_max = "";
Let _rec_m_min = "";
Let _no_recibo = "";
Let _rec_desde = "";
Let _rec_hasta = "";
Let _no_remesa = "";
Let _usuario   = "";
Let _cod_cobrador = "";

-- Formas de Pago de los Recibos

CREATE TEMP TABLE tmp_cob120(
		no_remesa		CHAR(10)		NOT NULL,
		monto_cajero    DEC(16,2)       DEFAULT 0,	
		monto_rutero	DEC(16,2)       DEFAULT 0,
		monto_efectivo 	DEC(16,2)       DEFAULT 0,
		no_recibo       CHAR(10),
		rec_m_max       CHAR(10),
		rec_m_min       CHAR(10),
		efectivo_rut    DEC(16,2)       DEFAULT 0,
		PRIMARY KEY (no_remesa)
		) WITH NO LOG;
--set debug file to "sp_cob120.trc";
--trace on;

FOREACH
	 Select no_remesa,
	        cod_cobrador,
			user_added,
			tipo_remesa
	   Into _no_remesa,
	        _cod_cobrador,
			_usuario,
			_tipo_remesa
	   From cobremae
	  Where fecha = a_fecha
		and tipo_remesa in('A','M')
	    and actualizado = 1
		and cod_sucursal = a_agencia
	  order by cod_cobrador

	 Select tipo_cobrador
	   Into _tipo_cobrador
	   From cobcobra
	  Where cod_cobrador = _cod_cobrador;
	  
	  LET _monto_cajero   = 0;
	  LET _monto_rutero   = 0;
	  LET _monto_efectivo = 0;
	  let _m_efectivo_rut = 0;

	 Select sum(importe)
	   Into _monto_efectivo
	   From cobrepag
	  where tipo_pago = 1
	    and no_remesa = _no_remesa;
	    	
	  IF  _tipo_remesa = 'A' or _tipo_remesa = 'M' THEN

		if _tipo_cobrador = 2 then		-- Cajero

		 	 Select sum(importe)
			   Into _monto_cajero
			   From cobrepag
			  where tipo_pago in (1 , 2)
			    and no_remesa = _no_remesa;

		elif _tipo_cobrador = 3 then	-- Rutero

			Select sum(importe)
			  Into _monto_rutero
			  From cobrepag
			 where tipo_pago in (1 , 2)
			   and no_remesa = _no_remesa;

			Select sum(importe)
			  Into _m_efectivo_rut
			  From cobrepag
			 where tipo_pago in (1)
			   and no_remesa = _no_remesa;			   

		end if
	  End If

      If _tipo_remesa = 'M' Then
		 Select MIN(no_recibo)
		   Into _rec_m_min
		   From cobredet
		  Where no_remesa = _no_remesa
		    and tipo_mov <> 'B';

 		 Select MAX(no_recibo)
		   Into _rec_m_max
		   From cobredet
		  Where no_remesa = _no_remesa
		    and tipo_mov <> 'B';
	  End If

  	 IF _tipo_remesa = 'A' THEN
		 FOREACH
			 Select no_recibo
			   Into _no_recibo
			   From cobredet
			  Where no_remesa = _no_remesa
			    and tipo_mov <> 'B'
		   EXIT FOREACH;
		 END FOREACH
  	 END IF

     BEGIN
	 	ON EXCEPTION
		  UPDATE tmp_cob120
		     SET monto_cajero = monto_cajero + _monto_cajero,
			     monto_rutero = monto_rutero + _monto_rutero,
			     monto_efectivo = monto_efectivo + _monto_efectivo,
				 efectivo_rut   = efectivo_rut + _m_efectivo_rut
		   WHERE no_remesa = _no_remesa;
		END EXCEPTION

		INSERT INTO tmp_cob120(
		no_remesa,
		monto_cajero,
		monto_rutero,
		monto_efectivo,
		no_recibo,
		rec_m_max,
		rec_m_min,
		efectivo_rut
		)
		VALUES(
		_no_remesa,
		_monto_cajero,
		_monto_rutero,
		_monto_efectivo,
		_no_recibo,
		_rec_m_max,
		_rec_m_min,
		_m_efectivo_rut
		);
	 END
  
END FOREACH

Select sum(monto_cajero),
       sum(monto_rutero),
	   sum(monto_efectivo),
	   sum(efectivo_rut)
  Into _monto_cajero,
       _monto_rutero,
	   _monto_efectivo,
	   _m_efectivo_rut
  From tmp_cob120;

Select min(no_recibo)
  Into _rec_desde
  From tmp_cob120;

Select max(no_recibo)
  Into _rec_hasta
  From tmp_cob120;

Select min(rec_m_min)
  Into _rec_m_min
  From tmp_cob120
 Where rec_m_min <> "" ;

Select max(rec_m_max)
  Into _rec_m_max
  From tmp_cob120
 Where rec_m_max <> "" ;

Select sum(bilcien), sum(bilcinc), sum(bilvein), sum(bildiez), sum(bilcinco), sum(biluno),
       sum(moncinc), sum(monvein), sum(mondiez), sum(moncinco), sum(monuno)
  Into _cien_b, _cincuenta_b, _veinte_b, _diez_b, _cinco_b, _uno_b,
       _cincuenta_m, _veinticinco_m, _diez_m, _cinco_m, _uno_m
  From cobcieca
 Where fecha = a_fecha
   and cod_chequera in (Select cod_chequera from cobcobra where cod_compania = a_compania and cod_sucursal = a_agencia and cod_chequera is not null);
--   and actualizado = 1;

Select count(*)
  Into _cant_cheques
  From cobrepag a, tmp_cob120 b
 Where tipo_pago = 2
   and a.no_remesa = b.no_remesa;

If _cant_cheques > 0 Then

	Foreach
	 Select no_remesa
	   Into _no_remesa
	   From tmp_cob120

	 Select cod_cobrador,
			user_added
	   Into _cod_cobrador,
			_usuario
	   From cobremae
	  Where no_remesa = _no_remesa;

	   Foreach
		Select fecha,
		       no_cheque,
		       cod_banco,
		       girado_por,
		       tipo_cheque,
		       importe 
		  Into _fecha,
		       _no_cheque,
		       _cod_banco,
			   _girado_por,
			   _tipo_cheque,
			   _importe
		  From cobrepag
		 Where no_remesa = _no_remesa
		   and tipo_pago = 2

			 Select alias
			   Into _nombre_banco
			   From chqbanco
			  Where cod_banco = _cod_banco;
			  
			if _tipo_cheque = 1 then
				let _stipo_cheque = "Cheque Gerencia";
			elif _tipo_cheque = 2 then
				let _stipo_cheque = "Cheque Local";
			elif _tipo_cheque = 3 then
				let _stipo_cheque = "Cheque Extranjero";
			else
				let _stipo_cheque = " ";
			end if	  

		Return _fecha,
		       _no_cheque,
		 	   _nombre_banco,
		 	   Trim(_girado_por),
		 	   _stipo_cheque,
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
			   _rec_m_min,
			   _rec_m_max,
			   _usuario,
			   _m_efectivo_rut
		 	   WITH RESUME;
	   End Foreach

	End Foreach
Else
		Return null,
		       null,
		 	   null,
		 	   null,
		 	   null,
		 	   null,
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
			   _rec_m_min,
			   _rec_m_max,
			   _usuario,
			   _m_efectivo_rut
		 	   WITH RESUME;
End If

drop table tmp_cob120;

END PROCEDURE
