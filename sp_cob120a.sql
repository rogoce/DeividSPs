-- Procedimiento que Genera los TOTALES PARA EL CIERRE DE CAJA
-- Creado    : 16/10/2003 - Autor: Amado Perez 
-- Modificado: 16/10/2003 - Autor: Amado Perez


DROP PROCEDURE sp_cob120a;

CREATE PROCEDURE "informix".sp_cob120a(
a_fecha    DATE
)RETURNING DEC(16,2),  -- monto efectivo
		   DEC(16,2);  -- monto cheque

DEFINE _no_remesa         CHAR(10);
DEFINE _no_recibo         CHAR(10);
DEFINE _rec_desde         CHAR(10);
DEFINE _rec_hasta         CHAR(10);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _usuario           CHAR(8);

DEFINE _monto_efectivo    DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _tipo_cobrador     SMALLINT;

SET ISOLATION TO DIRTY READ;

Let _monto_cheque = 0.00;
Let _monto_efectivo = 0.00;

-- Formas de Pago de los Recibos

CREATE TEMP TABLE tmp_cob120(
		no_remesa		CHAR(10)		NOT NULL,
		monto_cheque	DEC(16,2)       DEFAULT 0,
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
	    and actualizado = 1
		and (tipo_remesa = 'A' OR tipo_remesa = 'M')

	 Select tipo_cobrador
	   Into _tipo_cobrador
	   From cobcobra
	  Where cod_cobrador = _cod_cobrador;
	  
	  LET _monto_efectivo = 0;
      LET _monto_cheque = 0;

	 Select sum(importe)
	   Into _monto_efectivo
	   From cobrepag
	  where tipo_pago = 1
	    and no_remesa = _no_remesa; 	
		  	 
 	 Select sum(importe)
	   Into _monto_cheque
	   From cobrepag
	  where tipo_pago = 2
	    and no_remesa = _no_remesa; 	

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
		     SET monto_cheque = monto_cheque + _monto_cheque,
			     monto_efectivo = monto_efectivo + _monto_efectivo
		   WHERE no_remesa = _no_remesa;
		END EXCEPTION

		INSERT INTO tmp_cob120(
		no_remesa,
		monto_cheque,
		monto_efectivo,
		no_recibo
		)
		VALUES(
		_no_remesa,
		_monto_cheque,
		_monto_efectivo,
		_no_recibo
		);
	 END
  
END FOREACH

Select sum(monto_cheque),
	   sum(monto_efectivo)
  Into _monto_cheque,
	   _monto_efectivo
  From tmp_cob120;

if _monto_cheque is null then
 let _monto_cheque = 0;
end if

if _monto_efectivo is null then
 let _monto_efectivo = 0;
end if

Return _monto_efectivo,
	   _monto_cheque
 	   WITH RESUME;

{Select min(no_recibo)
  Into _rec_desde
  From tmp_cob120;

Select max(no_recibo)
  Into _rec_hasta
  From tmp_cob120;}


drop table tmp_cob120;

END PROCEDURE
