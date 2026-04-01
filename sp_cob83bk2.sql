-- Procedimiento que Genera la Remesa de los ACH

-- ref. sp_cob50;   : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Creado: 29/01/2002 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob83bk2;

CREATE PROCEDURE "informix".sp_cob83bk2(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code,_no_tran      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(20); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(100);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_cliente   	CHAR(10);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _no_cuenta		CHAR(17);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(100);
DEFINE _cod_pagador   	CHAR(10);
DEFINE _nombre_pagador 	CHAR(100);
DEFINE _cargo			DEC(16,2);
DEFINE _monto_rem		DEC(16,2);
DEFINE _cod_banco       CHAR(3);
DEFINE _cod_chequera    CHAR(3);
DEFINE _recibi_de       CHAR(50);
DEFINE _pronto_pago     smallint;
DEFINE _error       	integer;
DEFINE _mensaje  	  	char(50);
DEFINE _fec_rec         date;
define _fec_ano         smallint;
define _fec_mes			smallint;
define _cnt             smallint;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Ach', '';
END EXCEPTION           

--SET DEBUG FILE TO "sp_cob83.trc";
--TRACE ON;

LET _tipo_mov       = 'P'; 
LET _null           = NULL;
LET a_no_remesa     = '1'; 
let _nombre_cliente = "";
let _mensaje        = ""; 
let _fec_rec        = current;

let _fec_ano        = year(_fec_rec);
let _fec_mes        = month(_fec_rec);

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	

LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

-- Numero de Comprobante

LET a_no_recibo = 'ACH';	-- ACH

IF DAY(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || DAY(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || DAY(_fecha);
END IF

IF MONTH(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || MONTH(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || MONTH(_fecha);
END IF

LET _ano_char   = YEAR(_fecha);
LET a_no_recibo = TRIM(a_no_recibo) || _ano_char[3,4];

-- Insertar el Maestro de Remesas

select valor_parametro
  into _cod_banco
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_caja';

let _cod_banco = trim(_cod_banco);

select valor_parametro
  into _cod_chequera
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_ach';

let _recibi_de = "REMESA DE ACH: " || a_no_recibo;

INSERT INTO cobremae(
no_remesa,
cod_compania,
cod_sucursal,
cod_banco,
cod_cobrador,
recibi_de,
tipo_remesa,
fecha,
comis_desc,
contar_recibos,
monto_chequeo,
actualizado,
periodo,
user_added,
date_added,
user_posteo,
date_posteo,
subir_bo,
cod_chequera
)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
_cod_banco,
_null,
_recibi_de,
'C',
_fecha,
0,
3,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha,
0,
_cod_chequera
);

LET _renglon = 0;

FOREACH
	--Leer las transacciones
	 SELECT no_cuenta,
	        cod_pagador,
			motivo,
			nombre_pagador,
			periodo,
			monto,
			cargo,
			no_tran,
			no_documento,
			pronto_pago
	   INTO	_no_cuenta,
	        _cod_pagador,
			_motivo_rechazo,
			_nombre_pagador,
			_periodo,
			_monto,
			_cargo,
			_no_tran,
			_no_documento,
			_pronto_pago
	   FROM cobcutmp
	  WHERE rechazado = 0	--transacciones aprobados
	  order by nombre_pagador

		LET _renglon   = _renglon + 1;
		LET _no_poliza = sp_sis21(_no_documento);

	   foreach
			--Leer el detalle de ach
			SELECT nombre
			  INTO _nombre_cliente
			  FROM cobcutas
			 WHERE trim(no_cuenta) = trim(_no_cuenta)
			   and no_documento    = _no_documento

			exit foreach;
	   end foreach

		if _nombre_cliente is null then
			let _nombre_cliente = "";
		end if

	   {SELECT SUM(saldo)  --02/02/2011 se cambio para que trajera el saldo correcto
		  INTO _saldo
		  FROM emipomae
		 WHERE no_documento = _no_documento
		   AND actualizado  = 1; }

		let _saldo = sp_cob115b('001','001',_no_documento,'');

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF

	-- Impuestos de la Poliza

		SELECT SUM(i.factor_impuesto)
		  INTO _factor
		  FROM prdimpue i, emipolim p
		 WHERE i.cod_impuesto = p.cod_impuesto
		   AND p.no_poliza    = _no_poliza;

		IF _factor IS NULL THEN
			LET _factor = 0;
		END IF

		LET _factor   = 1 + _factor / 100;

		LET _prima     = _monto / _factor;
		LET _impuesto  = _monto - _prima;
		LET _monto_rem = _monto;
		let _saldo     = _saldo - _monto;
	-- Descripcion de la Remesa
	
		LET _nombre_agente = "";

		FOREACH
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza

			SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			EXIT FOREACH;

		END FOREACH

		if _nombre_cliente is null then
			let _nombre_cliente = "";
		end if

		LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
	 
		-- insercion de las polizas con pronto pago a la tabla cobpronde
		if _pronto_pago = 1 then
			call sp_cob50c(_no_documento,a_user) returning _error, _mensaje;
		end if

		-- Detalle de la Remesa
		INSERT INTO cobredet(
	    no_remesa,
	    renglon,
	    cod_compania,
	    cod_sucursal,
	    no_recibo,
	    doc_remesa,
	    tipo_mov,
	    monto,
	    prima_neta,
	    impuesto,
	    monto_descontado,
	    comis_desc,
	    desc_remesa,
	    saldo,
	    periodo,
	    fecha,
	    actualizado,
		no_poliza
		)
		VALUES(
	    a_no_remesa,
	    _renglon,
	    a_compania,
	    a_sucursal,
	    a_no_recibo,
	    _no_documento,
	    _tipo_mov,
	    _monto_rem,
	    _prima,
	    _impuesto,
	    0,
	    0,
	    _descripcion,
	    _saldo,
	    _periodo,
	    _fecha,
	    0,
		_no_poliza
		);

		FOREACH
		 SELECT	cod_agente,
				porc_partic_agt,
				porc_comis_agt
		   INTO	_cod_agente,
				_porc_partic,
				_porc_comis
		   FROM	emipoagt
		  WHERE no_poliza = _no_poliza

		 INSERT INTO cobreagt
		 VALUES(
		 a_no_remesa,
		 _renglon,
		 _cod_agente,
		 0,
		 0,
		 _porc_comis,
		 _porc_partic
		 );  
		  
		END FOREACH

	UPDATE cobcutas
	   SET rechazada       = 0
	 WHERE trim(no_cuenta) = trim(_no_cuenta)
	   AND no_documento    = _no_documento;

	update emipoliza
	   set motivo_rechazo = ''
	 where no_documento   = _no_documento;


END FOREACH

-- Actualizar el detalle de ach, el campo de cargo_especial en cero
FOREACH
	--Leer las transacciones
	SELECT no_cuenta
	  INTO	_no_cuenta
	  FROM cobcutmp
	 WHERE rechazado = 0	--transacciones aprobadas

	FOREACH
		--Leer el detalle de ach
		SELECT no_documento
		  INTO _no_documento
		  FROM cobcutas
		 WHERE trim(no_cuenta) = trim(_no_cuenta)
		   AND periodo         = _periodo

		UPDATE cobcutas
		   SET cargo_especial  = 0.00
		 WHERE trim(no_cuenta) = trim(_no_cuenta)
		   AND no_documento    = _no_documento;

	END FOREACH
END FOREACH

SELECT SUM(monto)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;

--****************************************************
-- Actualizacion de la Gestion para los ACH Rechazados

LET _fecha_gestion  = CURRENT YEAR TO SECOND;	

FOREACH

 SELECT no_cuenta,
		motivo,
		periodo,
		no_documento
   INTO	_no_cuenta,
		_motivo_rechazo,
		_periodo,
		_no_documento
   FROM cobcutmp
  WHERE rechazado = 1	--transacciones rechazados

	update cobcuhab
	   set rechazada  = 1
	 where no_cuenta = _no_cuenta;

  if _motivo_rechazo is null then
	let _motivo_rechazo = "";
  end if
--  este update es para marcar la poliza como rechazada.
	UPDATE cobcutas
	   SET rechazada       = 1
	 WHERE trim(no_cuenta) = trim(_no_cuenta)
	   AND no_documento    = _no_documento;
	

	LET _no_poliza      = sp_sis21(_no_documento);
	LET _motivo_rechazo = "RECHAZO ACH: " || TRIM(_motivo_rechazo);
	LET _fecha_gestion  = _fecha_gestion + 1 UNITS SECOND;	

	Update emipoliza
	   set motivo_rechazo = _motivo_rechazo
	 where no_documento	  = _no_documento;

	select COUNT(*)
	  into _cnt
	  from cobgesti
	 where no_poliza            = _no_poliza
	   and year(fecha_gestion)  = _fec_ano
	   and month(fecha_gestion) = _fec_mes
	   and desc_gestion[1,4]    = 'RECH';

	if _cnt = 9 then
		Update emipoliza
		   set cant_rechazo = cant_rechazo + 1
		 where no_documento	= _no_documento;
	end if
	
	   BEGIN
		  	ON EXCEPTION IN(-239)
		  	END EXCEPTION
			INSERT INTO cobgesti(
			no_poliza,
			fecha_gestion,
			desc_gestion,
			user_added,
			no_documento,
			fecha_aviso,
			tipo_aviso
			)
			VALUES(
			_no_poliza,
			_fecha_gestion,
			_motivo_rechazo,
			a_user,
			_no_documento,
			_null,
			0
			);
	   END	 
END FOREACH

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;
