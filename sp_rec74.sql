-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 23/01/2003 - Autor: Amado Perez 
--                          Se modifico para que leyera la sucursal del campo sucursal_origen
--                          de emipomae y no de cod_sucursal
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec74;

CREATE PROCEDURE "informix".sp_rec74(
a_compania  CHAR(3),
a_agencia   CHAR(3),
a_periodo1  CHAR(7),
a_periodo2  CHAR(7)
) RETURNING CHAR(18),
            dec(16,2),
            dec(16,2);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente     CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo,_periodo_rec CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _cod_acreedor    CHAR(5);

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_abierto	 DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)  NOT NULL
		) WITH NO LOG;

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH
 SELECT no_reclamo,
 		monto,
		periodo
   INTO _no_reclamo,
   		_monto_total,
		_peri
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
	AND cod_tipotran IN ('004','005','006','007')
	AND periodo      >= a_periodo1 
	AND periodo      <= a_periodo2
    AND monto        <> 0

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

	SELECT periodo
	  INTO _periodo_rec
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	IF _periodo_rec >= a_periodo1 AND _periodo_rec <= a_periodo2 THEN
	   IF _periodo_rec = _peri THEN
	   		LET _incurrido_abierto = _monto_bruto;
	   ELSE
	   		LET _incurrido_abierto = 0;
	   END IF
	ELSE
	   LET _incurrido_abierto = 0;
	END IF

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	incurrido_abierto,
	periodo
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto,
	_incurrido_abierto,
	_peri
	);

END FOREACH

-- Variacion de Reserva

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH 
 SELECT no_reclamo,	
 		variacion,
		periodo
   INTO _no_reclamo,	
   		_monto_total,
		_peri
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND cod_tipotran MATCHES '*' -- Para que incluya el indice creado
	AND periodo      >= a_periodo1 
	AND periodo      <= a_periodo2
    AND variacion    <> 0

	-- Informacion de Coaseguro

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

		IF _porc_reas IS NULL OR _porc_reas = 0 THEN
			LET _porc_reas = 0;
		END IF;

		EXIT FOREACH;

	END FOREACH
 
	SELECT periodo
	  INTO _periodo_rec
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Calculos

	LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

	IF _periodo_rec >= a_periodo1 AND _periodo_rec <= a_periodo2 THEN
	   IF _periodo_rec = _peri THEN
	   		LET _incurrido_abierto = _monto_bruto;
	   ELSE
	   		LET _incurrido_abierto = 0;
	   END IF
	ELSE
	   LET _incurrido_abierto = 0;
	END IF

	-- Actualizacion del Movimiento

	INSERT INTO tmp_incurrido(
	no_reclamo,
	reserva_total,
	reserva_bruto,
	reserva_neto,
	incurrido_abierto,
	periodo
	)
	VALUES(
	_no_reclamo,
	_monto_total,
	_monto_bruto,
	_monto_neto,
	_incurrido_abierto,
	_peri
	);

END FOREACH

-- Actualizacion del Incurrido

{
UPDATE tmp_incurrido
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;
}

BEGIN

DEFINE _pagado_total  DEC(16,2);
DEFINE _pagado_bruto  DEC(16,2);
DEFINE _pagado_neto   DEC(16,2);
DEFINE _reserva_total DEC(16,2);
DEFINE _reserva_bruto DEC(16,2);
DEFINE _reserva_neto  DEC(16,2);

define _bo_pagado_total	DEC(16,2);
define _bo_pagado_bruto DEC(16,2);

FOREACH 
 SELECT no_reclamo,	
        SUM(pagado_total),
		SUM(pagado_bruto),
		SUM(pagado_neto),
		SUM(reserva_total),
		SUM(reserva_bruto),
		SUM(reserva_neto),
		SUM(incurrido_abierto)
   INTO _no_reclamo,	
        _pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_reserva_total,
		_reserva_bruto,
		_reserva_neto,
		_incurrido_abierto
   FROM tmp_incurrido
  GROUP BY no_reclamo
  
	select numrecla
	  into _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select pagado_bru
	  into _bo_pagado_bruto
	 from incurrid
	where numrecla = _numrecla;
	
	if _pagado_bruto <> _bo_pagado_bruto then

		return _numrecla,
		       _pagado_bruto,
		       _bo_pagado_bruto
		       with resume;
	end if		         	

END FOREACH

DROP TABLE tmp_incurrido;

END 

END PROCEDURE;
