-- Procedimiento que Carga las tablas dbgacum, dbgdeta, dbgsaldo
-- para el proceso de verificacion de datos

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/02/2002 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pa51a;

create procedure sp_pa51a(a_compania CHAR, a_fecha date) returning smallint, char(100);

DEFINE _no_endoso		CHAR(5);
DEFINE _periodo			CHAR(7);
DEFINE _no_poliza		CHAR(10);
DEFINE _no_requis		CHAR(10);
DEFINE _no_remesa		CHAR(10);
DEFINE _no_factura		CHAR(10);
DEFINE _no_documento	CHAR(20);
DEFINE _tipo_tran       CHAR(1);
DEFINE _mes				CHAR(2);
DEFINE _ano				CHAR(4);
DEFINE _cod_tipoprod1   CHAR(3);
DEFINE _mes_string      CHAR(2);
DEFINE _cob_periodo     CHAR(7);
DEFINE _periodo_tran    CHAR(7);

DEFINE _error			SMALLINT;
DEFINE _cantidad		SMALLINT;
DEFINE _renglon			SMALLINT;

DEFINE _valor           INTEGER; 
DEFINE _valor2          INTEGER; 
DEFINE _consecutivo		INTEGER;

DEFINE _monto           DEC(16,2);

DEFINE _date_added      DATE;
--DEFINE _fecha           DATE;

LET _cantidad = 0;
LET _valor    = 0;
LET _valor2   = 0;
LET _monto    = 0.00;

--set debug file to "sp_pa51a.trc";
--trace on;

BEGIN

on exception set _error 
	rollback work;
 	return _error, 'Error al Actualizar los Registros del Dia: ' || a_fecha;         
end exception           

begin work;

SELECT date_added
  INTO _date_added
  FROM dbgfecha
 WHERE fecha = a_fecha;

IF _date_added IS NOT NULL THEN
	Rollback Work;
	Return 1, "Esta Fecha ya fue Procesada el " || _date_added;
END IF

INSERT INTO dbgfecha(
	fecha,
	date_added
	)
	values(
	a_fecha,
	today	  
	);

--Selecciona los registros de hoy
select count(*)
  into _valor
  from dbgacum
 where fecha_tran = a_fecha;

IF _valor = 0 then

	Insert Into dbgacum(
	fecha_tran,		
	monto_factura,
	monto_pago,
	monto_cheque,
	monto_anulado
	)
	values(
	a_fecha,
	0.00,
	0.00,
	0.00,
	0.00
	);

END IF

SELECT Max(consecutivo)
  INTO _consecutivo
  FROM dbgdeta;

if _consecutivo is null then
	let _consecutivo = 0;
end if

-- Seleccion del codigo del tipoprod para excluir el reaseguro asumido

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

-- Facturas
FOREACH
 SELECT a.no_poliza,
        a.no_endoso,
		a.prima_bruta,
		a.no_documento,
		a.periodo
   INTO	_no_poliza,
        _no_endoso,
		_monto,
		_no_documento,
		_periodo_tran
   FROM endedmae a, emipomae b
  WHERE a.fecha_emision  = a_fecha
    AND a.actualizado    = 1
	AND a.no_poliza      = b.no_poliza
	AND b.cod_tipoprod   <> _cod_tipoprod1  --No incluye reaseguro asumido

--Calculo de la fecha_tran cuando pertenece a otro periodo
{		LET _ano1 = Year(_periodo_tran);
		LET _mes1 = Month(_periodo_tran);
		LET _dia1 = day(a_fecha);

	    IF month(a_fecha) <> _mes1 And year(a_fecha) >= _ano1 Then 
			LET _fecha_tran = _dia1 || '/' || _mes1 || '/' || _ano1;
		ELSE 
		    LET _fecha_tran = a_fecha;
	    END IF}

	LET _tipo_tran = 'F';

	LET _consecutivo = _consecutivo + 1;
	LET _cantidad    = _cantidad + 1;

	Insert Into dbgdeta(
		consecutivo,		
		fecha_dia,
		fecha_tran,
		no_poliza,
		no_endoso,
		no_remesa,
		renglon,
		no_requis,
		no_documento,
		monto,
		tipo_tran
		)
		values(
		_consecutivo,
		today,
		a_fecha, --fecha_tran
		_no_poliza,
		_no_endoso,
		null,
		null,
		null,
		_no_documento,
		_monto,
		_tipo_tran
		);

  		UPDATE dbgacum 
		   SET dbgacum.fecha_tran    = a_fecha,
			   dbgacum.monto_factura = dbgacum.monto_factura + _monto
		WHERE dbgacum.fecha_tran    = a_fecha;
	
END FOREACH

-- Cheques Pagados
FOREACH 
 SELECT b.no_poliza,
        b.no_documento,
		b.no_requis,
		a.monto
   INTO _no_poliza,
        _no_documento,
		_no_requis,
		_monto
   FROM chqchmae a, chqchpol b, emipomae c
  WHERE a.pagado          = 1
    AND	a.fecha_impresion = a_fecha
	AND a.origen_cheque   = "6"
	AND a.no_requis       = b.no_requis
	AND b.no_poliza       = c.no_poliza
	AND c.cod_tipoprod    <> _cod_tipoprod1  --No incluye reaseguro asumido

	LET _tipo_tran = 'P';

	LET _consecutivo = _consecutivo + 1;
	LET _cantidad    = _cantidad + 1;

	Insert Into dbgdeta(
		consecutivo,
		fecha_dia,
		fecha_tran,
		no_poliza,
		no_endoso,
		no_remesa,
		renglon,
		no_requis,
		no_documento,
		monto,
		tipo_tran
		)
		values(
		_consecutivo,
		today,
		a_fecha,
		_no_poliza,
		null,
		null,
		null,
		_no_requis,
		_no_documento,
		_monto,
		_tipo_tran
		);

		UPDATE dbgacum 
		   SET dbgacum.fecha_tran    = a_fecha,
			   dbgacum.monto_cheque  = dbgacum.monto_cheque + _monto
		 WHERE dbgacum.fecha_tran    = a_fecha;
	
END FOREACH

-- Cheques Anulados
FOREACH 
 SELECT b.no_poliza,
        b.no_documento,
		b.no_requis,
		b.monto
   INTO _no_poliza,
        _no_documento,
		_no_requis,
		_monto
   FROM chqchmae a, chqchpol b, emipomae c
  WHERE a.anulado       = 1
    AND	a.fecha_anulado = a_fecha
	AND a.origen_cheque = "6"
	AND a.no_requis     = b.no_requis
	AND b.no_poliza     = c.no_poliza
	AND c.cod_tipoprod  <> _cod_tipoprod1  --No incluye reaseguro asumido

	LET _tipo_tran = 'A';

	LET _consecutivo = _consecutivo + 1;
	LET _cantidad    = _cantidad + 1;

	Insert Into dbgdeta(
		consecutivo,
		fecha_dia,
		fecha_tran,
		no_poliza,
		no_endoso,
		no_remesa,
		renglon,
		no_requis,
		no_documento,
		monto,
		tipo_tran
		)
		values(
		_consecutivo,
		today,
		a_fecha,
		_no_poliza,
		null,
		null,
		null,
		_no_requis,
		_no_documento,
		_monto,
		_tipo_tran
		);

		UPDATE dbgacum 
		   SET dbgacum.fecha_tran    = a_fecha,
			   dbgacum.monto_anulado = dbgacum.monto_anulado + _monto
		 WHERE dbgacum.fecha_tran    = a_fecha;

END FOREACH

-- Pagos
SELECT cob_periodo
  INTO _cob_periodo
  FROM parparam
 WHERE cod_compania = a_compania;

 LET _cob_periodo = "2002-02";

FOREACH 
 SELECT a.no_poliza,
        a.no_remesa,
		a.renglon,
		a.monto,
		a.no_recibo
   INTO _no_poliza,
        _no_remesa,
		_renglon,
		_monto,
		_no_documento
   FROM cobredet a, emipomae b
  WHERE a.periodo        >= _cob_periodo   -- Incluye periodos futuros
    AND a.no_poliza       = b.no_poliza
    AND b.cod_tipoprod   <> _cod_tipoprod1 -- No incluye reaseguro asumido  
	AND a.actualizado     = 1
    AND a.fecha           <= a_fecha
    AND a.tipo_mov        IN ('P', 'N')	   -- Pago de Prima(P) y Notas de Credito(N) 

	 SELECT count(*)        
	   INTO _valor2
	   FROM dbgdeta
	  WHERE no_remesa  = _no_remesa
	    AND	renglon    = _renglon;

		IF _valor2 = 0 then    

			LET _tipo_tran = 'R';

			LET _consecutivo = _consecutivo + 1;
			LET _cantidad    = _cantidad + 1;

			Insert Into dbgdeta(
				consecutivo,
				fecha_dia,
				fecha_tran,
				no_poliza,
				no_endoso,
				no_remesa,
				renglon,
				no_requis,
				no_documento,
				monto,
				tipo_tran
				)
			values(
				_consecutivo,
				today,
				a_fecha,
				_no_poliza,
				null,
				_no_remesa,
				_renglon,
				null,
				_no_documento,
				_monto,
				_tipo_tran
				);

				UPDATE dbgacum 
				   SET dbgacum.fecha_tran    = a_fecha,
					   dbgacum.monto_pago    = dbgacum.monto_pago + _monto
				 WHERE dbgacum.fecha_tran    = a_fecha;

		END IF

END FOREACH

END 

commit work;
return _cantidad, "Registros Procesados ...";

end procedure

