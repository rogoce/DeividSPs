-- Procedimiento que cra la gestion automatica

-- Creado    : 22/02/2001 - Autor: Armando Moreno
-- Modificado: 28/06/2001 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob211;

CREATE PROCEDURE "informix".sp_cob211(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _dia		      	INTEGER;  

--SET DEBUG FILE TO "sp_cob50.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Tarjetas de Credito', '';         
END EXCEPTION           

LET _tipo_mov   = 'P'; 
LET _null       = NULL;
LET a_no_remesa = '1';  

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

LET a_no_recibo = 'VC';	-- Visa Cargo

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
date_posteo)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
'017',
_null,
_null,
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
_fecha
);

LET _renglon = 0;

FOREACH
 SELECT	no_documento,
		monto,
		nombre,
		no_tarjeta
   INTO	_no_documento,
		_monto,
		_nombre_cliente,
		_no_tarjeta
   FROM cobtatra
  WHERE procesar = 1	 --tarjetas aprobadas
  ORDER BY nombre

 -- desmarcar rechazadas a tarjetas aprobadas.
 update cobtahab
    set rechazada  = 0
  where no_tarjeta = _no_tarjeta;

--	trace _no_documento;

	LET _renglon   = _renglon + 1;
	LET _no_poliza = sp_sis21(_no_documento);

--  este update es para marcar la poliza como NO rechazada.
	UPDATE cobtacre
	   SET rechazada    = 0
	 WHERE no_tarjeta   = _no_tarjeta
	   AND no_documento = _no_documento;

	SELECT SUM(saldo)
	  INTO _saldo
	  FROM emipomae
	 WHERE no_documento = _no_documento
	   AND actualizado  = 1;

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
	LET _prima    = _monto / _factor;
	LET _impuesto = _monto - _prima;
	
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

	LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
	 
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
    _monto,
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

		INSERT INTO cobreagt(
        no_remesa,
		renglon,
		cod_agente,
		monto_calc,
		monto_man,
		porc_comis_agt,
		porc_partic_agt
		)
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

END FOREACH

SELECT SUM(monto)
  INTO _saldo
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

UPDATE cobremae
   SET monto_chequeo = _saldo
 WHERE no_remesa     = a_no_remesa;

--**********************************************************
-- Actualizacion de la Gestion para las Tarjetas Rechazadas*
--**********************************************************

LET _fecha_gestion  = CURRENT YEAR TO SECOND;	

FOREACH
 SELECT no_documento,
		motivo_rechazo,
		no_tarjeta
   INTO _no_documento,
		_motivo_rechazo,
		_no_tarjeta
   FROM cobtatra
  WHERE procesar = 0

	LET _no_poliza      = sp_sis21(_no_documento);
	LET _motivo_rechazo = "RECHAZO VISA: " || TRIM(_motivo_rechazo);
	LET _fecha_gestion  = _fecha_gestion + 1 UNITS SECOND;

	SELECT cod_pagador
  	  INTO _cod_pagador
      FROM emipomae
     WHERE no_poliza = _no_poliza;

--  este update es para marcar la poliza como rechazada.
	UPDATE cobtacre
	   SET rechazada    = 1
	 WHERE no_tarjeta   = _no_tarjeta
	   AND no_documento = _no_documento;

	{update emipomae
	   set cobra_poliza = "E"
	 where no_poliza    = _no_poliza;

	let _error_code = sp_cas022(_no_poliza);		

	update emipomae
	   set cobra_poliza = "T"
	 where no_poliza    = _no_poliza;

	select cod_cobrador
	  into _cod_cobrador
	  from cascliente
	 where cod_cliente = _cod_pagador;

	select fecha_ult_pro
	  into _fecha
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	if _fecha is null then 
		let _fecha = today;
	end if

	let _fecha = _fecha + 2;
	let _dia   = day(_fecha);

	update cascliente
	   set ultima_gestion = "Tarjeta de Credito Numero " || _no_tarjeta || " Rechazada",
	       dia_cobros3    = _dia
	 where cod_cliente    = _cod_pagador;}

	INSERT INTO cobgesti(
	no_poliza,
	fecha_gestion,
	desc_gestion,
	user_added,
	no_documento,
	fecha_aviso,
	tipo_aviso,
	cod_pagador
	)
	VALUES(
	_no_poliza,
	_fecha_gestion,
	_motivo_rechazo,
	a_user,
	_no_documento,
	_null,
	0,
	_cod_pagador
	);

END FOREACH

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;
