-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 26/01/2004 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob136a;

CREATE PROCEDURE "informix".sp_cob136a(
a_compania 		CHAR(3), 
a_sucursal 		CHAR(3), 
a_no_documento  CHAR(20),
a_ano			integer
) RETURNING	DATE,  	      -- Fecha	min
			DATE,  	      -- Fecha	max
			DEC(16,2),    -- MONTO
			VARCHAR(100), -- PAGADOR
			CHAR(20),     -- CEDULA
			VARCHAR(100), -- ASEGURADO
			VARCHAR(50),
			SMALLINT,
			DATE,
			DATE,
			DEC(16,2),
			DEC(16,2),
			SMALLINT;

DEFINE v_fecha		      DATE;
DEFINE v_fecha_min        DATE;
DEFINE v_fecha_max        DATE;
DEFINE _fecha_factura     DATE;
DEFINE v_referencia       CHAR(20);
DEFINE v_documento        CHAR(20);
DEFINE _cedula		      CHAR(20);
DEFINE v_monto            DEC(16,2);
DEFINE v_prima            DEC(16,2);
DEFINE v_saldo            DEC(16,2);	 
DEFINE v_periodo          CHAR(7);
DEFINE v_cod_endomov      CHAR(3);
DEFINE v_cod_tipocan      CHAR(3);
DEFINE _cod_tipoprod      CHAR(3);

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_pagador      CHAR(10);
DEFINE _tipo_fac         CHAR(30);
DEFINE _nueva_renov      CHAR(1);
DEFINE _tipo_remesa      CHAR(1);
DEFINE _no_requis		 CHAR(10);
DEFINE _no_remesa		 CHAR(10);
DEFINE _pagado           SMALLINT;
DEFINE _anulado          SMALLINT;
DEFINE _ramo_sis	     SMALLINT;
DEFINE _cod_banco        CHAR(3);
DEFINE _cod_ramo	     CHAR(3);
define _nombre_asegurado varchar(100);
define _nombre_ramo		 varchar(50);
define _nombre_pagador   varchar(100);
define _flag			 smallint;
define _saber_cobro		 smallint;
define _saber_reclamo	 smallint;
define _sindato			 smallint;
define _cod_tipotran    char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _numrecla		char(20);
define _fecha_siniestro	date;
define _no_unidad		char(10);
define _gasto_fact		dec(16,2);
define _pago_prov		dec(16,2);
define v_fecha_rec_min  date;
define v_fecha_rec_max	date;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;

CREATE TEMP TABLE tmp_saldo1(
        fecha           DATE,
		referencia      CHAR(20),
		no_documento    CHAR(20),
		monto           DEC(16,2),
		prima_neta      DEC(16,2),
		periodo			CHAR(7),
		no_poliza       CHAR(10),
		tipo_fac        CHAR(30)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_rec1(
        fecha           DATE,
		facturado       DEC(16,2),
		pagado		    DEC(16,2)
		) WITH NO LOG;   

FOREACH
 SELECT no_poliza,
        nueva_renov,
		cod_ramo
   INTO _no_poliza,
        _nueva_renov,
		_cod_ramo
   FROM emipomae
  WHERE no_documento = a_no_documento
    AND actualizado  = 1

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

		LET _tipo_fac = 'REMESA ' || _no_remesa;

		INSERT INTO tmp_saldo1(
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

END FOREACH

 SELECT min(fecha),
		max(fecha),
        sum(monto)
   INTO v_fecha_min,
        v_fecha_max,
        v_monto
   FROM tmp_saldo1
  WHERE year(fecha) = a_ano;

if v_fecha_min is null then
	let _saber_cobro = 1;
end if

 let _no_poliza = sp_sis21(a_no_documento);

 SELECT cod_contratante,
		cod_pagador
   INTO _cod_contratante,
        _cod_pagador
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 SELECT nombre,
		cedula
   INTO _nombre_pagador,
        _cedula
   FROM cliclien
  WHERE cod_cliente = _cod_pagador;

 SELECT nombre
   INTO _nombre_asegurado
   FROM cliclien
  WHERE cod_cliente = _cod_contratante;

 SELECT nombre,
		ramo_sis
   INTO _nombre_ramo,
		_ramo_sis
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;

 if _ramo_sis <> 5 then		--si no es salud
	let _flag = 1;
	let _pago_prov  = 0;
	let _gasto_fact = 0;
	let v_fecha_rec_min = today;
	let v_fecha_rec_max = today;
 else
	select cod_tipotran
	  into _cod_tipotran
	  from rectitra
	 where tipo_transaccion = 4;

	foreach
	 select	numrecla,
	        fecha_siniestro,
			no_reclamo,
			no_unidad,
			no_poliza,
			periodo
	   into	_numrecla,
	        _fecha_siniestro,
			_no_reclamo,
			_no_unidad,
			_no_poliza,
			_periodo
	   from recrcmae
	  where	no_documento   = a_no_documento
	    and actualizado    = 1

		foreach
			 select fecha,
					no_tranrec,
					fecha_factura
			   into	_fecha_gasto,
					_no_tranrec,
					_fecha_factura
			   from rectrmae
			  where no_reclamo   = _no_reclamo
			    and actualizado  = 1
				and cod_tipotran = _cod_tipotran

			 select	sum(facturado),
					sum(monto)
			   into	_gasto_fact,
					_pago_prov
			   from rectrcob
			  where no_tranrec = _no_tranrec;

			if _fecha_factura is null then
				let _fecha_factura = _fecha_gasto;
			end if

			-- En vez de fecha de la transaccion de puso fecha de factura
			-- Solicitado por Maruquel el 06/02/2007
			-- Cambiado por Demetrio Hurtado

			INSERT INTO tmp_rec1(
			fecha,
			facturado,
			pagado
			)
			VALUES(
			_fecha_factura,
			_gasto_fact,
			_pago_prov
		    );
		end foreach
	end foreach

	 SELECT min(fecha),
			max(fecha),
	        sum(facturado),
			sum(pagado)
	   INTO v_fecha_rec_min,
	        v_fecha_rec_max,
	        _gasto_fact,
			_pago_prov
	   FROM tmp_rec1
	  WHERE year(fecha) = a_ano;

	if v_fecha_rec_min is null then
		let _saber_reclamo = 1;
	end if
 end if

DROP TABLE tmp_saldo1;
DROP TABLE tmp_rec1;

if _saber_cobro = 1 and _saber_reclamo = 1 then  --no tiene datos
	let _sindato = 1;
elif _saber_reclamo = 1 then
	let _sindato = 2;
	let _flag = 1;
end if

  RETURN v_fecha_min,
		 v_fecha_max,  
		 abs(v_monto),
		 trim(_nombre_pagador),
		 trim(_cedula),
		 trim(_nombre_asegurado),
		 trim(_nombre_ramo),
		 _flag,
		 v_fecha_rec_min,
		 v_fecha_rec_max,
		 _gasto_fact,
		 _pago_prov,
		 _sindato;

END PROCEDURE