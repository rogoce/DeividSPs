-- Incurrido de las Transacciones Pendientes de Pago
-- Reclamos
--
-- Creado    : 22/01/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec46;

CREATE PROCEDURE "informix".sp_rec46(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7)
		) RETURNING CHAR(255);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _reserva_total   DECIMAL(16,2);
DEFINE _reserva_bruto   DECIMAL(16,2);
DEFINE _reserva_neto    DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo      CHAR(10);
DEFINE _transaccion     CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;

DEFINE _fecha           DATE;
DEFINE _fecha_pagado    DATE;
DEFINE _fecha_trans     DATE;

DEFINE _ano1			SMALLINT;
DEFINE _mes1			SMALLINT;
DEFINE _dia1			SMALLINT;
DEFINE _ano2			SMALLINT;
DEFINE _mes2			SMALLINT;
DEFINE _fecha1          DATE;
DEFINE _fecha2          DATE;
DEFINE _fecha_char      CHAR(10);

-- Fecha Incial

LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

IF _mes1 < 10 THEN
	LET _fecha_char = '01/0' || _mes1 || '/' || _ano1;
ELSE
	LET _fecha_char = '01/'  || _mes1 || '/' || _ano1;
END IF

LET _fecha1 = _fecha_char;

-- Fecha Final

LET _ano2 = a_periodo1[1,4];
LET _mes2 = a_periodo1[6,7];

IF _mes2 = 12 THEN
	LET _ano2 = _ano2 + 1;
	LET _mes2 = 1;
ELSE
	LET _mes2 = _mes2 + 1;
END IF	

IF _mes2 < 10 THEN
	LET _fecha_char = '01/0' || _mes2 || '/' || _ano2;
ELSE
	LET _fecha_char = '01/'  || _mes2 || '/' || _ano2;
END IF

LET _fecha2 = _fecha_char;

LET _dia1 = _fecha2 - _fecha1;

-- Ultimo Dia del Mes

IF _mes1 < 10 THEN
	LET _fecha_char = _dia1 || '/0' || _mes1 || '/' || _ano1;
ELSE
	LET _fecha_char = _dia1 || '/'  || _mes1 || '/' || _ano1;
END IF

LET _fecha = _fecha_char;

--RETURN _fecha_char;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

--DROP TABLE tmp_incurrido;
--DROP TABLE tmp_sinis;

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		transaccion          CHAR(10),
		fecha				 DATE,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo, transaccion);

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		transaccion          CHAR(10),
		fecha				 DATE,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
		ajust_interno   	 CHAR(3)   NOT NULL,
		cod_evento     	     CHAR(3)   NOT NULL,
		cod_suceso     	     CHAR(3),
		cod_cliente          CHAR(10)  NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		posible_recobro		 INT       NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		doc_poliza           CHAR(20)  NOT NULL,
		PRIMARY KEY (no_reclamo, transaccion)
		) WITH NO LOG;

{                                                          
 CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);  
 CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);     
 CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);      
 CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno); 
 CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);    
 CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);    
 CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);     
}                                                          

-- Pagos y Reserva

LET _monto_total   = 0;
LET _monto_bruto   = 0;
LET _monto_neto    = 0;

LET _reserva_total = 0;
LET _reserva_bruto = 0;
LET _reserva_neto  = 0;

FOREACH
 SELECT r.no_reclamo,
 		r.monto,
		r.variacion,
		r.transaccion,
		r.fecha_pagado,
		r.fecha
   INTO _no_reclamo,	
   		_monto_total,
		_reserva_total,
		_transaccion,
		_fecha_pagado,
		_fecha_trans
   FROM rectrmae r, rectitra t
  WHERE r.cod_compania     = a_compania
    AND r.actualizado      = 1
	AND r.cod_tipotran     = t.cod_tipotran
	AND r.fecha           >= '01/01/2001'
	AND r.fecha           <= _fecha
	AND t.tipo_transaccion = 4
	AND r.fecha_pagado     IS NOT NULL

	IF _fecha_pagado > _fecha THEN
		CONTINUE FOREACH;
	END IF
			       
	-- Informacion de Coseguro

	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	-- Informacion de Reaseguro

	LET _porc_reas = 0;

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		EXIT FOREACH;

	END FOREACH 

	-- Calculos

	LET _monto_bruto   = _monto_total / 100 * _porc_coas;
	LET _monto_neto    = _monto_bruto / 100 * _porc_reas;
	LET _reserva_bruto = _monto_total / 100 * _porc_coas;
	LET _reserva_neto  = _monto_bruto / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	transaccion,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	fecha
	)
	VALUES(
	_no_reclamo,
	_transaccion,
	_monto_total,
	_monto_bruto,
	_monto_neto,
	_reserva_total,
	_reserva_bruto,
	_reserva_neto,
	_fecha_trans
	);

END FOREACH

BEGIN

DEFINE _pagado_total  DEC(16,2);
DEFINE _pagado_bruto  DEC(16,2);
DEFINE _pagado_neto   DEC(16,2);
DEFINE _reserva_total DEC(16,2);
DEFINE _reserva_bruto DEC(16,2);
DEFINE _reserva_neto  DEC(16,2);

FOREACH 
 SELECT no_reclamo,	
		transaccion,
		fecha,
        SUM(pagado_total),
		SUM(pagado_bruto),
		SUM(pagado_neto),
		SUM(reserva_total),
		SUM(reserva_bruto),
		SUM(reserva_neto)
   INTO _no_reclamo,	
		_transaccion,
		_fecha_trans,
        _pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_reserva_total,
		_reserva_bruto,
		_reserva_neto
   FROM tmp_incurrido
  GROUP BY no_reclamo, transaccion, fecha
  
  	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,
	       periodo,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  INTO _no_poliza,
	       _periodo,
	       _numrecla,
		   _ajust_interno,
		   _cod_evento,
		   _cod_suceso,
		   _posible_recobro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Informacion de Polizas

	SELECT cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento,
		   cod_sucursal
	  INTO _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza,
		   _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	INSERT INTO tmp_sinis(
	no_reclamo,
	transaccion,
	fecha,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	no_poliza,
	periodo,
	numrecla,
	ajust_interno,
	cod_evento,
	cod_suceso,
	posible_recobro,
	cod_ramo,
	cod_grupo,
	cod_subramo,
	cod_cliente,
	doc_poliza,
	cod_sucursal,
	incurrido_total,
	incurrido_bruto,
	incurrido_neto,
	seleccionado
	)
	VALUES(
	_no_reclamo,
	_transaccion,
	_fecha_trans,
	_pagado_total,
	_pagado_bruto,
	_pagado_neto,
	_reserva_total,
	_reserva_bruto,
	_reserva_neto,
	_no_poliza,
	_periodo,
	_numrecla,
	_ajust_interno,
	_cod_evento,
	_cod_suceso,
	_posible_recobro,
	_cod_ramo,
	_cod_grupo,
	_cod_subramo,
	_cod_cliente,
	_doc_poliza,
	_cod_sucursal,
	0,
	0,
	0,
	1
	);

END FOREACH

DROP TABLE tmp_incurrido;

END 

-- Actualizacion del Incurrido

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;

END PROCEDURE;
